//
//  BackTableVC.swift
//  myCalandar
//
//  Created by 華宇 on 2016/12/13.
//  Copyright © 2016年 華宇. All rights reserved.
//

import Foundation

class BackTableVC: UITableViewController {
    
    var TableArray = [String]()
    
    override func viewDidLoad() {
        TableArray = ["🍴iEAT", "📅calendar", "🍴recipe", "🔋battery", "⚙set", "💾backup"]
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: TableArray[indexPath.row], for: indexPath) as UITableViewCell
        
        cell.textLabel?.text = TableArray[indexPath.row]
        
    return cell
        
    }
    
// 這個prepareForSegue裡面提到用indexPath的方法 供以後參考
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        var DestVC = segue.destination as! ViewController
//        var indexPath: NSIndexPath = self.tableView.indexPathForSelectedRow! as NSIndexPath
//        
//    }
    
    
    
}
