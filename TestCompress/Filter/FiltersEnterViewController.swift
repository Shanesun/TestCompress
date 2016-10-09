//
//  FiltersEnterViewController.swift
//  TestCompress
//
//  Created by Shane on 2016/10/8.
//  Copyright © 2016年 Shane. All rights reserved.
//

import UIKit

class FiltersEnterViewController: UITableViewController {
    
    
    let filterEntersArray = ["编辑滤镜", "滤镜预览", "滤镜说明"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SystemEnterCell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterEntersArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SystemEnterCell", for: indexPath)
        
        cell.textLabel?.text = filterEntersArray[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            
            let filterListVC = FilterListViewController()
            self.navigationController?.pushViewController(filterListVC, animated: true)
            break
            
        case 1:
            let photoFilterVC = PhotoFilterViewController()
            self.navigationController?.pushViewController(photoFilterVC, animated: true)
            break
        case 2:
            let filterListVC = FilterDesWebViewController.init(url: "https://developer.apple.com/library/prerelease/content/documentation/GraphicsImaging/Reference/CoreImageFilterReference/#//apple_ref/doc/uid/TP30000136-SW29")
            self.navigationController?.pushViewController(filterListVC, animated: true)
            break
        default: break
            
        }
    }
}
