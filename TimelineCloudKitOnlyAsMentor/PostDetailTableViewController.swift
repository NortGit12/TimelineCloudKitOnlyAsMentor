//
//  PostDetailTableViewController.swift
//  TimelineCloudKitOnlyAsMentor
//
//  Created by Jeff Norton on 10/31/16.
//  Copyright © 2016 JeffCryst. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {
    
    //==================================================
    // MARK: - Properties
    //==================================================
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var followUnfollowButton: UIButton!
    
    let dateFormatter = DateHelper().dateFormatter
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    //==================================================
    // MARK: - General
    //==================================================

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50.0
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(postCommentsChanged(_:)), name: PostController.PostCommentsChangedNotification, object: nil)
    }
    
    //==================================================
    // MARK: - Methods
    //==================================================
    
    func postCommentsChanged(_ notification: Notification) {
        
        guard let notificationPost = notification.object as? Post
            , let post = post
            , notificationPost  === post else { return } // Not our post
        
        updateViews()
    }
    
    func updateViews() {
        
        guard let post = self.post
            , isViewLoaded else { return }
        
        postImageView.image = post.photo
        
        tableView.reloadData()
        
        PostController.shared.checkSubscriptionTo(commentsForPost: post) { (subscribed) in
            
            DispatchQueue.main.async {
                
                self.followUnfollowButton.setTitle(subscribed ? "Unfollow Post" : "Follow Post", for: .normal)
            }
        }
    }

    //==================================================
    // MARK: - Table view data source
    //==================================================

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return post?.comments.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentsCell", for: indexPath)

        guard let post = post else { return UITableViewCell() }
        let comment = post.comments[indexPath.row]
        
        postImageView.image = post.photo
        cell.textLabel?.text = comment.text
        cell.detailTextLabel?.text = dateFormatter.string(from: comment.timestamp)

        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //==================================================
    // MARK: - Actions
    //==================================================
    
    @IBAction func commentButtonTapped(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "New Comment", message: nil, preferredStyle: .alert)
        
        var commentTextField = UITextField()
        alertController.addTextField { (textField) in
            
            textField.placeholder = "Comment..."
            commentTextField = textField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let postAction = UIAlertAction(title: "Post", style: .default) { (action) in
            
            guard let commentText = commentTextField.text
                , commentText.characters.count > 0 else {
                    
                    let errorAlertController = UIAlertController(title: "Error", message: "Required data missing.  The comment must have text.  Try again.", preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    
                    errorAlertController.addAction(okAction)
                    
                    self.present(errorAlertController, animated: true, completion: nil)
                    
                    return
            }
            
            guard let post = self.post else { return }
            
            PostController.shared.addComment(toPost: post, commentText: commentText) { (_) in
                
                commentTextField.resignFirstResponder()
                commentTextField.text = ""
                
                self.tableView.reloadData()
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(postAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
        
        guard let photo = post?.photo, let commentText = post?.comments.first?.text
            else {
                
                NSLog("Error accessing the post's photo and first comment.")
                return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [photo, commentText], applicationActivities: nil)
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func followUnFollowButtonTapped(_ sender: UIBarButtonItem) {
        
        
    }
}




























