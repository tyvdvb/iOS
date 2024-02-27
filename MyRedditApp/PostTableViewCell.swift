//
//  PostTableViewCell.swift
//  MyRedditApp
//
//  Created by Ira Nazar on 2024-02-20.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var postView: PostView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(with redditPost: RedditPost) {
        postView.configure(with: redditPost)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postView.prepareForReuse()
    }
    
    
    
    
    
}
