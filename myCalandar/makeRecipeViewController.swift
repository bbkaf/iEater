//
//  makeRecipeViewController.swift
//  myCalandar
//
//  Created by 華宇 on 2017/3/7.
//  Copyright © 2017年 華宇. All rights reserved.
//

import UIKit
import CoreData
import Charts    // bar chart  .....1

class makeRecipeViewController: iEATViewController {

    var theIndexPathRaw = 0
    var singleFoodOriginNuitrition: [Double] = []
    
    @IBOutlet weak var recipeNameTextField: UITextField!
    
    @IBAction func backButtonClick(_ sender: UIButton) {
        
        newEntryUpdateOrInsertToCoreData(saveType: "all")
 
        self.barChartView.removeFromSuperview()
        self.photoCollectionView.removeFromSuperview()
        self.foodCollectionView.removeFromSuperview()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //這條是把文字窗關掉，以後新建的textfield 點右側拉did and exit黏到下面這坨
    @IBAction func dismiss(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func recipeNameTextField(_ sender: UITextField) {
        recipeName = sender.text ?? "no name"
    }
    
    
    override func eatFoodButtonClick(_ sender: UIButton) {
        
        if searchFoodButton.currentTitle != "🔍" && searchFoodButton.currentTitle != "食材" {
            
            //append food & food amount & nuitrition Array
            recipeFoodArray.append(self.searchFoodButton.currentTitle!)
            recipeFoodAmountArray.append("\(Int(self.amountSlider.value))")
            
            for i in 0...(recipeNuitritionArray.count - 1){
                let x = recipeNuitritionArray[i]
                print(x)
                
                let y = x + Double(NSString(format: "%.2f", singleFoodNuitrition[i]) as String)!
                print(y)
                
                recipeNuitritionArray[i] = y
            }
            //這邊輸出還是小數點好多位???
            print(recipeNuitritionArray)
            
            
            //reload collectionView
            foodCollectionView.reloadData()
            
            //updata coreData
            //newEntryUpdateOrInsertToCoreData(saveType: "notPhoto")
            
            //searchFoodButton currentTitle = 🔍
            searchFoodButton.setTitle("🔍", for: .normal)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        //loadEntryFromCoreData()
        
        //        diaryTextView.isEditable = false
        //        diaryTextView.isSelectable = false
        
        functionPage = "foodPage"
        
        if segueFromCalendar == 1 {
            
            diaryEntryMode()
            
        }else{
            
            foodEntryMode()
        }
        
        segueFromCalendar = 0
        
        barChartView.noDataText = "點擊🔍 選擇食物種類"
        barChartView.noDataTextColor = UIColor.gray
        
        //選擇男性或女性的dailyNeeds
        whitIDaillyNeed = nuitritionMaleDailyNeeds
        recipeNameTextField.text = recipeName
        diaryTextView.text = recipeDiary
        showYearMonthDay()
        
        print("makeRecipe VC ViewWillAppear")
    }
    
    
    override func showYearMonthDay() {
        print("do nothing")
    }
    
    override func showTodayFood(){
        //準備放入 編輯 與 顯示今日攝取總量
        
        searchFoodButton.setTitle("🔍", for: .normal)
        
        mode = "todayTotalFood"
        
        searchFoodButton.setTitle("食材", for: .normal)
        
        var totalEatGram = 0.0
        
        if recipeFoodArray.count != 0 {
            for i in 0...recipeFoodAmountArray.count - 1 {
                let x = Double(recipeFoodAmountArray[i])!
                totalEatGram += x
            }
        }else{
            totalEatGram = 0
        }
        
        eatFoodButton.setTitle("\(Int(totalEatGram)) 克", for: .normal)
        
        showFoodInBarChart(mode: mode, page: page)
        
    }
    
    override func showFoodInBarChart(mode: String, page:Int){
        
        var foodToAnalyse = ""
        var foodAmount:Double = 0.0
        
        if mode == "selectedFood" {
            foodToAnalyse = selectedFood
            foodAmount = Double(amountSlider.value)
        }
        
        if mode == "historyFood" {
            foodToAnalyse = historyFood
            foodAmount = Double(historyAmount)!
        }
        
        if mode == "todayTotalFood"{
            
            switch page {
            case 1:
                
                barChartX = ["熱量","蛋白","醣分","纖維","TC","脂肪","(S)","(M)","(P)","ω3","ω6"]
                nuitsSold = [recipeNuitritionArray[0],recipeNuitritionArray[1],recipeNuitritionArray[2],recipeNuitritionArray[3],recipeNuitritionArray[4],recipeNuitritionArray[5],recipeNuitritionArray[6],recipeNuitritionArray[7],recipeNuitritionArray[8],recipeNuitritionArray[26],recipeNuitritionArray[27]]
                
                
            case 2:
                
                barChartX = ["鈉","鉀","鈣","鎂","鐵","鋅","磷","銅"]
                nuitsSold = [recipeNuitritionArray[9],recipeNuitritionArray[10],recipeNuitritionArray[11],recipeNuitritionArray[12],recipeNuitritionArray[13],recipeNuitritionArray[14],recipeNuitritionArray[15],recipeNuitritionArray[16]]
                
            default:
                
                barChartX = ["A","E","B1","B2","B3","B6","B9","B12","C"]
                nuitsSold = [recipeNuitritionArray[17],recipeNuitritionArray[18],recipeNuitritionArray[19],recipeNuitritionArray[20],recipeNuitritionArray[21],recipeNuitritionArray[22],recipeNuitritionArray[23],recipeNuitritionArray[24],recipeNuitritionArray[25]]
                
            }
            
            setChart(dataPoints: barChartX, values: nuitsSold)
            
        }else{
            
            if self.searchFoodButton.currentTitle != "🔍" || mode == "historyFood" {
                
                let 熱量 = (Double(fooodNutritionDictionary["\(foodToAnalyse)修正熱量-成分值(kcal)"] as String!)! * foodAmount / whitIDaillyNeed["熱量"]!)
                let 蛋白質 = (Double(fooodNutritionDictionary["\(foodToAnalyse)粗蛋白-成分值(g)"] as String!)! * foodAmount / whitIDaillyNeed["蛋白質"]!)
                let 醣分 = (Double(fooodNutritionDictionary["\(foodToAnalyse)總碳水化合物-成分值(g)"] as String!)!  * foodAmount / whitIDaillyNeed["醣分"]!)
                let 脂肪 = (Double(fooodNutritionDictionary["\(foodToAnalyse)粗脂肪-成分值(g)"] as String!)!  * foodAmount / whitIDaillyNeed["脂肪"]!)
                let 膳食纖維 = (Double(fooodNutritionDictionary["\(foodToAnalyse)膳食纖維-成分值(g)"] as String!)!  * foodAmount / whitIDaillyNeed["膳食纖維"]!)
                let 飽和脂肪酸 = (Double(fooodNutritionDictionary["\(foodToAnalyse)脂肪酸S總量-成分值(mg)"] as String!)!  * foodAmount / whitIDaillyNeed["熱量"]! )
                let 單元不飽和脂肪酸 = (Double(fooodNutritionDictionary["\(foodToAnalyse)脂肪酸M總量-成分值(mg)"] as String!)!  * foodAmount / whitIDaillyNeed["熱量"]!)
                let 多元不飽和脂肪酸 = (Double(fooodNutritionDictionary["\(foodToAnalyse)脂肪酸P總量-成分值(mg)"] as String!)!  * foodAmount / whitIDaillyNeed["熱量"]!)
                let omega3 = (Double(fooodNutritionDictionary["\(foodToAnalyse)omega3"] as String!)!  * foodAmount / whitIDaillyNeed["熱量"]!)
                let omega6 = (Double(fooodNutritionDictionary["\(foodToAnalyse)omega6"] as String!)!  * foodAmount / whitIDaillyNeed["熱量"]!)
                
                //CoreData不存Ratio 存絕對數值
                var SRatio = 0.0
                var MRatio = 0.0
                var PRatio = 0.0
                if 飽和脂肪酸 != 0 && 飽和脂肪酸 != 0 && 飽和脂肪酸 != 0 {
                    SRatio = (飽和脂肪酸 / (飽和脂肪酸 + 單元不飽和脂肪酸 + 多元不飽和脂肪酸)) * 脂肪
                    MRatio = (單元不飽和脂肪酸 / (飽和脂肪酸 + 單元不飽和脂肪酸 + 多元不飽和脂肪酸)) * 脂肪
                    PRatio = (多元不飽和脂肪酸 / (飽和脂肪酸 + 單元不飽和脂肪酸 + 多元不飽和脂肪酸)) * 脂肪
                }
                
                var omega3Ratio = 0.0
                var omega6Ratio = 0.0
                if omega3 != 0 || omega6 != 0 {
                    omega3Ratio = (omega3 / (omega3 + omega6)) * PRatio
                    omega6Ratio = (omega6 / (omega3 + omega6)) * PRatio
                }
                
                let 膽固醇 = (Double(fooodNutritionDictionary["\(foodToAnalyse)膽固醇-成分值(mg)"] as String!)!  * foodAmount / whitIDaillyNeed["膽固醇"]!)
                
                let Na = (Double(fooodNutritionDictionary["\(foodToAnalyse)鈉-成分值(mg)"] as String!)!  * foodAmount / whitIDaillyNeed["Na"]!)
                let K = (Double(fooodNutritionDictionary["\(foodToAnalyse)鉀-成分值(mg)"] as String!)!  * foodAmount / whitIDaillyNeed["K"]!)
                let Ca = (Double(fooodNutritionDictionary["\(foodToAnalyse)鈣-成分值(mg)"] as String!)!  * foodAmount / whitIDaillyNeed["Ca"]!)
                let Mg = (Double(fooodNutritionDictionary["\(foodToAnalyse)鎂-成分值(mg)"] as String!)!  * foodAmount / whitIDaillyNeed["Mg"]!)
                let Fe = (Double(fooodNutritionDictionary["\(foodToAnalyse)鐵-成分值(mg)"] as String!)!  * foodAmount / whitIDaillyNeed["Fe"]!)
                let Zn = (Double(fooodNutritionDictionary["\(foodToAnalyse)鋅-成分值(mg)"] as String!)!  * foodAmount / whitIDaillyNeed["Zn"]!)
                let P = (Double(fooodNutritionDictionary["\(foodToAnalyse)磷-成分值(mg)"] as String!)!  * foodAmount / whitIDaillyNeed["P"]!)
                let Cu = (Double(fooodNutritionDictionary["\(foodToAnalyse)銅-成分值(ug)"] as String!)!  * foodAmount / whitIDaillyNeed["Cu"]!)
                
                let A = Double(fooodNutritionDictionary["\(foodToAnalyse)維生素A效力(1)-成分值(I.U.)"] as String!)! * foodAmount / whitIDaillyNeed["A"]!
                let E = Double(fooodNutritionDictionary["\(foodToAnalyse)維生素E總量-成分值(mg)"] as String!)! * foodAmount / whitIDaillyNeed["E"]!
                let B1 = Double(fooodNutritionDictionary["\(foodToAnalyse)維生素B1-成分值(mg)"] as String!)! * foodAmount / whitIDaillyNeed["B1"]!
                let B2 = Double(fooodNutritionDictionary["\(foodToAnalyse)維生素B2-成分值(mg)"] as String!)! * foodAmount / whitIDaillyNeed["B2"]!
                let B3 = Double(fooodNutritionDictionary["\(foodToAnalyse)菸鹼素-成分值(mg)"] as String!)! * foodAmount / whitIDaillyNeed["B3"]!
                let B6 = Double(fooodNutritionDictionary["\(foodToAnalyse)維生素B6-成分值(mg)"] as String!)! * foodAmount / whitIDaillyNeed["B6"]!
                let B9 = Double(fooodNutritionDictionary["\(foodToAnalyse)葉酸-成分值(ug)"] as String!)! * foodAmount / whitIDaillyNeed["B9"]!
                let B12 = Double(fooodNutritionDictionary["\(foodToAnalyse)維生素B12-成分值(ug)"] as String!)! * foodAmount / whitIDaillyNeed["B12"]!
                let C = Double(fooodNutritionDictionary["\(foodToAnalyse)維生素C-成分值(mg)"] as String!)! * foodAmount / whitIDaillyNeed["C"]!
                
                switch page {
                case 1:
                    
                    barChartX = ["熱量","蛋白","醣分","纖維","TC","脂肪","(S)","(M)","(P)","ω3","ω6"]
                    nuitsSold = [熱量,蛋白質,醣分,膳食纖維,膽固醇,脂肪,SRatio,MRatio,PRatio,omega3Ratio,omega6Ratio]
                    
                case 2:
                    
                    barChartX = ["鈉","鉀","鈣","鎂","鐵","鋅","磷","銅"]
                    nuitsSold = [Na,K,Ca,Mg,Fe,Zn,P,Cu]
                    
                default:
                    
                    barChartX = ["A","E","B1","B2","B3","B6","B9","B12","C"]
                    nuitsSold = [A,E,B1,B2,B3,B6,B9,B12,C]
                    
                }
                
                singleFoodNuitrition = [熱量,蛋白質,醣分,膳食纖維,膽固醇,脂肪,SRatio,MRatio,PRatio,Na,K,Ca,Mg,Fe,Zn,P,Cu,A,E,B1,B2,B3,B6,B9,B12,C,omega3Ratio,omega6Ratio]
                
//                singleFoodOriginNuitrition = [熱量,蛋白質,醣分,膳食纖維,膽固醇,脂肪,SRatio,MRatio,PRatio,Na,K,Ca,Mg,Fe,Zn,P,Cu,A,E,B1,B2,B3,B6,B9,B12,C,omega3Ratio,omega6Ratio]
                
                setChart(dataPoints: barChartX, values: nuitsSold)
            }
        }
    }
    
    override func showDiary(){
        
        diaryTextView.text =  recipeDiary
    }
    
    override func newEntryUpdateOrInsertToCoreData(saveType: String){
        
        if makeNewRecipeOrModify != "new" {
            //which mean update(replace) entry to coreData
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let context = appDelegate.persistentContainer.viewContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UsersRecipes")
            
            request.returnsObjectsAsFaults = false
            
            do
            {
                if let results = try context.fetch(request) as? [NSManagedObject] {
                    
                    if results.count != 0{
                        
                        let result = results[theIndexPathRaw]
                        
                        let foodArrayData = NSKeyedArchiver.archivedData(withRootObject: recipeFoodArray) as NSData
                        result.setValue(foodArrayData, forKey: "recipeFoodArray")
                        
                        let photoArrayData = NSKeyedArchiver.archivedData(withRootObject: recipePhotoArray) as NSData
                        result.setValue(photoArrayData, forKey: "recipePhotoArray")
                        print("updated recipePhoto")
                        
                        
                        let foodAmountArrayData = NSKeyedArchiver.archivedData(withRootObject: recipeFoodAmountArray) as NSData
                        result.setValue(foodAmountArrayData, forKey: "recipeFoodAmountArray")
                        
                        let nuitritionArrayData = NSKeyedArchiver.archivedData(withRootObject: recipeNuitritionArray) as NSData
                        result.setValue(nuitritionArrayData, forKey: "recipeNuitritionArray")
                        
                        let diaryData = NSKeyedArchiver.archivedData(withRootObject: recipeDiary) as NSData
                        result.setValue(diaryData, forKey: "recipeDiary")
                        
                        let nameData = NSKeyedArchiver.archivedData(withRootObject: recipeName) as NSData
                        result.setValue(nameData, forKey: "recipeName")
                        
                        
                        try context.save()
                        print("updated")
                    }
                }
            }
                
            catch
            {
                
            }
            
        }else{
            
            // append orderArray & insert new entry to coredata (add new Entry to coreData)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let context = appDelegate.persistentContainer.viewContext
            
            let newUser = NSEntityDescription.insertNewObject(forEntityName: "UsersRecipes", into: context)
            
            let foodArrayData = NSKeyedArchiver.archivedData(withRootObject: recipeFoodArray) as NSData
            newUser.setValue(foodArrayData, forKey: "recipeFoodArray")
            
            //            if saveType == "photo" {
            let photoArrayData = NSKeyedArchiver.archivedData(withRootObject: recipePhotoArray) as NSData
            newUser.setValue(photoArrayData, forKey: "recipePhotoArray")
            print("saved photo")
            //            }
            
            let foodAmountArrayData = NSKeyedArchiver.archivedData(withRootObject: recipeFoodAmountArray) as NSData
            newUser.setValue(foodAmountArrayData, forKey: "recipeFoodAmountArray")
            
            let nuitritionArrayData = NSKeyedArchiver.archivedData(withRootObject: recipeNuitritionArray) as NSData
            newUser.setValue(nuitritionArrayData, forKey: "recipeNuitritionArray")
            
            let diaryData = NSKeyedArchiver.archivedData(withRootObject: recipeDiary) as NSData
            newUser.setValue(diaryData, forKey: "recipeDiary")
            
            let nameData = NSKeyedArchiver.archivedData(withRootObject: recipeName) as NSData
            newUser.setValue(nameData, forKey: "recipeName")
            
            do
            {
                try context.save()
                print("saved")
            }
            catch
            {
                
            }
            
        }
        
    }
    
    override func loadEntryFromCoreData(){
        
        if makeNewRecipeOrModify == "new" {
            
            recipeFoodArray = []
            recipeDiary = ""
            recipeName = ""
            recipeFoodAmountArray = []
            //step = ""
            recipeNuitritionArray = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
            recipePhotoArray = []
            
        }else{
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let context = appDelegate.persistentContainer.viewContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UsersRecipes")
            
            request.returnsObjectsAsFaults = false
            
            do
            {
                let results = try context.fetch(request)
                
                if results.count != 0 {
                    print("coreData UsersRecipes 裡有\(results.count)組資料")
                    
                    
                    let result = results[theIndexPathRaw] as! NSManagedObject
                    
                    let foodArrayData = result.value(forKey: "recipeFoodArray") as! NSData
                    let foodArrayUnarchiveObject = NSKeyedUnarchiver.unarchiveObject(with: foodArrayData as Data)
                    recipeFoodArray = foodArrayUnarchiveObject as! [String]
                    
                    let photoArrayData = result.value(forKey: "recipePhotoArray") as! NSData
                    let photoArrayUnarchiveObject = NSKeyedUnarchiver.unarchiveObject(with: photoArrayData as Data)
                    recipePhotoArray = photoArrayUnarchiveObject as! [UIImage]
                    
                    let foodAmountArrayData = result.value(forKey: "recipeFoodAmountArray") as! NSData
                    let foodAmountArrayUnarchiveObject = NSKeyedUnarchiver.unarchiveObject(with: foodAmountArrayData as Data)
                    recipeFoodAmountArray = foodAmountArrayUnarchiveObject as! [String]
                    
                    let nuitritionArrayData = result.value(forKey: "recipeNuitritionArray") as! NSData
                    let nuitritionArrayUnarchiveObject = NSKeyedUnarchiver.unarchiveObject(with: nuitritionArrayData as Data)
                    var oldNuitritionArray = nuitritionArrayUnarchiveObject as! [Double]
                    
                    //新增omega3.6時 整理array長度用
                    if oldNuitritionArray.count < 28 {
                        oldNuitritionArray.append(0.0)
                        oldNuitritionArray.append(0.0)
                    }
                    if oldNuitritionArray.count > 28 {
                        oldNuitritionArray.removeLast()
                        oldNuitritionArray.removeLast()
                    }
                    recipeNuitritionArray = oldNuitritionArray
                    
                    let diaryData = result.value(forKey: "recipeDiary") as! NSData
                    let diaryUnarchiveObject = NSKeyedUnarchiver.unarchiveObject(with: diaryData as Data)
                    recipeDiary = diaryUnarchiveObject as! String
  
                    let nameData = result.value(forKey: "recipeName") as! NSData
                    let nameUnarchiveObject = NSKeyedUnarchiver.unarchiveObject(with: nameData as Data)
                    recipeName = nameUnarchiveObject as! String
                }
            }
            catch
            {
            }
        }
    }
    
    override func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                
                //隨keyboard移動textView 下面程式碼為keyboard消失時 步驟1的constrin要回到原本值(99.0) ...5
                self.keyboardHeightLayoutConstraint?.constant = 99.0
                
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
        
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.foodCollectionView {
            
            return 1
            
        }else{
            
            return 1
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.foodCollectionView {
            
            return recipeFoodArray.count
            
        }else{
            
            return recipePhotoArray.count
            
        }
    }

    
    
    // populate the data of given cell
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if collectionView == self.foodCollectionView {
            
            let foodCell = cell as! foodCollectionViewCell
            foodCell.label.adjustsFontSizeToFitWidth = true
            foodCell.label.font = UIFont(name: "System", size: 8)
            foodCell.label.numberOfLines = 2
            foodCell.label.textAlignment = .center
            foodCell.label.text = "\(recipeFoodArray[indexPath.row])\n\(recipeFoodAmountArray[indexPath.row]) g"
            
        }else{
            
            let photoCell = cell as! photoCollectionViewCell
            photoCell.photoButton.setBackgroundImage(recipePhotoArray[indexPath.row], for: .normal)
            
            return
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView == self.photoCollectionView{
            
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            
            let totalCellWidth = collectionView.bounds.height * CGFloat(recipePhotoArray.count)
            
            let totalSpacingWidth = flowLayout.minimumLineSpacing * CGFloat(recipePhotoArray.count - 1)
            
            let leftInset = max(0, (self.photoCollectionView.bounds.width - CGFloat(totalCellWidth + totalSpacingWidth))) / 2
            
            let rightInset = leftInset
            
            return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
        }else{
            return UIEdgeInsetsMake(0,0,0,0)
        }
    }

    //點擊要做的事
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == foodCollectionView {
            
            mode = "selectedFood" //等於是拿掉historyMode的功能 改成類似歷史查詢 同時快速key in 資料
            
            print("change mode tp \(mode)  -- 等於是拿掉historyMode的功能 改成類似歷史查詢 同時快速key in 資料")
            
            historyFood = recipeFoodArray[indexPath.row]
            
            historyAmount = recipeFoodAmountArray[indexPath.row]
            
            selectedFood = historyFood
            
            searchFoodButton.setTitle(historyFood, for: .normal)
            
            eatFoodButton.setTitle("\(historyAmount) 克", for: .normal)
            
            amountSlider.setValue(Float(historyAmount)!, animated: true)
            
            showFoodInBarChart(mode: mode, page: page)
            
        }
        
        print(indexPath.row)
    }

    override func doneButtonAction(){
        self.diaryTextView.resignFirstResponder()
        //store new entry
        recipeDiary = diaryTextView.text
//        unLockButton.setTitle("🔒", for: .normal)
        //        diaryTextView.isEditable = false
        //        diaryTextView.isSelectable = false
        //newEntryUpdateOrInsertToCoreData(saveType: "not Photo")
        
    }

    override func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        let chosenImage = info[UIImagePickerControllerEditedImage] as! UIImage
        recipePhotoArray.append(chosenImage)
        
        // UIImagePickerControllerEditedImage -> 輸出編輯後的照片
        //UIImagePickerControllerLivePhoto -> 輸出livePhoto
        
        self.dismiss(animated: true, completion: nil)
        
        //newEntryUpdateOrInsertToCoreData(saveType: "photo")
        
        photoCollectionView.reloadData()
        
    }


    

}
