//
//  ProfileViewController.swift
//  Instagram
//
//  Created by LYON on 3/31/22.
//

import UIKit
import Parse
import AlamofireImage
import MBProgressHUD
import PhotosUI

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var posts = [PFObject]()
    var selectedPost: PFObject!
    var numberOfPost: Int!
    
    let myRefreshControl = UIRefreshControl()
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
//        let profile = PFObject(className: "Profile")
//        let image = (profile["image"] as? [PFObject]) ?? []
//        let imageFile = profile["image"] as! PFFileObject
//        let urlString = imageFile.url!
//        let url = URL(string: urlString)!
//
//        profileImage.af.setImage(withURL: url)
        
        myRefreshControl.addTarget(self, action: #selector(loadPost), for: .valueChanged)
        self.tableView.refreshControl = myRefreshControl
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadPost()
    }
    
    @IBAction func onLogout(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let delegate = windowScene.delegate as? SceneDelegate else { return }
        
        delegate.window?.rootViewController = loginViewController
    }
    
    @objc func loadPost() {
        
        numberOfPost = 20
        
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author", "comments", "comments.author"])
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            
            cell.captionLabel.text = post["caption"] as? String
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.photoView.af.setImage(withURL: url)
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let post = posts[indexPath.section]
        let comment = PFObject(className: "Comments")
        
        comment["post"] = post
        comment["author"] = PFUser.current()!
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
