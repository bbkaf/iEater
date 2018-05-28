//
//  foodItemCell.swift
//  myCalandar
//
//  Created by 華宇 on 2016/12/19.
//  Copyright © 2016年 華宇. All rights reserved.
//

import UIKit


class foodItemCell: UITableViewCell {

    var buttonCreated = 0
    
    var button: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if buttonCreated == 0 {
            
            
            button = UIButton(frame: CGRect(x: contentView.bounds.minX, y: contentView.bounds.minY, width: contentView.bounds.width, height: contentView.bounds.height))
            
            button.backgroundColor = UIColor.blue
//            button.setTitle("", for: .normal)
            button.layer.cornerRadius = 5
            button.clipsToBounds = true
//            button.addTarget(self, action: #selector(foodSelected), for: .touchUpInside) // 點擊button的手勢與要做的事
            contentView.addSubview(button)
            buttonCreated = 1
            print("button add to contentView")
            
        }
    
    }
    
   

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
