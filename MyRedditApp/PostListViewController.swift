//
//  PostListViewController.swift
//  MyRedditApp
//
//  Created by Ira Nazar on 2024-02-20.
//

import UIKit
import SDWebImage

class PostListViewController: UIViewController {
    
    struct Const {
        static let cellIdentifiear = "Cell"
        static let goToDetailsSegueID = "go_to_details"
    }
    
    private var posts: [RedditPost] = []
    private var selectedPost: RedditPost?
    private var after: String?
    private var isFetching = false
    private let pageSize = 10
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPosts()
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Const.goToDetailsSegueID:
            let nextVc = segue.destination as! PostDetailsViewController
            DispatchQueue.main.async {
                if let lastSelectedPost = self.selectedPost {
                    nextVc.configure(with: lastSelectedPost)
                }
            }
        default:
            break
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
            
            let fetchedPosts = fetchedData.data.children.map { $0.data }
            posts.append(contentsOf: fetchedPosts)
            tableView.reloadData()
        } catch {
            print("Error fetching posts: \(error)")
        }
        isFetching = false
    }
    
    
}

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
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.frame.size.height
        
        if offsetY > contentHeight - screenHeight {
            fetchPosts()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedPost = self.posts[indexPath.row]
        self.performSegue(
            withIdentifier: Const.goToDetailsSegueID,
            sender: nil
        )
    }
    
}

