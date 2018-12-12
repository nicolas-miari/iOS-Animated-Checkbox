//
//  ViewController.swift
//  AnimatedCheckbox
//
//  Created by Nicolás Miari on 2018/12/12.
//  Copyright © 2018 Nicolás Miari. All rights reserved.
//

import UIKit

class SuperellipseViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!

    var shapeLayer: CAShapeLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.yellow.cgColor
        shapeLayer.anchorPoint = CGPoint(x: 0, y: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        shapeLayer.bounds = containerView.bounds
        shapeLayer.path = UIBezierPath.superellipse(in: shapeLayer.bounds, cornerRadius: 100).cgPath
        containerView.layer.addSublayer(shapeLayer)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
