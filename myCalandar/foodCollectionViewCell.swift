//
//  foodCollectionViewCell.swift
//  myCalandar
//
//  Created by 華宇 on 2016/12/14.
//  Copyright © 2016年 華宇. All rights reserved.
//

import UIKit

class foodCollectionViewCell: UICollectionViewCell {
    
    var buttonCreated = 0
    
    var label: UILabel!
    
    override func awakeFromNib() {
        
        if buttonCreated == 0 {
            label = UILabel(frame: CGRect(x: (contentView.frame.minX), y: (contentView.frame.minY), width: contentView.bounds.width, height: contentView.bounds.height))
            label.backgroundColor = UIColor.clear
            label.text = ""
            label.font = UIFont(name: "System", size: 4)
            label.layer.cornerRadius = 0
            label.clipsToBounds = false
           
            contentView.addSubview(label)
            buttonCreated = 1
            print("button add to contentView")
        }
    }
}
