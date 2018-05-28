//
//  BaseViewController.swift
//  
//
//  Created by HankTseng on 2017/9/20.
//

import UIKit

class BaseViewController: UIViewController {

    @IBOutlet weak var redGradientConstraintTopToSafeArea: NSLayoutConstraint!
    @IBOutlet weak var reGradientConstraintOfHeight: NSLayoutConstraint!
    @IBOutlet weak var titleConstraintToCenterOfGradient: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view. 
    }

    override func viewDidLayoutSubviews() {
        print("this is BaseVC viewDidLayoutSubviews statusBarFrame height = \(self.tabBarController?.tabBar.frame.height)")
        self.redGradientConstraintTopToSafeArea.constant = -UIApplication.shared.statusBarFrame.height
        if self.tabBarController?.tabBar.frame.height == 83 {
            self.titleConstraintToCenterOfGradient = self.titleConstraintToCenterOfGradient.setMultiplier(multiplier: 1.18)
            self.reGradientConstraintOfHeight.constant = 90
        }
    }

}
