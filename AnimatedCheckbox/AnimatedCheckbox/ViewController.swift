//
//  ViewController.swift
//  AnimatedCheckbox
//
//  Created by Nicolás Miari on 2018/12/11.
//  Copyright © 2018 Nicolás Miari. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private(set) weak var dummyCheckbox: Checkbox!

    @IBOutlet private(set) weak var enableDummyCheckbox: Checkbox!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        enableDummyCheckbox.isSelected = true
    }

    @IBAction func checkboxChanged(_ sender: Any) {
        dummyCheckbox.isEnabled = enableDummyCheckbox.isSelected
    }
}

