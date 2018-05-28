//
//  monthCollectionViewCell.swift
//  myCalandar
//
//  Created by 華宇 on 2016/12/8.
//  Copyright © 2016年 華宇. All rights reserved.
//

import UIKit

protocol monthCollectionViewCellDelegate { // protocol STEP 1
    func changeColorOfButton(forCell: monthCollectionViewCell)
    
}



protocol Test2Delegate:class {
    func testAgain(sender: monthCollectionViewCell)
}

class monthCollectionViewCell: UICollectionViewCell {
    
    var indexPath: IndexPath?
    
    var buttonCreated = 0
    
    var button: UIButton!
    
    var delegate: monthCollectionViewCellDelegate? = nil // protocol STEP 2
    
    weak var delegate2: Test2Delegate?
    
    override func awakeFromNib() {
        
        if buttonCreated == 0 {
        button = UIButton(frame: CGRect(x: (contentView.bounds.minX), y: (contentView.bounds.minY), width: contentView.bounds.width, height: contentView.bounds.height))
        button.backgroundColor = UIColor.clear
        button.setTitle("", for: .normal)
        button.layer.cornerRadius = contentView.bounds.width / 2
        button.clipsToBounds = false       
        button.addTarget(self, action: #selector(changeColor), for: .touchUpInside) // 點擊button的手勢與要做的事
        button.titleLabel?.lineBreakMode = NSLineBreakMode.byCharWrapping

        contentView.addSubview(button)
            buttonCreated = 1
            print("button add to monthCollectionViewCell")
        }
    
    }
    
    
    
    deinit {
        button.removeFromSuperview()
        print("deinit monthCollectionViewCell")
    }
    
    
    
    func changeColor(){
        if button.tag != 999999{
        print("changeColor")
        delegate?.changeColorOfButton(forCell: self) // protocol STEP 3
            
        delegate2?.testAgain(sender: self)
        }
    }
    
}
