//
//  UserDetailVC.swift
//  PhonePe
//
//  Created by Harshit on 10/07/19.
//  Copyright © 2019 Harshit. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class UserDetailVC: UIViewController {

    // MARK:Variables
    var searchUser = ""
    var followerUrl = ""
    var data:DataModel?
    
    
    //MARK:Outlets
    @IBOutlet weak var userImage:UIImageView!
    @IBOutlet weak var location:UILabel!
    @IBOutlet weak var userName:UILabel!
    @IBOutlet weak var followers:UILabel!
    @IBOutlet weak var following:UILabel!
    @IBOutlet weak var repos:UILabel!
    @IBOutlet weak var gists:UILabel!
    @IBOutlet weak var updatedDate:UILabel!
    @IBOutlet weak var followerView:UIView!
    @IBOutlet weak var followingView:UIView!
    @IBOutlet weak var repo:UIView!
    @IBOutlet weak var gist:UIView!
    @IBOutlet weak var date:UIView!
    @IBOutlet weak var moreInfo:UIView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        setupShareButton()
        performApiRequest(userName: searchUser)
    }
    
    
    //MARK : For Initial UI setup
    func initialSetup(){
        self.navigationItem.title = "Profile"
        userImage.layer.borderWidth = 1
        userImage.layer.masksToBounds = false
        userImage.layer.borderColor = UIColor.black.cgColor
        userImage.layer.cornerRadius = userImage.frame.height/2
        userImage.clipsToBounds = true
        self.followingView.layer.cornerRadius = 5.0
        self.followerView.layer.cornerRadius = 5.0
        self.repo.layer.cornerRadius = 5.0
        self.gist.layer.cornerRadius = 5.0
        self.date.layer.cornerRadius = 5.0
        self.moreInfo.layer.cornerRadius = 5.0
    }
    
    //MARK : Added share button on naviagtion bar
    func setupShareButton(){
        let rightButtonItem = UIBarButtonItem.init(
            title: "Share",
            style: .done,
            target: self,
            action: #selector(rightButtonAction(sender:))
        )
        self.navigationItem.rightBarButtonItem = rightButtonItem
    }
    
    
    //MARK : Perform share button action
    @objc func rightButtonAction(sender: UIBarButtonItem){
        let urlString = [self.data?.login?.uppercased(),self.data?.html_url]
        let activityController = UIActivityViewController(activityItems: urlString as [Any], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
     //MARK : Perform Followers button action
    @IBAction func onClickFollowers(_sender:UIButton){
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ListingTVC") as? ListingTVC{
            vc.url = self.followerUrl+"?&page="
            vc.navigationItem.title = "Followers"
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK : Perform Followings button action
    @IBAction func onClickFollowings(_sender:UIButton){
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ListingTVC") as? ListingTVC{
            vc.url = "https://api.github.com/users/\(searchUser)/following?&page="
            vc.navigationItem.title = "Following"
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    @IBAction func onClickRepos(_sender:UIButton){
    }
    
    //MARK : Perform MoreUserInfo button action
    @IBAction func onClickMoreUserInfo(_sender:UIButton){
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MoreVC") as? MoreVC{
            vc.url = self.data?.html_url ?? ""
            if self.data?.name == nil{
                 vc.navigationItem.title = self.data?.login
            }
            else{
                 vc.navigationItem.title = self.data?.name
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

     // MARK : Make api request to get searched user info.
    private func performApiRequest(userName:String) {
        Alamofire.request(APIUrl.MainUrl.rawValue+"users/\(userName)").responseData { (response) in
            guard let data = response.data else {return}
            do {
                let model = try JSONDecoder().decode(DataModel.self, from:data)
                self.data = model
               DispatchQueue.main.async {
               self.userImage.sd_setImage(with: URL(string: model.avatar_url ?? ""), placeholderImage: UIImage(named: "placeholder"))
                if model.name == nil{
                    self.userName.text = model.login?.uppercased()
                }
                else{
                    self.userName.text = model.name?.uppercased()
                }
                self.location.text = model.location
                self.followers.text = "\(String(describing: model.followers!))"
                self.following.text = "\(String(describing: model.following!))"
                self.repos.text = "\(String(describing: model.public_repos!))"
                self.gists.text = "\(String(describing: model.public_gists!))"
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                 let date:Date = formatter.date(from: model.updated_at!) ?? Date()
                formatter.dateFormat = "MM-dd-yyyy HH:mm"
                let StringDate = formatter.string(from: date)
                self.updatedDate.text = StringDate
                self.followerUrl = "\(String(describing: model.followers_url!))"
                }
            } catch {
                print(error)
            }
        }
    }
}
