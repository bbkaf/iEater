//
//  RecipeCollectionViewCell.swift
//  myCalandar
//
//  Created by 華宇 on 2017/3/10.
//  Copyright © 2017年 華宇. All rights reserved.
//

import UIKit

class RecipeCollectionViewCell: UICollectionViewCell {
    
    var buttonCreated = 0
    
    var label: UILabel!
    
    var image: UIImageView!
    
    override func awakeFromNib() {
        
        if buttonCreated == 0 {
            label = UILabel(frame: CGRect(x: (contentView.frame.minX), y: (contentView.frame.maxY - contentView.bounds.height / 5), width: contentView.bounds.width, height: contentView.bounds.height / 5))
            label.backgroundColor = UIColor.clear
            label.text = ""
            label.layer.cornerRadius = 0
            label.clipsToBounds = true
            label.textAlignment = .center
            label.textColor = UIColor.white
            label.font = UIFont.boldSystemFont(ofSize: 12.0)
            
            image = UIImageView(frame: CGRect(x: (contentView.frame.minX), y: (contentView.frame.minY), width: contentView.bounds.width, height: contentView.bounds.height))
            image.backgroundColor = UIColor.clear
            image.layer.cornerRadius = 5
            image.clipsToBounds = true
            
            contentView.addSubview(image)
            
            contentView.addSubview(label)
            
            buttonCreated = 1
            print("button add to contentView")
        }
    }
    
}
