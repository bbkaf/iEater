//
//  BatteryCellver2TableViewCell.swift
//  myCalandar
//
//  Created by HankTseng on 2017/9/18.
//  Copyright © 2017年 華宇. All rights reserved.
//

import UIKit

class BatteryCellver2TableViewCell: UITableViewCell {
    @IBOutlet weak var indexImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var circleImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    var dic: [String:String] = [:]
    @IBOutlet weak var indexImage: UIImageView!

    
    func showData() {
        self.nameLabel.text = dic["name"] ?? "hemptty"
        self.descriptionTextView.text = dic["description"] ?? "hemptty"
        self.descriptionTextView.sizeToFit()
        let x = Int(dic["amount"]!) ?? 50
        
        if x >= 80 {
            self.circleImage.image = UIImage(named: "battery-100")
            indexImage.backgroundColor = UIColor.getBatteryDarkGreenColor()
        } else if x >= 40{
            self.circleImage.image = UIImage(named: "battery-60")
            indexImage.backgroundColor = UIColor.getBatteryDarkYellowColor()
        } else {
            self.circleImage.image = UIImage(named: "battery-20")
            indexImage.backgroundColor = UIColor.getBatteryDarkRedColor()
            
        }
        
        indexImageConstraint = self.indexImageConstraint.setMultiplier(multiplier: 0.01)
        circleImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0)
        self.layoutIfNeeded()
        
        /*
        UIView.animate(withDuration: 2, options: [.curveEaseOut], animations: {
            self.indexImageConstraint = self.indexImageConstraint.setMultiplier(multiplier: CGFloat( min(Float(x) / 100.0, 1.0) ))
            self.layoutIfNeeded()
        })

        UIView.animate(withDuration: 1, delay: 0.2, options: [.curveEaseOut], animations: { 
            self.indexImageConstraint = self.indexImageConstraint.setMultiplier(multiplier: CGFloat( min(Float(x) / 100.0, 1.0) ))
        }) { (true) in
            self.indexImageConstraint = self.indexImageConstraint.setMultiplier(multiplier: CGFloat( min(0, 1.0) ))
        }
         */
        
        UIView.animate(withDuration: 1.5, delay: 0.2, options: [.curveEaseOut], animations: {
            self.indexImageConstraint = self.indexImageConstraint.setMultiplier(multiplier: CGFloat( min(Float(x) / 100.0, 1.0) ))
            self.layoutIfNeeded()
        }, completion: {(true) in
            //
        })
        
        if x < 40 {
            /*
        UIView.animate(withDuration: 0.2, delay: 1.5, options: [.curveEaseOut], animations: { 
            self.circleImage.layer.borderColor = UIColor.getBatteryDarkRedColor().cgColor
            self.layoutIfNeeded()
        }) { (true) in
            UIView.animate(withDuration: 0.2, delay: 0.1, options: [.curveEaseOut], animations: {
                self.circleImage.layer.borderColor = UIColor.getBatteryDarkRedColor().cgColor
                self.layoutIfNeeded()
            }) { (true) in
                //
            }
        }
        */
        
        UIView.animate(withDuration: 0.18, delay: 1, options: [], animations: {
            self.circleImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.08)
            self.layoutIfNeeded()
        }) { (true) in
            UIView.animate(withDuration: 0.16, delay: 0, options: [], animations: {
                self.circleImage.transform = CGAffineTransform(rotationAngle: -CGFloat.pi * 0.07)
                self.layoutIfNeeded()
            }) { (true) in
                UIView.animate(withDuration: 0.14, delay: 0, options: [], animations: {
                    self.circleImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.07)
                    self.layoutIfNeeded()
                }) { (true) in
                    UIView.animate(withDuration: 0.11, delay: 0, options: [], animations: {
                        self.circleImage.transform = CGAffineTransform(rotationAngle: -CGFloat.pi * 0.06)
                        self.layoutIfNeeded()
                    }) { (true) in
                        UIView.animate(withDuration: 0.08, delay: 0, options: [], animations: {
                            self.circleImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.06)
                            self.layoutIfNeeded()
                        }) { (true) in
                            UIView.animate(withDuration: 0.07, delay: 0, options: [], animations: {
                                self.circleImage.transform = CGAffineTransform(rotationAngle: -CGFloat.pi * 0.05)
                                self.layoutIfNeeded()
                            }) { (true) in
                                UIView.animate(withDuration: 0.06, delay: 0, options: [], animations: {
                                    self.circleImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.04)
                                    self.layoutIfNeeded()
                                }) { (true) in
                                    UIView.animate(withDuration: 0.04, delay: 0, options: [], animations: {
                                        self.circleImage.transform = CGAffineTransform(rotationAngle: -CGFloat.pi * 0.03)
                                        self.layoutIfNeeded()
                                    }) { (true) in
                                        UIView.animate(withDuration: 0.04, delay: 0, options: [], animations: {
                                            self.circleImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.02)
                                            self.layoutIfNeeded()
                                        }) { (true) in
                                            UIView.animate(withDuration: 0.03, delay: 0, options: [], animations: {
                                                self.circleImage.transform = CGAffineTransform(rotationAngle: -CGFloat.pi * 0.01)
                                                self.layoutIfNeeded()
                                            }) { (true) in
                                                UIView.animate(withDuration: 0.02, delay: 0, options: [], animations: {
                                                    self.circleImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.0)
                                                    self.layoutIfNeeded()
                                                }) { (true) in
                                                    //
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                    }
                }
            }
        }
        }
        
    }
 
    override func awakeFromNib() {
        super.awakeFromNib()
        circleImage.layer.borderColor = UIColor.lightGray.cgColor
        circleImage.layer.borderWidth = 1.5
        circleImage.layer.cornerRadius = circleImage.bounds.width / 2
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
