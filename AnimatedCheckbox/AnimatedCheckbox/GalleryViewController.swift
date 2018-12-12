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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
