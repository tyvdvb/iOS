//
//  PostView.swift
//  MyRedditApp
//
//  Created by Ira Nazar on 2024-02-27.
//

import UIKit

class PostView: UIView {
    
    
    let kCONTENT_XIB_NAME = "PostView"
    
    @IBOutlet var postView: UIView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var savedBookmark: UIButton!
    @IBOutlet weak var rattingLabel: UIButton!
    @IBOutlet weak var commentsLabel: UIButton!
    
    private var redditPost: RedditPost?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        print("Before loading XIB")
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        postView.fixInView(self)
        print("After loading XIB")
    }
    
    func configure(with redditPost: RedditPost) {
        titleLabel.text = redditPost.title
        usernameLabel.text = redditPost.displayInfo
        
        
        if let thumbnailURL = redditPost.thumbnail,
           let _ = URL(string: thumbnailURL) {
            let correctedURL = thumbnailURL.replacingOccurrences(of: "&amp;", with: "&")
            postImage.sd_setImage(with: URL(string: correctedURL), completed: nil)
        }
        
        savedBookmark.setImage(UIImage(systemName: "bookmark"), for: .normal)
        commentsLabel.setTitle("\(redditPost.num_comments)", for: .normal)
        rattingLabel.setTitle("\(redditPost.rating)", for: .normal)
        
        self.redditPost = redditPost
        
    }
    
    func prepareForReuse() {
        postImage.image = nil
        titleLabel.text = "Title"
        usernameLabel.text = "username"
        savedBookmark.setImage(nil, for: .normal)
        rattingLabel.setTitle("0", for: .normal)
        commentsLabel.setTitle("4", for: .normal)
        redditPost = nil
    }
}

extension UIView
{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
