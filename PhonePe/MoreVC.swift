//
//  MoreVC.swift
//  PhonePe
//
//  Created by Harshit on 11/07/19.
//  Copyright © 2019 Harshit. All rights reserved.
//

import UIKit

class MoreVC: UIViewController {

    // MARK:Outlets
    @IBOutlet weak var webView: UIWebView!
    
    // MARK:Variables
    var url = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load url into the web view to see the additional user info
        webView.loadRequest(NSURLRequest(url: NSURL(string: url)! as URL) as URLRequest)
    }
}
