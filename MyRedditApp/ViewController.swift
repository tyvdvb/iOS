//
//  ViewController.swift
//  MyRedditApp
//
//  Created by Ira Nazar on 2024-02-12.
//

import UIKit
import SDWebImage

class ViewController: UIViewController {


    @IBOutlet private weak var screenView: UIView!
    @IBOutlet private weak var postImage: UIImageView!
    @IBOutlet private weak var titleLabel: UITextField!
    @IBOutlet private weak var rattingButton: UIButton!
    
    @IBOutlet private weak var commentsButton: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var savedBookmark: UIButton!
    
    @IBOutlet private weak var usernameLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            let topPost = try APIManager.shared.fetchData(subreddit: "ios", limit: 1, after: nil)
            updateUI(with: topPost)
        } catch {
            print("Error fetching Reddit post: \(error)")
        }
    }
    
    private func updateUI(with redditPost: RedditPost) {
        titleLabel.text = redditPost.title
        usernameLabel.text = redditPost.displayInfo
        print("Username: \(redditPost.displayInfo)")
        
        
        if let thumbnailURL = redditPost.thumbnail, let _ = URL(string: thumbnailURL) {
            let correctedURL = thumbnailURL.replacingOccurrences(of: "&amp;", with: "&")
            postImage.sd_setImage(with: URL(string: correctedURL), completed: nil)
        }

       
        savedBookmark.setImage(UIImage(systemName: "bookmark"), for: .normal)
        commentsButton.setTitle("\(redditPost.num_comments)", for: .normal)
        rattingButton.setTitle("\(redditPost.rating)", for: .normal)
    }


}

