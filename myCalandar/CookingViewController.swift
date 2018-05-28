//
//  CookingViewController.swift
//  Charts
//
//  Created by HankTseng on 2017/10/18.
//

import UIKit

class CookingViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func awakeFromNib() {
        super.awakeFromNib()
        //ESTabBar用的
        self.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(), title: "Cooking", image: UIImage(named: "Genie-100"), selectedImage: UIImage(named: "Genie Filled-100"))
        //ESTabBar用的
    }

}
