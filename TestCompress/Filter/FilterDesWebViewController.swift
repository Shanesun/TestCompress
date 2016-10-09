//
//  FilterDesWebViewController.swift
//  TestCompress
//
//  Created by Shane on 2016/10/8.
//  Copyright © 2016年 Shane. All rights reserved.
//

import UIKit

class FilterDesWebViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    var urlString : String!
    
    init(url:String) {
        super.init(nibName:nil, bundle:nil)
        urlString = url
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() { 
        webView.loadRequest(URLRequest.init(url: URL.init(string: urlString)!))
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
    }
}
