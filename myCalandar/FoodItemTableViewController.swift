//
//  FoodItemTableViewController.swift
//  myCalandar
//
//  Created by 華宇 on 2016/12/19.
//  Copyright © 2016年 華宇. All rights reserved.
//

import UIKit

protocol DelegateDidDismissPopover: class { //protocol STEP 1
    func upDataUI(sender: FoodItemTableViewController)
}
class FoodItemTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate  {
    
    let foodItemArray = NSArray(contentsOfFile: pathOffoodItemArray!)! as! [[String]]
    
    weak var delegateOfDidDismissPopover: DelegateDidDismissPopover? //protocol STEP 2
    
    //search bar ..... 1   (1~8)
    let searchController = UISearchController(searchResultsController: nil)
    
    //search bar .....3 建一個過濾過後的array
    var filterFoods = [[String]]()
    
    //search bar .....4 過濾方法
    func filterContentForSearchText(searchText: String, scope: String = "ALL"){
        
        //        filterFoods = foodItemArray.filter({ (foods: String) -> Bool in
        //            return foods.lowercased().contains(searchText.lowercased())
        //        })
        
        filterFoods = []
        
        for i in 0...foodItemArray.count - 1 {
            if foodItemArray[i][0].lowercased().contains(searchText.lowercased()) || foodItemArray[i][1].lowercased().contains(searchText.lowercased()) || foodItemArray[i][2].lowercased().contains(searchText.lowercased()) {
                filterFoods.append(foodItemArray[i])
            }
        }
        
        self.tableView.reloadData()
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedFood = "🔍"
        
        //search bar .....2
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false //等等試試改false會怎樣 用true時搜尋時下面會變灰 而且點下面無法觸發didSelectRowAtIndexPath ; 用false雖然搜尋時下面不會變黑 但是可以觸發didSelectRowAtIndexPath (結論 必須用false)
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        self.tableView.layer.cornerRadius = 13.0
        self.tableView.layer.borderColor = UIColor.orange.cgColor
        self.tableView.layer.borderWidth = 2.0
        self.tableView.clipsToBounds = true
        
        
    }
    
    deinit {
        print("deinit FoodItemTableViewController")
    }
    
    // MARK: - popover視窗大小
    override func viewWillLayoutSubviews() {
        self.preferredContentSize = CGSize(width: presentingViewController!.view.bounds.width * 0.7, height: presentingViewController!.view.bounds.height * 0.8)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //search bar .....6 確定使用正確的array
        if searchController.isActive && searchController.searchBar.text != "" {
            return filterFoods.count
        }else{
            return foodItemArray.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodItemCell", for: indexPath) as! FoodItemWithNickNameTableViewCell
        
        //search bar .....7 確定使用正確的array
        if searchController.isActive && searchController.searchBar.text != "" && filterFoods.count != 0 {
            //cell.textLabel?.text = filterFoods[indexPath.row]
            if filterFoods[indexPath.row][0] != "" {
                cell.label1.text = filterFoods[indexPath.row][0]
            }else{
                cell.label1.text = "-"
            }
            if filterFoods[indexPath.row][1] != "" {
                cell.label2.text = filterFoods[indexPath.row][1]
            }else{
                cell.label2.text = "-"
            }
            if filterFoods[indexPath.row][2] != "" {
                cell.label3.text = filterFoods[indexPath.row][2]
            }else{
                cell.label3.text = "-"
            }
            
        }else{
            //cell.textLabel?.text = foodItemArray[indexPath.row]
            if foodItemArray[indexPath.row][0] != "" {
                cell.label1.text = foodItemArray[indexPath.row][0]
            }else{
                cell.label1.text = "-"
            }
            if foodItemArray[indexPath.row][1] != "" {
                cell.label2.text = foodItemArray[indexPath.row][1]
            }else{
                cell.label2.text = "-"
            }
            if foodItemArray[indexPath.row][2] != "" {
                cell.label3.text = foodItemArray[indexPath.row][2]
            }else{
                cell.label3.text = "-"
            }
        }
        
        //以下偶數列背景區分
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.clear
            
        } else {
            cell.backgroundColor = UIColor.orange.withAlphaComponent(0.05)
        }
        //以上偶數列背景區分
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        //search bar .....8 確定使用正確的array
        if searchController.isActive && searchController.searchBar.text != "" {
            selectedFood = filterFoods[indexPath.row][0]
        }else{
            selectedFood = foodItemArray[indexPath.row][0]
        }
        if self.searchController.isActive {
            self.searchController.dismiss(animated: true, completion: nil)
        }
        self.dismiss(animated: true) {
            //芷珊建議要放在completion裡面(現在這樣是改完的)，等他動畫做完再執行delegate
            self.delegateOfDidDismissPopover?.upDataUI(sender: self) // protocol STEP 3
        }
        
        
        print(selectedFood)
        
    }
    
    
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}



// search bar .....5
extension FoodItemTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

















