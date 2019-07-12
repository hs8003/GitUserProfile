//
//  SearchUserVC.swift
//  PhonePe
//
//  Created by Harshit on 10/07/19.
//  Copyright © 2019 Harshit. All rights reserved.
//

import UIKit
import Alamofire

class SearchUserVC: UIViewController {
    
    
    // MARK:Variables
    var SearchBarValue:String!
    var searchActive : Bool = false
    var data =  [DataModel]()
    var filtered = [DataModel]()
    var totalPageCount = Int()
    var pageCount = 1
    
    //MARK:Outlets
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var tblView:UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK : call api function
        performApiRequest(page: pageCount, userName: "")
    }
    
    
    // MARK : Make api request to get search user info.
    private func performApiRequest(page:Int,userName:String) {
        Alamofire.request(APIUrl.MainUrl.rawValue+"search/users?q=\(userName.lowercased())&page=\(page)").responseData { (response) in
            guard let data = response.data else {return}
            do {
                 let model = try JSONDecoder().decode(DataModel.self, from:data)
                 self.totalPageCount = model.total_count ?? 0
                 // Use Main Thread to update the UI when get the response
                DispatchQueue.main.async {
                    if self.pageCount == 1{
                         self.data = model.items ?? []
                    }
                    else{
                         self.data += model.items ?? []
                    }
                    // Reloading the table view
                    self.tblView.reloadData()
                }
                
            } catch {
                print(error)
            }
        }
    }
    
    
    // MARK : For Pagination Bottom Refresh
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool){
        
        if scrollView == tblView{
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height)
            {
                // To Check the total page count
                if self.data.count < self.totalPageCount {
                    pageCount = pageCount+1
                    performApiRequest(page: pageCount, userName: self.SearchBarValue.lowercased())
                }
            }
        }
    }
}


// MARK : UISearch Bar Delegates
extension SearchUserVC:UISearchBarDelegate{
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        searchBar.text = nil
        searchBar.resignFirstResponder()
        tblView.resignFirstResponder()
        self.searchBar.showsCancelButton = false
        performApiRequest(page: 0, userName: "")
        tblView.reloadData()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        self.searchActive = false;
        self.searchBar.showsCancelButton = true
        
        // To check if search bar is empty, No text there
        if searchText == ""{
             self.data.removeAll()
             performApiRequest(page: 0, userName: "")
             tblView.reloadData()
        }
    }
    
    
    // MARK : Search will be populate result on click this search button
    func searchBarSearchButtonClicked( _ searchBar: UISearchBar)
    {
        self.data.removeAll()
        self.searchActive = true;
        self.searchBar.showsCancelButton = true
        self.SearchBarValue = searchBar.text
        pageCount = 1
        performApiRequest(page: pageCount, userName: searchBar.text?.lowercased() ?? "")
        tblView.reloadData()
        searchBar.resignFirstResponder()
    }
}


// MARK : UITableviewDatasource & UITableviewdelegate
extension SearchUserVC:UITableViewDelegate,UITableViewDataSource{
    
    // MARK : Return the number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK : Return the number of sections
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return data.count
    }
    
     // MARK : Create and Populate the cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListingCell", for: indexPath) as? ListingCell
        cell?.name.text = data[indexPath.row].login
        cell?.img.sd_setImage(with: URL(string: data[indexPath.row].avatar_url ?? ""), placeholderImage: UIImage(named: "placeholder"))
        return cell ?? UITableViewCell()
    }
    
    
     // MARK : Selection of the cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserDetailVC") as? UserDetailVC{
        vc.searchUser = data[indexPath.row].login ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
     // MARK : Use For animation,when scroll the cell
     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(
            withDuration: 0.5,
            delay: 0.09,
            animations: {
                cell.alpha = 1
        })
    }
}


 // MARK : To create the data model for api request keys
class DataModel : Codable {
    let login : String?
    let avatar_url : String?
    let name : String?
    let location : String?
    let followers : Int?
    let following : Int?
    let public_repos : Int?
    let public_gists : Int?
    let updated_at : String?
    let followers_url : String?
    let items:[DataModel]?
    let total_count:Int?
    let html_url : String?
}

 // MARK : Enum for Main url
enum APIUrl:String{
    case MainUrl = "https://api.github.com/"
}
