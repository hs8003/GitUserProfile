//
//  ListingTVC.swift
//  PhonePe
//
//  Created by Harshit on 10/07/19.
//  Copyright © 2019 Harshit. All rights reserved.
//

import UIKit
import Alamofire

class ListingTVC: UITableViewController {

    // MARK:Variables
    var url = ""
    var data = [DataModel]()
    var navigationTitle = ""
    var pageCount = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
       performApiRequest(page: pageCount)
    }
    
     // MARK : Make api request to get Followers/Following info for particular user.
    private func performApiRequest(page:Int) {
        Alamofire.request(url+"\(page)").responseData { (response) in
            guard let data = response.data else {return}
            do {
                let model = try JSONDecoder().decode(Array<DataModel>.self, from:data)
                DispatchQueue.main.async {
                    if self.pageCount == 1{
                        self.data = model
                    }
                    else{
                         self.data += model
                    }
                    self.tableView.reloadData()
                }
            } catch {
                print(error)
            }
        }
    }
    
    // MARK : For Pagination Bottom Refresh
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == tableView{
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
            {
                if self.data.count > 0 {
                    pageCount = pageCount+1
                    performApiRequest(page: pageCount)
                }
                else{
                    print ("no more data to load")
                }
            }
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ListingCell", for: indexPath) as? ListingCell{
            cell.name.text = self.data[indexPath.row].login
            cell.img.sd_setImage(with: URL(string: self.data[indexPath.row].avatar_url ?? ""), placeholderImage: UIImage(named: "placeholder"))
           return cell
        }
        return UITableViewCell()
    }
    
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserDetailVC") as? UserDetailVC{
            vc.searchUser = self.data[indexPath.row].login ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

class ListingCell: UITableViewCell {
    
    // MARK:Variables
    @IBOutlet weak var img:UIImageView!
    @IBOutlet weak var name:UILabel!
    
    // MARK:Make circle image of user
    override func awakeFromNib() {
        super.awakeFromNib()
        img.layer.borderWidth = 0.8
        img.layer.masksToBounds = false
        img.layer.borderColor = UIColor.black.cgColor
        img.layer.cornerRadius = img.frame.height/2
        img.clipsToBounds = true
    }
    
}


