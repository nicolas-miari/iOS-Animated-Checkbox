//
//  GalleryViewController.swift
//  AnimatedCheckbox
//
//  Created by Nicolás Miari on 2018/12/12.
//  Copyright © 2018 Nicolás Miari. All rights reserved.
//

import UIKit

class GalleryViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //self.view.tintColor = UIColor(red: 255.0/255.0, green: 204.0/255.0, blue: 0, alpha: 1)
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
