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
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
