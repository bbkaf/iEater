//
//  backupViewController.swift
//  myCalandar
//
//  Created by 華宇 on 2017/1/12.
//  Copyright © 2017年 華宇. All rights reserved.
//

import UIKit
import CloudKit

class backupViewController: BaseViewController {
    
    @IBOutlet weak var viewInScrollView: UIView!
    @IBOutlet weak var descriptionTextViewConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var myScrollview: UIScrollView!
    @IBOutlet weak var weightSlider: UISlider!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var whatINeedNuiCollectionView: UICollectionView!
    @IBOutlet weak var breastButton: UIButton!
    @IBOutlet weak var pregnantButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var youngButton: UIButton!
    @IBOutlet weak var adultButton: UIButton!
    @IBOutlet weak var oldButton: UIButton!
    @IBOutlet weak var secretButton: UIButton!
    @IBOutlet weak var kidneyButton: UIButton!
    @IBOutlet weak var diabeteButton: UIButton!
    @IBOutlet weak var kindeyAndDiabeteButton: UIButton!
    @IBOutlet weak var detailSetButton: UIButton!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    fileprivate var startFromX = CGFloat(1)
    fileprivate var startDeceleratinX = CGFloat(1)
    fileprivate var movingSpeed = CGFloat(0.5)
    fileprivate var startIndexPath: NSIndexPath = NSIndexPath.init(item: 1000, section: 1)
    fileprivate var resetLock = Timer()
    
    let ieat = iEATViewController()
    @IBOutlet weak var littleSpinner: UIActivityIndicatorView!
    
    // 3 line
    @IBOutlet weak var Open: UIBarButtonItem!
    // 3 line
    
    @IBAction func threeLine(_ sender: UIButton) {
        revealViewController().revealToggle(self)
    }
    
    
    @IBAction func weightSliderAction(_ sender: UISlider) {
        weight = Double(sender.value)
        weightLabel.text = "WEIGHT\n\(Int(sender.value)) kg"
        makeMyDailyNeeds()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()   
        self.descriptionTextView.sizeToFit()
        self.viewInScrollView.sizeToFit()
    }
    
    
    @IBAction func setButtonClick(_ sender: UIButton) {
        
        if sender.currentTitle! == gender || sender.currentTitle! == age || (sender.currentTitle! == restrintion && sender.currentTitle! != "detailSet") {
            if sender.currentTitle! == gender {
                
            }else if sender.currentTitle! == age{
                
            }else{
                restrintion = "non"
            }
        }else{
            
            switch sender.currentTitle! {
            case "breast", "pregnant", "female", "male":
                gender = sender.currentTitle!
            case "young", "adult", "old", "secret":
                age = sender.currentTitle!
            case "kidney", "diabete", "kindeyAndDiabete":
                restrintion = sender.currentTitle!
            case "detailSet":
                restrintion = sender.currentTitle!
                whitIDaillyNeed = specificNeeds
            default:
                break
            }
        }
        setButtons()
        
        makeMyDailyNeeds()
        
    }
    
    @IBAction func backupButtonClick(_ sender: UIButton) {
        
        coreDataBackupToCloud()
        
    }
    
    @IBAction func restoreButtonClick(_ sender: UIButton) {
        
        coredataRestoreFromiCloud()
        
    }
    
    override func awakeFromNib() {
        //ESTabBar用的
        self.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(), title: "Set", image: UIImage(named: "Engineering-100"), selectedImage: UIImage(named: "Engineering Filled-100"))
        //ESTabBar用的
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        myScrollview.sizeToFit()
        
        backButton.layer.cornerRadius = self.backButton.bounds.width / 2
        //backButton.layer.borderWidth = 1.0
        //backButton.layer.borderColor = UIColor.orange.cgColor
        
        restoreButton.layer.cornerRadius = self.backButton.bounds.width / 2
        //restoreButton.layer.borderWidth = 1.0
        //restoreButton.layer.borderColor = UIColor.orange.cgColor
        
        weightLabel.text = "WEIGHT\n\(Int(weight)) kg"
        weightSlider.setValue(Float(weight), animated: true)
        //        // 3 lines
        //        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        //        // 3 lines    }
        
        //littleSpinner.isHidden = true
        
        self.resetLock = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.keepMovingCollectionView), userInfo: nil, repeats: true)
        RunLoop.current.add(self.resetLock, forMode: .commonModes)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        setButtons()
        
        if self.startFromX == CGFloat(1){
            self.startFromX = CGFloat((Double(70.0 + 2.0) * Double(nuitritionArray.count) * 500.0))
        }
    }
    
    func setButtons(){
        
        self.breastButton.setBackgroundImage(UIImage(named:"Breastfeeding-100") , for: .normal)
        self.pregnantButton.setBackgroundImage(UIImage(named:"Pregnant-100"), for: .normal)
        self.femaleButton.setBackgroundImage(UIImage(named:"Circled User Female -100"), for: .normal)
        self.maleButton.setBackgroundImage(UIImage(named:"Circled User Male-100"), for: .normal)
        self.youngButton.setBackgroundImage(UIImage(named:"Teenager Male-100"), for: .normal)
        self.adultButton.setBackgroundImage(UIImage(named:"Manager-100"), for: .normal)
        self.oldButton.setBackgroundImage(UIImage(named:"Elderly Person-100"), for: .normal)
        self.secretButton.setBackgroundImage(UIImage(named:"Desura-100"), for: .normal)
        self.kidneyButton.setBackgroundImage(UIImage(named:"Kidney-100"), for: .normal)
        self.diabeteButton.setBackgroundImage(UIImage(named:"Diabetes Monitor-100"), for: .normal)
        self.kindeyAndDiabeteButton.setBackgroundImage(UIImage(named:"Diabetes Monitor-100"), for: .normal)
        self.detailSetButton.setBackgroundImage(UIImage(named:"Reservation 2-100"), for: .normal)
        
        self.breastButton.alpha = 0.3
        self.pregnantButton.alpha = 0.3
        self.femaleButton.alpha = 0.3
        self.maleButton.alpha = 0.3
        self.youngButton.alpha = 0.3
        self.adultButton.alpha = 0.3
        self.oldButton.alpha = 0.3
        self.secretButton.alpha = 0.3
        self.kidneyButton.alpha = 0.3
        self.diabeteButton.alpha = 0.3
        self.kindeyAndDiabeteButton.alpha = 0.3
        self.detailSetButton.alpha = 0.3
        
        switch gender {
        case "breast":
            self.breastButton.setBackgroundImage(UIImage(named:"Breastfeeding Filled-100"), for: .normal)
            self.breastButton.alpha = 1.0
        case "pregnant":
            self.pregnantButton.setBackgroundImage(UIImage(named:"Pregnant Filled-100"), for: .normal)
            self.pregnantButton.alpha = 1.0
        case "female":
            self.femaleButton.setBackgroundImage(UIImage(named:"Circled User Female  Filled-100"), for: .normal)
            self.femaleButton.alpha = 1.0
        case "male":
            self.maleButton.setBackgroundImage(UIImage(named:"Circled User Male Filled-100"), for: .normal)
            self.maleButton.alpha = 1.0
        default:
            break
        }
        
        switch age {
        case "young":
            self.youngButton.setBackgroundImage(UIImage(named:"Teenager Male Filled-100"), for: .normal)
            self.youngButton.alpha = 1.0
        case "adult":
            self.adultButton.setBackgroundImage(UIImage(named:"Manager Filled-100"), for: .normal)
            self.adultButton.alpha = 1.0
        case "old":
            self.oldButton.setBackgroundImage(UIImage(named:"Elderly Person Filled-100"), for: .normal)
            self.oldButton.alpha = 1.0
        case "secret":
            self.secretButton.setBackgroundImage(UIImage(named:"Desura Filled-100"), for: .normal)
            self.secretButton.alpha = 1.0
        default:
            break
        }
        
        switch restrintion {
        case "kidney":
            self.kidneyButton.setBackgroundImage(UIImage(named:"Kidney Filled-100"), for: .normal)
            self.kidneyButton.alpha = 1.0
        case "diabete":
            self.diabeteButton.setBackgroundImage(UIImage(named:"Diabetes Monitor Filled-100"), for: .normal)
            self.diabeteButton.alpha = 1.0
        case "kindeyAndDiabete":
            self.kindeyAndDiabeteButton.setBackgroundImage(UIImage(named:"Diabetes Monitor Filled-100"), for: .normal)
            self.kindeyAndDiabeteButton.alpha = 1.0
        case "detailSet":
            self.detailSetButton.setBackgroundImage(UIImage(named:"Reservation 2 Filled-100"), for: .normal)
            self.detailSetButton.alpha = 1.0
        default:
            break
        }
    }
    
    func keepMovingCollectionView(){
        
        let frame: CGRect = CGRect(x : self.startFromX, y : 0, width: self.whatINeedNuiCollectionView.frame.width, height: self.whatINeedNuiCollectionView.frame.height)
        self.whatINeedNuiCollectionView.scrollRectToVisible(frame, animated: false)
        self.startFromX += self.movingSpeed
    }
    
    func makeMyDailyNeeds(){
        
        //性別修正 tier1
        switch gender {
        case "male":
            whitIDaillyNeed = ["熱量": Double(weight * 35.0), "醣分": Double(weight * 4.375), "蛋白質": Double(weight * 1.2), "脂肪": Double(weight * 0.97), "膳食纖維": Double(weight * 0.35), "A":5000, "B1":1.4, "B2":1.8, "B3":22, "B5":7, "B6":1.8, "B9":300, "B12":3, "C":100, "D":7, "E":12, "H":200, "vitK": Double(weight), "Ca":800, "P": Double(weight * 15.0), "K":2000, "Mg":360, "Na":3000, "Cl":200, "S":200, "Fe":10, "Cu":2500, "I":120, "Mn":3.6, "Zn":15, "Co":1, "Mo":28, "F":5, "Cr":33, "Se":50, "膽固醇":300, "飽和脂肪酸S": Double(weight * 0.292), "單元不飽和脂肪酸": Double(weight * 0.389), "多元不飽和脂肪酸": Double(weight * 0.292), "omega3": Double(weight * 0.073), "omega6": Double(weight * 0.219)]
        case "female":
            whitIDaillyNeed = ["熱量": Double(weight * 30.0), "醣分": Double(weight * 3.75), "蛋白質": Double(weight * 1.1), "脂肪": Double(weight * 0.83), "膳食纖維": Double(weight * 0.3), "A":4200, "B1":1.1, "B2":1.5, "B3":17, "B5":7, "B6":1.5, "B9":300, "B12":3, "C":100, "D":7.0, "E":10, "H":200, "vitK": Double(weight), "Ca":700, "P": Double(weight * 14.0), "K":2000, "Mg":315, "Na":3000, "Cl":200, "S":200, "Fe":15, "Cu":2500, "I":120, "Mn":4, "Zn":12, "Co":1, "Mo":28, "F":5, "Cr":23, "Se":50, "膽固醇":300, "飽和脂肪酸S": Double(weight * 0.25), "單元不飽和脂肪酸": Double(weight * 0.33), "多元不飽和脂肪酸": Double(weight * 0.25), "omega3": Double(weight * 0.0625), "omega6": Double(weight * 0.1875)]
        case "pregant":
            whitIDaillyNeed = ["熱量": Double(weight * 38.0), "醣分": Double(weight * 4.75), "蛋白質": Double(weight * 1.4), "脂肪": Double(weight * 1.06), "膳食纖維": Double(weight * 0.38), "A":4200, "B1":1.1, "B2":1.5, "B3":17, "B5":9, "B6":1.5, "B9":800, "B12":3, "C":100, "D":9.0, "E":10, "H":200, "vitK": Double(weight), "Ca":1300, "P": Double(weight * 14.0), "K":2000, "Mg":355, "Na":3000, "Cl":200, "S":200, "Fe":18, "Cu":2500, "I":120, "Mn":4, "Zn":15, "Co":1, "Mo":28, "F":5, "Cr":23, "Se":50, "膽固醇":300, "飽和脂肪酸S": Double(weight * 0.317), "單元不飽和脂肪酸": Double(weight * 0.422), "多元不飽和脂肪酸": Double(weight * 0.317), "omega3": Double(weight * 0.0792), "omega6": Double(weight * 0.2375)]
        case "breast":
            whitIDaillyNeed = ["熱量": Double(weight * 36.0), "醣分": Double(weight * 4.5), "蛋白質": Double(weight * 1.4), "脂肪": Double(weight), "膳食纖維": Double(weight * 0.36), "A":4200, "B1":1.1, "B2":1.5, "B3":17, "B5":9, "B6":1.5, "B9":600, "B12":3, "C":100, "D":9.0, "E":10, "H":200, "vitK": Double(weight), "Ca":1300, "P": Double(weight * 14), "K":2000, "Mg":355, "Na":3000, "Cl":200, "S":200, "Fe":45, "Cu":2500, "I":120, "Mn":4, "Zn":15, "Co":1, "Mo":28, "F":5, "Cr":23, "Se":50, "膽固醇":300, "飽和脂肪酸S": Double(weight * 0.3), "單元不飽和脂肪酸": Double(weight * 0.4), "多元不飽和脂肪酸": Double(weight * 0.3), "omega3": Double(weight * 0.075), "omega6": Double(weight * 0.225)]
        default:
            whitIDaillyNeed = ["熱量": Double(weight * 35.0), "醣分": Double(weight * 4.375), "蛋白質": Double(weight * 1.2), "脂肪": Double(weight * 0.97), "膳食纖維": Double(weight * 0.35), "A":5000, "B1":1.4, "B2":1.8, "B3":22, "B5":7, "B6":1.8, "B9":300, "B12":3, "C":100, "D":7, "E":12, "H":200, "vitK": Double(weight), "Ca":800, "P": Double(weight * 15.0), "K":2000, "Mg":360, "Na":3000, "Cl":200, "S":200, "Fe":10, "Cu":2500, "I":120, "Mn":3.6, "Zn":15, "Co":1, "Mo":28, "F":5, "Cr":33, "Se":50, "膽固醇":300, "飽和脂肪酸S": Double(weight * 0.292), "單元不飽和脂肪酸": Double(weight * 0.389), "多元不飽和脂肪酸": Double(weight * 0.292), "omega3": Double(weight * 0.073), "omega6": Double(weight * 0.219)]
        }
        
        //年齡修正 tier2
        if age == "young"{
            //do modefication for young
        }else if age == "adult"{
            whitIDaillyNeed["熱量"]! -= Double(weight)
            whitIDaillyNeed["蛋白質"]! -= Double(weight * 0.1)
            whitIDaillyNeed["脂肪"]! *= 0.92
            whitIDaillyNeed["Ca"]! += 200.0
            whitIDaillyNeed["P"]! -= Double(weight)
        }else if age == "secret"{
            //do modefication for young / secret
            
            
        }else{
            whitIDaillyNeed["熱量"]! -= Double(weight * 3.0)
            whitIDaillyNeed["蛋白質"]! -= Double(weight * 0.2)
            whitIDaillyNeed["脂肪"]! *= 0.80
            whitIDaillyNeed["B3"]! -= 5.0
            whitIDaillyNeed["Ca"]! += 400.0
            whitIDaillyNeed["P"]! -= Double(weight * 2.0)
            
        }
        
        //限制條件修正 tier 4
        if restrintion != "none" {
            
            switch restrintion {
            case "kidney":
                whitIDaillyNeed["熱量"]! -= Double(weight * 2.0)
                whitIDaillyNeed["蛋白質"]! -= Double(weight * 0.4)
                whitIDaillyNeed["脂肪"]! *= 0.80
                whitIDaillyNeed["B3"]! -= 5.0
                whitIDaillyNeed["Ca"]! = 1500.0
                whitIDaillyNeed["P"]! -= Double(weight * 7.0)
                whitIDaillyNeed["K"]! = 1500.0
                whitIDaillyNeed["Na"]! = 2000
            case "diabete":
                //whitIDaillyNeed["熱量"]! -= Double(weight * 2)!
                whitIDaillyNeed["蛋白質"]! -= Double(weight * 0.4)
                whitIDaillyNeed["醣分"]! *= 0.80
                whitIDaillyNeed["脂肪"]! *= 0.80
                whitIDaillyNeed["膳食纖維"]! += 15.0
                whitIDaillyNeed["B3"]! -= 5.0
                //whitIDaillyNeed["Ca"]! = 1500.0
                whitIDaillyNeed["P"]! -= Double(weight * 7.0)
                whitIDaillyNeed["K"]! = 1500.0
                whitIDaillyNeed["Na"]! = 2000
            case "kindeyAndDiabete":
                whitIDaillyNeed["熱量"]! -= Double(weight * 2.0)
                whitIDaillyNeed["蛋白質"]! -= Double(weight * 0.6)
                whitIDaillyNeed["醣分"]! *= 0.80
                whitIDaillyNeed["脂肪"]! *= 0.80
                whitIDaillyNeed["膳食纖維"]! += 15.0
                whitIDaillyNeed["B3"]! -= 5.0
                whitIDaillyNeed["Ca"]! = 1500.0
                whitIDaillyNeed["P"]! -= Double(weight * 7.0)
                whitIDaillyNeed["K"]! = 1500.0
                whitIDaillyNeed["Na"]! = 2000
                
            case "detailSet":
                break
            default:
                break
            }
        }
        whatINeedNuiCollectionView.reloadData()
        print(whitIDaillyNeed)
    }
    
    func fetchedARecord (record: CKRecord!) {
        print("ghfhfhfhgfhgfhgfhgfhf")
        foodArray = record.value(forKey: "foodArray") as! [String]
        foodAmountArray = record.value(forKey: "foodAmountArray") as! [String]
        nuitritionArray = record.value(forKey: "nuitritionArray") as! [Double]
        diary = record.value(forKey: "diary") as! String
        //print(diary)
        order = Int(record.recordID.recordName)!
        self.ieat.newEntryUpdateOrInsertToCoreData(saveType: "not Photo")
    }
    
    func coredataRestoreFromiCloud(){
        
        backButton.isHidden = true
        restoreButton.isHidden = true
        //回復iCloud的資料到coreData
        //download iCloud的資料
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: "iEATtest", predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { (results, error) -> Void in
            if error != nil {
                print("fetch error \(error!)")
            }else{
                var recordIDArray:[String] = [] //recordID 就是 order
                var CKRecordArray:[CKRecord] = []
                
                for result in results! {
                    recordIDArray.append(result.recordID.recordName)
                    print("this is recordIDArray\(recordIDArray)")
                    CKRecordArray.append(result)
                    print("從iColud fetch \(CKRecordArray.count) 個記錄檔(CKRecord)")
                }
                
//                for i in 0...recordIDArray.count - 1{
//                    
//                    foodArray = CKRecordArray[i].value(forKey: "foodArray") as! [String]
//                    foodAmountArray = CKRecordArray[i].value(forKey: "foodAmountArray") as! [String]
//                    nuitritionArray = CKRecordArray[i].value(forKey: "nuitritionArray") as! [Double]
//                    diary = CKRecordArray[i].value(forKey: "diary") as! String
//                    
//                    order = Int(recordIDArray[i])!
//                    //self.ieat.newEntryUpdateOrInsertToCoreData(saveType: "not Photo")
//                    
//                }
                OperationQueue.main.addOperation({
                    print("asdasdasdadadada")
                    self.backButton.isHidden = false
                    self.restoreButton.isHidden = false
                })
            }
        }
        
        //增加query上限
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.recordFetchedBlock = fetchedARecord
        queryOperation.resultsLimit = 9999 //應該是要用cursor才對，這邊先暫時這樣
        queryOperation.queryCompletionBlock = { [weak self] (cursor : CKQueryCursor!, error : NSError!) in
            
            if cursor != nil {
                print("there is more data to fetch")
                let newOperation = CKQueryOperation(cursor: cursor)
                newOperation.recordFetchedBlock = self!.fetchedARecord
                newOperation.queryCompletionBlock = queryOperation.queryCompletionBlock
                privateDatabase.add(newOperation)
            }
            
            } as? (CKQueryCursor?, Error?) -> Void
        
        privateDatabase.add(queryOperation)
        
    }
    
    func coreDataBackupToCloud(){
        backButton.isHidden = true
        restoreButton.isHidden = true
        //將coreData備份到iCloud
        //首先先download iCloud的資料來判斷要新增還是取代iCloud上的紀錄
        if orderArray.count != 0{ //orderArray裡面有東西才來備份
            
            let container = CKContainer.default()
            let privateDatabase = container.privateCloudDatabase
            let predicate = NSPredicate(value: true)
            let query = CKQuery(recordType: "iEATtest", predicate: predicate)
            privateDatabase.perform(query, inZoneWith: nil) { (results, error) -> Void in
                
                if error != nil {
                    print("fetch error \(error!)")
                }
                
                var recordIDArray:[String] = [] //recordID 就是 order
                var CKRecordArray:[CKRecord] = []
                
                if error != nil {
                    print("iCloud上面沒記錄 直接開始上傳")
                }else{
                    for result in results! {
                        recordIDArray.append(result.recordID.recordName)
                        print("this is recordIDArray\(recordIDArray)")
                        CKRecordArray.append(result)
                        print("從iColud fetch \(CKRecordArray.count) 個記錄檔(CKRecord)")
                    }
                }
                print("iCloud 上面有\(results?.count)組資料")
                print("this is orderArray\(orderArray)")
                //開始備份
                for i in 0...orderArray.count - 1{
                    if recordIDArray.contains("\(orderArray[i])"){
                        //to replace
                        
                        order = orderArray[i]
                        self.ieat.loadEntryFromCoreData()
                        
                        let index = recordIDArray.index(of: "\(orderArray[i])")!
                        CKRecordArray[index].setObject(foodArray as CKRecordValue?, forKey: "foodArray")
                        CKRecordArray[index].setObject(foodAmountArray as CKRecordValue?, forKey: "foodAmountArray")
                        CKRecordArray[index].setObject(nuitritionArray as CKRecordValue?, forKey: "nuitritionArray")
                        CKRecordArray[index].setObject(diary as CKRecordValue?, forKey: "diary")
                        
                        let container = CKContainer.default()
                        let privateDatabase = container.privateCloudDatabase
                        
                        privateDatabase.save(CKRecordArray[index], completionHandler: { (reccord, error) -> Void in
                            if (error != nil) {
                                print("save error \(error!)")
                            }
                        })
                        
                        print("replace to cloud")
                        
                    }else{
                        //to save new record
                        let noteID = CKRecordID(recordName: "\(orderArray[i])")
                        let noteRecord = CKRecord(recordType: "iEATtest", recordID: noteID)
                        
                        order = orderArray[i]
                        self.ieat.loadEntryFromCoreData()
                        
                        
                        noteRecord.setObject(foodArray as CKRecordValue?, forKey: "foodArray")
                        noteRecord.setObject(foodAmountArray as CKRecordValue?, forKey: "foodAmountArray")
                        noteRecord.setObject(nuitritionArray as CKRecordValue?, forKey: "nuitritionArray")
                        noteRecord.setObject(diary as CKRecordValue?, forKey: "diary")
                        
                        let container = CKContainer.default()
                        let privateDatabase = container.privateCloudDatabase
                        
                        privateDatabase.save(noteRecord, completionHandler: { (reccord, error) -> Void in
                            if (error != nil) {
                                print("save error \(error!)")
                            }
                        })
                        print("save new record to cloud")
                        
                    }
                }
                OperationQueue.main.addOperation({
                    print("asdasdasdadadada")
                    self.backButton.isHidden = false
                    self.restoreButton.isHidden = false
                })
            }
            
        }
    }
    
    func setupCollectionView(){
        let whatINeedsLayout = UICollectionViewFlowLayout()
        whatINeedsLayout.minimumLineSpacing = 2
        whatINeedsLayout.minimumInteritemSpacing = 2
        whatINeedsLayout.scrollDirection = .horizontal
        whatINeedNuiCollectionView.collectionViewLayout = whatINeedsLayout
        whatINeedNuiCollectionView.register(foodCollectionViewCell.self, forCellWithReuseIdentifier: "whatINeedsCell")
        whatINeedNuiCollectionView.delegate = self
        whatINeedNuiCollectionView.dataSource = self
        whatINeedNuiCollectionView.backgroundColor = UIColor.clear
    }
    
    
}

extension backupViewController: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nuitritionArray.count * 900
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = whatINeedNuiCollectionView.dequeueReusableCell(withReuseIdentifier: "whatINeedsCell", for: indexPath) as! foodCollectionViewCell
        
        cell.awakeFromNib()
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 3
        
        //以下偶數列背景區分
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.clear
        } else {
            cell.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        }
        //以上偶數列背景區分
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let whatINeedsCell = cell as! foodCollectionViewCell
        whatINeedsCell.label.adjustsFontSizeToFitWidth = true
        whatINeedsCell.label.font = UIFont(name: "System", size: 4)
        whatINeedsCell.label.numberOfLines = 0
        whatINeedsCell.label.textAlignment = .center
        let x = ["熱量","蛋白","醣分","膳食纖維","膽固醇","脂肪","脂肪酸(S)","脂肪酸(M)","脂肪酸(P)","鈉","鉀","鈣","鎂","鐵","鋅","磷","銅","A","E","B1","B2","B3","B6","B9","B12","C","ω3","ω6"]
        let y = ["熱量","蛋白質","醣分","膳食纖維","膽固醇","脂肪","飽和脂肪酸S","單元不飽和脂肪酸","多元不飽和脂肪酸","Na","K","Ca","Mg","Fe","Zn","P","Cu","A","E","B1","B2","B3","B6","B9","B12","C","omega3","omega6"]
        let z = ["kcal","g","g","g","g","g","g","g","g","mg","mg","mg","mg","mg","mg","mg","ug","IU","mg","mg","mg","mg","mg","mg","ug","mg","g","g"]
        whatINeedsCell.label.text = " \(x[indexPath.row % 28]) \n\(String(format:"%.0f",whitIDaillyNeed[y[indexPath.row % 28]]!)) \(z[indexPath.row % 28])"
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 70, height: collectionView.frame.height * 0.8)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    }
    
    
    
    
}

extension backupViewController: UIScrollViewDelegate{
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scroll start")
        self.resetLock.invalidate()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scroll stop")
        
        startFromX = max(scrollView.contentOffset.x, CGFloat(1))
        if self.resetLock.isValid == false{
            if startDeceleratinX >= startFromX {
                self.movingSpeed = CGFloat(-0.5)
            }else{
                self.movingSpeed = CGFloat(0.5)
            }
            self.resetLock = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.keepMovingCollectionView), userInfo: nil, repeats: true)
            RunLoop.current.add(self.resetLock, forMode: .commonModes)
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        startDeceleratinX = max(scrollView.contentOffset.x, CGFloat(1))
    }
    
}














