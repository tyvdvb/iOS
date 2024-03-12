//
//  PostDetailsViewController.swift
//  MyRedditApp
//
//  Created by Ira Nazar on 2024-02-27.
//

import SDWebImage
import UIKit


class PostDetailsViewController: UIViewController{
    var onSaveStatusChange: ((RedditPost) -> Void)?
    @IBOutlet weak var postView: PostView!
    
    var currentPost: RedditPost?
    var isSaved: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let post = currentPost {
            postView.configure(with: post)
            postView.updateSaveButtonUI2(saved: isSaved)
            postView.onSaveStatusChange = { [weak self] post in
                self?.handleSaveStatusChange(for: post)
            }
        }
    }
    func configure(with post: RedditPost) {
        postView.configure(with: post)
        //        postView.updateSaveButtonUI()
    }
    
    func handleSaveStatusChange(for post: RedditPost) {
        onSaveStatusChange?(post)
    }
}




