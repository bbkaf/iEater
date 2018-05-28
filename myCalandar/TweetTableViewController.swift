//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by 華宇 on 2017/5/11.
//  Copyright © 2017年 華宇. All rights reserved.
//

import UIKit
//import Twitter

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
//    private var tweets = [Array<Twitter.Tweet>]() { //這是modal
//        didSet {
//            print(tweets)
//        }
//    }
    
        override func awakeFromNib() {
            super.awakeFromNib()
            //ESTabBar用的
            self.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(), title: "Twitter", image: UIImage(named: "Twitter-500"), selectedImage: UIImage(named: "Twitter Filled-500"))
            //ESTabBar用的
        }
    
//    var searchText: String? {
//        didSet{
//            tweets.removeAll()
//            tableView.reloadData()
//            searchForTweets()
//            //title = searchText
//            //searchTextField?.text = searchText
//            //searchTextField?.resignFirstResponder()
//        }
//    }
//    
//    private func twitterRequest() -> Twitter.Request? {
//        if let query = searchText, !query.isEmpty {
//            return Twitter.Request(search: query, count: 100)
//        }
//        return nil
//    }
//    
//    internal func insertTweets(_ newTweets: [Twitter.Tweet]) {
//        self.tweets.insert(newTweets, at: 0)
//        self.tableView.insertSections([0], with: .fade) //單純reload特定section比整個reloadData還要好，更有效率
//    }
//    
//    private var lastTwitterRequest: Twitter.Request?//解回來的東西是否是我搜尋的東西 ...1/3
//    private func searchForTweets() {
//        if let request = twitterRequest() {
//            lastTwitterRequest = request//解回來的東西是否是我搜尋的東西 ...2/3
//            request.fetchTweets{ [weak self] newTweets in //解memory cycle：再說一次用 [weal self] .... self?. 來解memory cycle 因為當fetch太久時，使用者已經按了back原先的TweetTableViewController已經out of heap，當原本這個fetch回來時必須給他self?讓他知道原本的self已經是nil，他就不會執行?後面的code(因為第一次的fetch已經不重要了)
//                DispatchQueue.main.async {
//                    if request == self?.lastTwitterRequest {//解回來的東西是否是我搜尋的東西 ...3/3
//                        //self?.tweets.insert(newTweets, at: 0)
//                        //self?.tableView.insertSections([0], with: .fade) //單純reload特定section比整個reloadData還要好，更有效率
//                        //以上兩行拉到新增方法拉到上面 , 因為要讓subclass override這兩條 所以獨立之
//                        self?.insertTweets(newTweets)
//                    }
//                }
//            }
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //iOS8以後有用autolayout調整tableView高度的方法
        tableView.estimatedRowHeight = 96
        tableView.rowHeight = UITableViewAutomaticDimension
        //        searchText = "房思"
        let redGradient = UIImage(named: "Red Gradient")
        let imageView = UIImageView(image: redGradient)
        imageView.frame = CGRect(x: 0, y: -20, width: self.view.frame.width, height: 70.0)
        self.navigationController?.navigationBar.addSubview(imageView)
        title = "Twitter"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white,
                                                                        NSFontAttributeName: UIFont.boldSystemFont(ofSize: 22)]
    }
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet{
            searchTextField.delegate = self
        }
    }
    
    @IBAction func searchTextFieldEditingChange(_ sender: UITextField) {
        //searchText = searchTextField.text
    }
    
    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField == searchTextField{
//            searchText = searchTextField.text
//        }
//        searchTextField.resignFirstResponder()
//        return true
//    }
    
    //MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        //return tweets.count
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return tweets[section].count
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tweet", for: indexPath)//告訴swift 我是用哪個prototype cell BY uniq "Identifier"
//        let tweet: Twitter.Tweet = tweets[indexPath.section][indexPath.row]
//        //        cell.textLabel?.text = "\(tweet.text)_\(tweet.created)"
//        //        cell.textLabel?.numberOfLines = 0
//        //        cell.detailTextLabel?.text = tweet.user.name
//        if let tweetCell = cell as? TweetTableViewCell {
//            tweetCell.tweet = tweet
//        }
        return cell
    }
}
