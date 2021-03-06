//
//  PostListTableViewController.swift
//  TimelineCloudKitOnlyAsMentor
//
//  Created by Jeff Norton on 10/31/16.
//  Copyright © 2016 JeffCryst. All rights reserved.
//
import UIKit

class PostListTableViewController: UITableViewController, UISearchResultsUpdating {
    
    //==================================================
    // MARK: - Properties
    //==================================================
    
    var loadingOverlay = UIView()
    var searchController: UISearchController?
    
    //==================================================
    // MARK: - General
    //==================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchController()
        
        requestFullSync()
        
        // Hides the search bar
        if tableView.numberOfRows(inSection: 0) > 0 {
            
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0) , at: .top, animated: false)
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(postsChanged(_:)), name: PostController.PostsChangedNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    //==================================================
    // MARK: - Methods
    //==================================================
    
    @IBAction func refreshControlActivated() {
        
        requestFullSync {
            
            self.refreshControl?.endRefreshing()
        }
    }
    
    func postsChanged(_ notification: Notification) {
        
        tableView.reloadData()
    }
    
    //==================================================
    // MARK: - PostController support
    //==================================================
    
    func requestFullSync(completion: (() -> Void)? = nil) {
        
        let activityIndicatorView = UIActivityIndicatorView()
        PostController.shared.startOverlayedActivityIndicatorView(activityIndicatorView, onView: self.tableView) {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            PostController.shared.performFullSync {
                
                DispatchQueue.main.async {
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    PostController.shared.stopOverlayedActivityIndicatorView(activityIndicatorView)
                    
                    completion?()
                }
            }
        }
    }
    
    //==================================================
    // MARK: - Table view data source
    //==================================================
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return PostController.shared.posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell else {
            
            NSLog("Error casting the cell as a PostTableViewCell")
            return UITableViewCell()
        }
        
        let post = PostController.shared.posts[indexPath.row]
        
        cell.post = post
        
        return cell
    }
    
    //==================================================
    // MARK: - Navigation
    //==================================================
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // How are we getting there?
        
        if segue.identifier == "postCellToDetailSegue" {
            
            // Where are we going?
            if let postDetailTableViewController = segue.destination as? PostDetailTableViewController {
                
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    
                    // We came from the PostListTableViewController
                    
                    // What do we need to pack
                    
                    let post = PostController.shared.posts[selectedIndexPath.row]
                    postDetailTableViewController.post = post
                    
                } else {
                    
                    // We came from the SearchResultsController
                    
                    guard let cell = sender as? PostTableViewCell else {
                        
                        NSLog("Error casting cell coming from SearchResultsController")
                        return
                    }
                    
                    let post = cell.post
                    postDetailTableViewController.post = post
                }
            }
        }
    }
    
    //==================================================
    // MARK: - SearchController
    //==================================================
    
    func setupSearchController() {
        
        let searchResultsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "searchResultsTableViewController")
        
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController?.searchResultsUpdater = self
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = true
        tableView.tableHeaderView = searchController?.searchBar
        
        definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let resultsTableViewController = searchController.searchResultsController as? SearchResultsTableViewController
            , let searchTerm = searchController.searchBar.text
            , searchTerm.characters.count > 0 {
            
            let posts = PostController.shared.posts
            let filteredSearchableRecords = posts.filter { $0.matches(searchTerm: searchTerm) }.map { $0 as SearchableRecord }
            
            let filteredPosts = filteredSearchableRecords as! [Post] 
            
            resultsTableViewController.sourceController = self
            resultsTableViewController.resultsArray = filteredPosts  //matchingPosts
            resultsTableViewController.tableView.reloadData()
        }
    }
    
    
}























