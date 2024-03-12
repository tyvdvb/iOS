//
//  DataManager.swift
//  MyRedditApp
//
//  Created by Ira Nazar on 2024-03-05.
//

import Foundation

protocol DataManagerDelegate: AnyObject {
    func didUnsavePost(_ post: RedditPost)
}

class DataManager {
    
    static let shared = DataManager()
    
    weak var delegate: DataManagerDelegate?
    
    private var savedPosts: [RedditPost] = []
    private let savedPostsFileURL: URL
    
    private init() {
        savedPostsFileURL = URL.documentsDirectory.appendingPathComponent("savedPosts.json", isDirectory: false)
        loadSavedPosts()
    }
    
    private func loadSavedPosts() {
        guard FileManager.default.fileExists(atPath: savedPostsFileURL.path) else {
            return
        }
        
        do {
            let data = try Data(contentsOf: savedPostsFileURL)
            let decodedPosts = try JSONDecoder().decode([RedditPost].self, from: data)
            savedPosts = decodedPosts
        } catch {
            print("Error loading saved posts: \(error)")
        }
    }
    
    func savePost(_ post: RedditPost) {
        if !savedPosts.contains(where: { $0.id == post.id }) {
            savedPosts.append(post)
            savePostsToFile()
        }
    }
    
    func unsavePost(_ post: RedditPost) {
        savedPosts.removeAll { $0.id == post.id }
        savePostsToFile()
        
        delegate?.didUnsavePost(post)
    }
    
    private func savePostsToFile() {
        do {
            let encodedData = try JSONEncoder().encode(savedPosts)
            try encodedData.write(to: savedPostsFileURL)
        } catch {
            print("Error saving posts to file: \(error)")
        }
    }
    
    func isPostSaved(_ post: RedditPost) -> Bool {
        return savedPosts.contains(where: { $0.id == post.id })
    }
    
    func getAllSavedPosts() -> [RedditPost] {
        return savedPosts
        
    }
    
    func removeAllSavedPosts() {
        savedPosts.removeAll()
        savePostsToFile()
    }
    
}
