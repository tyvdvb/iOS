//
//  PostView.swift
//  MyRedditApp
//
//  Created by Ira Nazar on 2024-02-27.
//

import UIKit


class PostView: UIView {
    var onSaveStatusChange: ((RedditPost) -> Void)?
    let kCONTENT_XIB_NAME = "PostView"
    
    @IBOutlet var postView: UIView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet var titleLabel: UILabel!
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
    
    private lazy var doubleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        gesture.numberOfTapsRequired = 2
        return gesture
    }()
    
    private lazy var bookmarkLayer: CALayer = {
        let layer = CALayer()
        layer.bounds = CGRect(x: 0, y: 0, width: 30, height: 50)
        layer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        layer.backgroundColor = UIColor.systemBlue.cgColor
        layer.cornerRadius = 5
        layer.isHidden = true
        self.layer.addSublayer(layer)
        return layer
    }()
    
    func commonInit() {
        print("Before loading XIB")
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        postView.fixInView(self)
        print("After loading XIB")
        
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(doubleTapGesture)
        
    }
    
    @objc private func handleDoubleTap() {
        guard var redditPost = redditPost else { return }
        redditPost.saved = !redditPost.saved
        if redditPost.saved {
            DataManager.shared.savePost(redditPost)
        } else {
            DataManager.shared.unsavePost(redditPost)
        }
        
        // Updating UI
        let imageName = redditPost.saved ? "bookmark.fill" : "bookmark"
        let buttonImage = UIImage(systemName: imageName)
        savedBookmark.setImage(buttonImage, for: .normal)
        self.redditPost = redditPost
        
        print(DataManager.shared.getAllSavedPosts())
        drawBookmarkIcon()
        animateBookmarkIcon()
        
        onSaveStatusChange?(redditPost)
    }
    
    private func drawBookmarkIcon() {
        
        bookmarkLayer.removeFromSuperlayer()
        
        let layer = CAShapeLayer()
        layer.bounds = CGRect(x: 0, y: 0, width: 30, height: 50)
        layer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        layer.path = createBookmarkPath().cgPath
        layer.fillColor = UIColor.systemBlue.cgColor
        self.layer.addSublayer(layer)
        bookmarkLayer = layer
    }
    
    private func createBookmarkPath() -> UIBezierPath {
        let path = UIBezierPath()
        let width: CGFloat = 30
        let height: CGFloat = 50
        
        let topLeft = CGPoint(x: 0, y: 0)
        let topRight = CGPoint(x: width, y: 0)
        let bottomRight = CGPoint(x: width, y: height)
        let middleBottom = CGPoint(x: width / 2, y: height * 0.6)
        let bottomLeft = CGPoint(x: 0, y: height)
        
        
        path.move(to: topLeft)
        path.addLine(to: topRight)
        path.addLine(to: bottomRight)
        path.addLine(to: middleBottom)
        path.addLine(to: bottomLeft)
        path.close()
        
        return path
    }
    
    private func animateBookmarkIcon() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let wrapperView = UIView(frame: self.bookmarkLayer.frame)
            self.layer.addSublayer(self.bookmarkLayer)
            wrapperView.layer.addSublayer(self.bookmarkLayer)
            
            UIView.transition(with: wrapperView, duration: 0.5, options: .transitionCrossDissolve) {
                self.bookmarkLayer.isHidden = !self.bookmarkLayer.isHidden
            }
        }
    }
    
    
    func configure(with redditPost: RedditPost) {
        titleLabel.text = redditPost.title
        titleLabel.numberOfLines = 0
        usernameLabel.text = redditPost.displayInfo
        
        
        if let thumbnailURL = redditPost.thumbnail, thumbnailURL.lowercased() != "self",
           let _ = URL(string: thumbnailURL) {
            
            let correctedURL = thumbnailURL.replacingOccurrences(of: "&amp;", with: "&")
            postImage.sd_setImage(with: URL(string: correctedURL), completed: nil)
        } else {
            postImage.image = UIImage(named: "placeholderImage")
        }
        commentsLabel.setTitle("\(redditPost.num_comments)", for: .normal)
        rattingLabel.setTitle("\(redditPost.rating)", for: .normal)
        
        
        self.redditPost = redditPost
        
    }
    
    func prepareForReuse() {
        postImage.image = UIImage(named: "placeholderImage")
        titleLabel.text = "Title"
        usernameLabel.text = "username"
        savedBookmark.setImage(nil, for: .normal)
        rattingLabel.setTitle("0", for: .normal)
        commentsLabel.setTitle("0", for: .normal)
        redditPost = nil
    }
    
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        guard let redditPost = redditPost else { return }
        
        let shareURL = URL(string: redditPost.url)
        let items: [Any] = [shareURL as Any, redditPost.saved]
        
        if let viewController = self.findViewController() {
            let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            viewController.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
    
    func updateSaveButtonUI() {
        guard let redditPost = redditPost else {
            return
        }
        
        print(redditPost.saved)
        let imageName = redditPost.saved ? "bookmark.fill" : "bookmark"
        let buttonImage = UIImage(systemName: imageName)
        savedBookmark.setImage(buttonImage, for: .normal)
        
        self.redditPost = redditPost
    }
    
    func updateSaveButtonUI2(saved: Bool) {
        let imageName = saved ? "bookmark.fill" : "bookmark"
        let buttonImage = UIImage(systemName: imageName)
        savedBookmark.setImage(buttonImage, for: .normal)
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard var redditPost = redditPost else { return }
        redditPost.saved = !redditPost.saved
        
        // Save or remove the post based on its saved status
        if redditPost.saved {
            DataManager.shared.savePost(redditPost)
        } else {
            DataManager.shared.unsavePost(redditPost)
        }
        
        // Updating UI
        let imageName = redditPost.saved ? "bookmark.fill" : "bookmark"
        let buttonImage = UIImage(systemName: imageName)
        savedBookmark.setImage(buttonImage, for: .normal)
        self.redditPost = redditPost
        
        print(DataManager.shared.getAllSavedPosts())
        onSaveStatusChange?(redditPost)
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
