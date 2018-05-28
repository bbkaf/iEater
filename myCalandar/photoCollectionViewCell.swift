//
//  photoCollectionViewCell.swift
//  myCalandar
//
//  Created by 華宇 on 2016/12/18.
//  Copyright © 2016年 華宇. All rights reserved.
//

import UIKit

class photoCollectionViewCell: UICollectionViewCell {
    
    var buttonCreated = 0
    
    var photoButton: UIButton!
    
    override func awakeFromNib() {
        
        if buttonCreated == 0 {
           photoButton = UIButton(frame: CGRect(x: (contentView.frame.minX), y: (contentView.frame.minY), width: contentView.bounds.width, height: contentView.bounds.height))
            
            photoButton.backgroundColor = UIColor.clear
            photoButton.layer.cornerRadius = contentView.bounds.width / 2
            photoButton.clipsToBounds = true
            photoButton.layer.borderWidth = 1.0
            photoButton.layer.borderColor = UIColor.orange.cgColor
            
            contentView.addSubview(photoButton)
            buttonCreated = 1
            print("photoButton add to contentView")
        }
        
    }
}
