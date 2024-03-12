//
//  PostListViewController.swift
//  MyRedditApp
//
//  Created by Ira Nazar on 2024-02-20.
//

import UIKit
import SDWebImage


class PostListViewController: UIViewController, DataManagerDelegate{
    
    struct Const {
        static let cellIdentifiear = "Cell"
        static let goToDetailsSegueID = "go_to_details"
    }
    
    private var posts: [RedditPost] = []
    private var selectedPost: RedditPost?
    private var after: String?
    private var isFetching = false
    private let pageSize = 10
    
    @IBOutlet weak var savedPostsButton: UIButton!
    private var isSavedPostMode = false
    
    @IBOutlet var searchBar: UISearchBar!
    
    
    @IBAction func savedPostsButtonTapped(_ sender: Any) {
        isSavedPostMode.toggle()
        
        savedPostsButton.tintColor = isSavedPostMode ? UIColor.systemBlue : UIColor.systemOrange
        
        searchBar.text = ""
        
        posts.removeAll()
        
        if isSavedPostMode {
            fetchSavedPosts()
        } else {
            fetchPosts()
        }
        configureSearchBarVisibility()
    }
    
    private func fetchSavedPosts() {
        posts = DataManager.shared.getAllSavedPosts()
        tableView.reloadData()
    }
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        DataManager.shared.delegate = self
        configureSearchBarVisibility()
        fetchPosts()
    }
    
    
    func didUnsavePost(_ post: RedditPost) {
        if isSavedPostMode, let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts.remove(at: index)
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    private func configureSearchBarVisibility() {
        searchBar.isHidden = !isSavedPostMode
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Const.goToDetailsSegueID:
            if let nextVc = segue.destination as? PostDetailsViewController,
               let selectedPost = sender as? RedditPost {
                nextVc.currentPost = selectedPost
                nextVc.isSaved = selectedPost.saved
                nextVc.onSaveStatusChange = { [weak self] post in
                    self?.handleSaveStatusChange(for: post)
                }
                DispatchQueue.main.async {
                    if let lastSelectedPost = self.selectedPost {
                        nextVc.configure(with: lastSelectedPost)
                    }
                }
            }
        default:
            break
        }
    }
    
    
    func handleSaveStatusChange(for post: RedditPost) {
        if let index = self.posts.firstIndex(where: { $0.id == post.id }) {
            self.posts[index] = post
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    private func fetchPosts() {
        guard !isFetching else {
            return
        }
        isFetching = true
        let subreddit = "ios"
        
        do {
            let fetchedData = try APIManager.shared.fetchData(subreddit: subreddit, limit: pageSize, after: after)
            after = fetchedData.data.after
            
            var fetchedPosts = fetchedData.data.children.map { $0.data }
            let savedPosts = DataManager.shared.getAllSavedPosts()
            for index in 0..<fetchedPosts.count {
                let post = fetchedPosts[index]
                fetchedPosts[index].saved = savedPosts.contains { $0.id == post.id }
            }
            posts.append(contentsOf: fetchedPosts)
            tableView.reloadData()
        } catch {
            print("Error fetching posts: \(error)")
        }
        isFetching = false
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension PostListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 310
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.cellIdentifiear, for: indexPath) as! PostTableViewCell
        let post = posts[indexPath.row]
        cell.configure(with: post)
        cell.updateSaveButtonUI()
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isSavedPostMode {return}
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.frame.size.height
        
        if offsetY > contentHeight - screenHeight {
            fetchPosts()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedPost = self.posts[indexPath.row]
        //        self.performSegue(
        //            withIdentifier: Const.goToDetailsSegueID,
        //            sender: nil
        //        )
        self.performSegue(withIdentifier: Const.goToDetailsSegueID, sender: self.posts[indexPath.row])
        
    }
    
}

// MARK: - UISearchBarDelegate
extension PostListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Search Text: \(searchText)")
        guard isSavedPostMode else {
            return
        }
        let filteredPosts: [RedditPost]
        
        if searchText.isEmpty {
            filteredPosts = DataManager.shared.getAllSavedPosts()
        } else {
            filteredPosts = DataManager.shared.getAllSavedPosts().filter {
                let titleRange = $0.title.range(of: searchText, options: .caseInsensitive)
                return titleRange != nil
            }
        }
        
        posts = filteredPosts
        tableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


