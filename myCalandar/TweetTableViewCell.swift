//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by 華宇 on 2017/5/12.
//  Copyright © 2017年 華宇. All rights reserved.
//

import UIKit
//import Twitter

class TweetTableViewCell: UITableViewCell
{
    @IBOutlet weak var tweetProfileImageView: UIImageView! {
        didSet {
            tweetProfileImageView.layer.cornerRadius = tweetProfileImageView.bounds.width / 2
            tweetProfileImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetUserLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    
//    var tweet: Twitter.Tweet? { didSet{ upDataUI() } }
    
//    private func upDataUI() {
//        tweetProfileImageView?.image = nil
//        tweetTextLabel?.text = tweet?.text
//        tweetUserLabel?.text = tweet?.user.description
//        if let profileImageURL = tweet?.user.profileImageURL {
//            // fetchData out of main Queue
//            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//                if let imageData = try? Data(contentsOf: profileImageURL), profileImageURL == self?.tweet?.user.profileImageURL //profileImageURL == self?.tweet?.user.profileImageURL 這行之重要，避免過時的fetch又重複去更新UI，沒有這行判斷圖片會快速疊出來(過時的fetch更新UI...)
//                {
//                    DispatchQueue.main.async {
//                        self?.tweetProfileImageView?.image = UIImage(data: imageData)
//                    }
//                }
//            }
//        } else {
//            tweetProfileImageView?.image = nil
//        }
//        
//        if let created = tweet?.created {
//            let formatter = DateFormatter()
//            if Date().timeIntervalSince(created) > 24*60*60 {
//                formatter.dateStyle = .short
//            } else {
//                formatter.timeStyle = .short
//            }
//            tweetCreatedLabel?.text = formatter.string(from: created)
//        } else {
//            tweetCreatedLabel?.text = nil
//        }
//    }
}
