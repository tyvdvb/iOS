//
//  APIManager.swift
//  MyRedditApp
//
//  Created by Ira Nazar on 2024-02-13.
//

import Foundation

struct RedditListing: Codable {
    let kind: String
    let data: RedditData
}

struct RedditData: Codable {
    let children: [RedditPostDataContainer]
}

struct RedditPostDataContainer: Codable {
    let data: RedditPost
}

struct RedditPost: Codable {
    let title: String
    let author: String
    let created_utc: TimeInterval
    let thumbnail: String?
    let num_comments: Int
    var saved: Bool { return false }
    let url: String
    let ups: Int
    let downs: Int
    let domain : String?
}


enum APIError: Error {
    case invalidURL
    case noDataReceived
    case decodingError(Error)
}


class APIManager {
    
    static let shared = APIManager()
    func fetchData(subreddit: String, limit: Int, after: String?)throws -> RedditPost {
        var components = URLComponents(string: "https://www.reddit.com/r/\(subreddit)/top.json")!
               components.queryItems = [
                   URLQueryItem(name: "limit", value: "\(limit)")
               ]
        
        guard let url = components.url else {
                   throw APIError.invalidURL
               }
        let group = DispatchGroup()
        var resultData: Data?
        var resultError: Error?
        
        group.enter()
        URLSession.shared.dataTask(with: url) { data, response, error in
            resultData = data
            resultError = error
            group.leave()
        }.resume()
        
        group.wait()
        
//        if let data = resultData, let jsonString = String(data: data, encoding: .utf8) {
//            print("JSON Response: \(jsonString)")
//        }


        if let error = resultError {
            throw error
        }

        guard let responseData = resultData else {
            throw APIError.noDataReceived
        }

        do {
            let jsonDecoder = JSONDecoder()
            let decodedObject = try jsonDecoder.decode(RedditListing.self, from: responseData)
            
            guard let post = decodedObject.data.children.first?.data else {
                throw APIError.decodingError(NSError(domain: "Invalid data format", code: 0, userInfo: nil))
            }
            let redditPost = RedditPost(
                title: post.title,
                author: post.author,
                created_utc: post.created_utc,
                thumbnail: post.thumbnail,
                num_comments: post.num_comments,
                url: post.url,
                ups: post.ups,
                downs: post.downs,
                domain: post.domain
            )
            return redditPost
        } catch let decodingError {
            throw APIError.decodingError(decodingError)
        }
    }
}

extension RedditPost {
    
    var rating: Int {
        return ups + downs
    }
    
    var formattedTime: String {
        let currentTime = Date().timeIntervalSince1970
        let timeDifference = currentTime - created_utc
        let minutes = Int(timeDifference / 60)
        let hours = Int(timeDifference / 3600)
        let days = Int(timeDifference / 86400)
        
        if days > 0 {
            return "\(days) d"
        } else if hours > 0 {
            return "\(hours) h"
        } else if minutes > 0 {
            return "\(minutes) m"
        } else {
            return "just now"
        }
    }

    var displayInfo: String {
        let domain = self.domain ?? "Unknown Domain"
        return "\(author) • \(formattedTime) • \(domain)"
    }
}

