//
//  PostDetailsViewController.swift
//  MyRedditApp
//
//  Created by Ira Nazar on 2024-02-27.
//

import SDWebImage
import UIKit

class PostDetailsViewController: UIViewController {
    
    
    @IBOutlet weak var postView: PostView!
    
    override func viewDidLoad() {
            super.viewDidLoad()
        }

        func configure(with post: RedditPost) {
            postView.configure(with: post)
        }
}
