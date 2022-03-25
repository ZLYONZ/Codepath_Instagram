//
//  FeedViewController.swift
//  Instagram
//
//  Created by LYON on 3/20/22.
//

import UIKit
import Parse
import AlamofireImage
import MBProgressHUD

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var posts = [PFObject]()
    var numberOfPost: Int!
    
    let myRefreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        myRefreshControl.addTarget(self, action: #selector(loadPost), for: .valueChanged)
        self.tableView.refreshControl = myRefreshControl
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadPost()
    }
    
    @IBAction func onLogOut(_ sender: Any) {
        PFUser.logOut()
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
    }
    
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
        let post = posts[indexPath.row]
        
        let user = post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        
        cell.captionLabel.text = post["caption"] as? String
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
        cell.photoView.af.setImage(withURL: url)
        
        return cell
    }
    
    @objc func loadPost() {
        
        numberOfPost = 20
        
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.limit = numberOfPost
        
        query.findObjectsInBackground { posts, error in
            if posts != nil {
                self.posts = posts!.reversed()
                self.tableView.reloadData()
                self.myRefreshControl.endRefreshing()
            }
        }
        
        
    }
    
    func loadMorePost() {

        numberOfPost = numberOfPost + 20
        
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.limit = numberOfPost

        query.findObjectsInBackground { posts, error in
            if posts != nil {
                self.posts = posts!.reversed()
                self.tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == posts.count {
            loadMorePost()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
