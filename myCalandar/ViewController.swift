//
//  ViewController.swift
//  myCalandar
//
//  Created by 華宇 on 2016/12/8.
//  Copyright © 2016年 華宇. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: BaseViewController {

    let storage = HKHealthStore()
    let ieat = iEATViewController()
    var showMonthArray: [[String]] = []
    var firstLaunch = "yes"
    var nextMonth1stOrder = 0
    var lastMonthLastOrder = 0
    var theFirstIndexPath: IndexPath?
    var theLastIndexPath: IndexPath?
    var todayIndexPath: IndexPath?
    var indexOfDateCell: IndexPath?
    {
        didSet{
            oldIndexPathOfDateCell = oldValue
        }
    }
    var oldIndexPathOfDateCell: IndexPath?
    fileprivate var startFromX = CGFloat(1)
    fileprivate var startDeceleratinX = CGFloat(1)
    fileprivate var movingSpeed = CGFloat(0.5)
    fileprivate var myTimerForMovingCollectionView = Timer()
    var stepsBegin = 0
    var todaySteps = 0
    fileprivate var myTimerForAddSteps = Timer()
    @IBOutlet weak var toTodayButton: UIButton!
    
    @IBOutlet weak var diaryBackgroundImage: UIImageView!
    // 3 line
    @IBOutlet weak var Open: UIBarButtonItem!
    // 3 line
    
    
    @IBOutlet weak var stepsLabel: AnimationLabel!
    @IBOutlet weak var diaryTextView: UITextView!
    @IBOutlet weak var yearMonthLabel: UILabel!
    @IBOutlet weak var yearMonthDayLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var foodCollectionView: UICollectionView!
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBAction func editButtonClick(_ sender: UIButton) {
        
        segueFromCalendar = 1
        
    }
    
    
    
    @IBAction func changeMonth(_ sender: UIButton) {
        
        if sender.currentTitle! == "⏩" {
            nextMonth()
        }else{
            lastMonth()
        }
        

    }
    
    @IBAction func toTodayButtonClick(_ sender: UIButton){
        
        formatter.dateFormat = "yyyy'/'MM'/'dd"
        
        formatter.timeZone = TimeZone(abbreviation: "GMT+8:00")
        
        formatter.string(from: nowTime as Date)
        
        print(formatter.string(from: nowTime as Date))
        
        for i in 0...(monthArray.count - 1) {
            if monthArray[i][0] == formatter.string(from: nowTime as Date) {
                order = i
                todayOrder = i
                print("today order =  \(i)")
            }
        }
        print("asd b \(indexOfDateCell?.row)")
        print("asd b \(oldIndexPathOfDateCell?.row)")
        ieat.loadEntryFromCoreData()
        
        creatShowMonthArray()
        print("asd \(indexOfDateCell?.row)")
        print("asd \(oldIndexPathOfDateCell?.row)")
        indexOfDateCell = todayIndexPath
        
        showDateLabelDiaryFood()
        
    }
    
    @IBAction func threeLine(_ sender: NavButton) {
        
        revealViewController().revealToggle(self)
        
    }
    
    
    
    func nextMonth(){
        order = nextMonth1stOrder
        ieat.loadEntryFromCoreData()
        creatShowMonthArray()
        indexOfDateCell = theFirstIndexPath
        oldIndexPathOfDateCell = nil
        showDateLabelDiaryFood()
        
        print("nextMonth")
        print("this indexOfDateCell.row \(indexOfDateCell?.row)")
        print("this oldIndexPathOfDateCell.row \(oldIndexPathOfDateCell?.row)")
    }
    func lastMonth(){
        order = lastMonthLastOrder
        ieat.loadEntryFromCoreData()
        creatShowMonthArray()
        indexOfDateCell = theLastIndexPath
        oldIndexPathOfDateCell = nil
        showDateLabelDiaryFood()
        
        print("lastMonth")
        print("this indexOfDateCell.row \(indexOfDateCell?.row)")
        print("this oldIndexPathOfDateCell.row \(oldIndexPathOfDateCell?.row)")
    }
    
    override func awakeFromNib() {
        //ESTabBar用的
        self.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(), title: "CAL", image: UIImage(named: "Tear Off Calendar-100"), selectedImage: UIImage(named: "Tear Off Calendar Filled-100"))
        //ESTabBar用的
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAuthorization()
        
        //ESTabBar用的
        self.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(), title: "CAL", image: UIImage(named: "Tear Off Calendar-100"), selectedImage: UIImage(named: "Tear Off Calendar Filled-100"))
        //ESTabBar用的
        
        yearMonthDayLabel.layer.cornerRadius = 3
        yearMonthDayLabel.layer.borderWidth = 0.5
        yearMonthDayLabel.layer.borderColor = UIColor.orange.cgColor
        
        stepsLabel.layer.cornerRadius = 3
        stepsLabel.layer.borderWidth = 0.5
        stepsLabel.layer.borderColor = UIColor.orange.cgColor
        
        diaryBackgroundImage.layer.cornerRadius = 20
        diaryTextView.layer.cornerRadius = 0.3
        
        let swipeToDown = UISwipeGestureRecognizer(target: self, action: #selector(self.lastMonth))
        swipeToDown.direction = .down
        self.collectionView.addGestureRecognizer(swipeToDown)
        
        let swipeToUp = UISwipeGestureRecognizer(target: self, action: #selector(self.nextMonth))
        swipeToUp.direction = .up
        self.collectionView.addGestureRecognizer(swipeToUp)
        setupCollectionView()
        
        
        
        self.myTimerForMovingCollectionView = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.keepMovingCollectionView), userInfo: nil, repeats: true)
        
        //schedule NSTimer to another mode (not in defaultRunLoopMode)
        RunLoop.current.add(self.myTimerForMovingCollectionView, forMode: .commonModes)
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        
        if monthArray.count == 0 {
            monthArray = NSArray(contentsOfFile: pathOfmonththArray!) as! [[String]]
        }
        
        if order == 0 {
            findOrder()
        }
        //        // 3 lines
        //        Open.target = self.revealViewController()
        //        Open.action = #selector(SWRevealViewController.revealToggle(_:))
        //
        //        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        //        // 3 lines
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        print("VC viewDidAppear")
        let anotherQuaneForMyRecipe = DispatchQueue(label: "loadMonthData")
        anotherQuaneForMyRecipe.async { [weak self] in
            self?.ieat.loadEntryFromCoreData()
            self?.creatShowMonthArray()
            print("this is indexOfDateCell at viewDidAppear \(self?.indexOfDateCell)")
            if self?.indexOfDateCell == nil {
                self?.indexOfDateCell = self?.todayIndexPath
            }
            DispatchQueue.main.async {
                self?.showDateLabelDiaryFood()
                self?.photoCollectionView.reloadData()
                self?.collectionView.reloadData()
                self?.foodCollectionView.reloadData()
                self?.scrollCollectionViewToMid()
                //                let frame: CGRect = CGRect(x : 500, y : 0, width: self.foodCollectionView.frame.width, height: self.foodCollectionView.frame.height)
                //                self.foodCollectionView.scrollRectToVisible(frame, animated: true)//固定0.3秒
                
                if self?.firstLaunch == "yes"{
                    //self.ieat.loadEntryFromCoreData()
                    self?.tabBarController?.selectedIndex = 2
                    self?.firstLaunch = "no"
                }
            }
        }
        
        
        
        //        photoCollectionView.reloadData()
        //        collectionView.reloadData()
        //        foodCollectionView.reloadData()
        //        //用scrollRectToVisible設定photoCollection的顯示位置 置中
        //        scrollCollectionViewToMid()
        
        
        
        
    }
    
    func keepMovingCollectionView(){

        if self.startFromX == CGFloat(1){
            print("this startFromX \(startFromX)")
            self.startFromX = CGFloat((Double(self.photoCollectionView.layer.bounds.width) + 2.0) * Double(nuitritionArray.count) * 500.0)
            print("after added startFromX \(startFromX)")
        }
        
        self.startFromX += self.movingSpeed
        let frame: CGRect = CGRect(x : self.startFromX, y : 0, width: self.foodCollectionView.frame.width, height: self.foodCollectionView.frame.height)
        self.foodCollectionView.scrollRectToVisible(frame, animated: false)
    }
    
    
    
    
    func checkAuthorization() -> Bool{
        
        // Default to assuming that we're authorized
        var isEnabled = true
        
        // Do we have access to HealthKit on this device?
        if HKHealthStore.isHealthDataAvailable()
        {
            // We have to request each data type explicitly
            let steps = NSSet(object: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount))
            
            // Now we can request authorization for step count data
            storage.requestAuthorization(toShare: nil, read: steps as! Set<HKObjectType>) { (success, error) -> Void in
                isEnabled = success
            }
        }
        else
        {
            isEnabled = false
        }
        
        return isEnabled
    }
    
    func retrieveStepCount(completion: @escaping (_ stepRetrieved: Double) -> Void) {
        
        // The type of data we are requesting (this is redundant and could probably be an enumeration
        let type = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        // Our search predicate which will fetch data from now until a day ago
        // (Note, 1.day comes from an extension
        // You'll want to change that to your own NSDate
        
        let date = selectedTime
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let newDate = cal.startOfDay(for: date as Date)
        
        //  Set the Predicates & Interval
        let predicate = HKQuery.predicateForSamples(withStart: newDate as Date, end: NSDate() as Date, options: .strictStartDate)
        let interval: NSDateComponents = NSDateComponents()
        interval.day = 1
        
        // The actual HealthKit Query which will fetch all of the steps and sub them up for us.
        let query = HKStatisticsCollectionQuery(quantityType: type!, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: newDate as Date, intervalComponents: interval as DateComponents)
        
        selectedSteps = "👣0"
        self.stepsLabel.text = selectedSteps
        
        query.initialResultsHandler = { query, results, error in
            
            if error != nil {
                
                //  Something went Wrong
                return
            }
            
            if let myResults = results{
                myResults.enumerateStatistics(from: newDate as Date, to: date as Date) {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        
                        let steps = quantity.doubleValue(for: HKUnit.count())
                        
                        completion(steps)
                        
                        print("step is \(steps)")
                        self.todaySteps = Int(steps)
                        selectedSteps = "👣\(Int(steps))"
                        
                        print("selectedSteps is \(selectedSteps)")
                        self.stepsLabel.count(from: 0, to: Float(steps), duration: 0.3)
                        self.myTimerForAddSteps.invalidate()
                        DispatchQueue.main.async(){
                            self.stepsBegin = 0
                            
//                            self.myTimerForAddSteps = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.addNumberAndShow), userInfo: nil, repeats: true)
//                            RunLoop.current.add(self.myTimerForAddSteps, forMode: .commonModes)
                            
                            
                            
                        }
                    }
                }
            }
        }
        
        storage.execute(query)
        
    }
    
    
    func addNumberAndShow() {
        
        if stepsBegin < todaySteps {
            stepsBegin += 50
            self.stepsLabel.text = "👣\(stepsBegin)"
        } else {
            self.stepsLabel.text = "👣\(todaySteps)"
            self.myTimerForAddSteps.invalidate()
            print("addNumberAndShow")
            
        }
    }
    
    func findOrder(){
        
        formatter.dateFormat = "yyyy'/'MM'/'dd"
        
        formatter.timeZone = TimeZone(abbreviation: "GMT+8:00")
        
        formatter.string(from: nowTime as Date)
        
        print(formatter.string(from: nowTime as Date))
        
        for i in 0...(monthArray.count - 1) {
            if monthArray[i][0] == formatter.string(from: nowTime as Date) {
                
                let NSDateStringType = monthArray[i][0]
                
                order = i
                print("todat order == \(i)")
                todayOrder = i
                
                selectedTime = formatter.date(from: NSDateStringType) as! NSDate
                
                print(formatter.string(from: selectedTime as Date))
            }
        }
    }
    
    func showLabelDiaryFood()
    {
        UIView.performWithoutAnimation {
            let NSDateStringType = monthArray[order][0]
            selectedTime = formatter.date(from: NSDateStringType) as! NSDate
            retrieveStepCount { (steps) in
                
            }
            yearMonthLabel.text = "\(monthArray[order][1])/\(monthArray[order][2])"
            yearMonthDayLabel.text = "\(monthArray[order][0])📖"
            diaryTextView.text = diary
            //foodCollectionView.reloadData() //造成lag
            photoCollectionView.reloadData()
            DispatchQueue.main.async(){
                self.scrollCollectionViewToMid()
            }
        }
        print("showLabelDiaryFood ok")
    }
    
    func showDateLabelDiaryFood(){
        
        let NSDateStringType = monthArray[order][0]
        
        selectedTime = formatter.date(from: NSDateStringType) as! NSDate
        
        retrieveStepCount { (steps) in
            
        }
        
        yearMonthLabel.text = "\(monthArray[order][1])/\(monthArray[order][2])"
        yearMonthDayLabel.text = "\(monthArray[order][0])📖"
        diaryTextView.text = diary
        
        collectionView.reloadData()
        foodCollectionView.reloadData()
        photoCollectionView.reloadData()
        
        DispatchQueue.main.async(){
            self.scrollCollectionViewToMid()
        }
    }
    
    
    func creatShowMonthArray(){
        showMonthArray = []
        var x = 1
        var z = 1
        var empty = 0
        repeat {
            
            if monthArray[order][2] == monthArray[order - x][2] {
                x += 1
            }
        }while monthArray[order][2] == monthArray[order - x][2]
        lastMonthLastOrder = order - x
        
        if ((order - x + 1) % 7) > 0{
            for i in 1...((order - x + 1) % 7){
                showMonthArray.append(["", "", "", "", "999999", "", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0"])
                empty += 1
                print("add 1 empty empty now is \(empty)")
            }
        }
        theFirstIndexPath = IndexPath(row: showMonthArray.count, section: 0)
        print("theFirstIndexPath is \(theFirstIndexPath?.row)")
        print("empty ok last month 1st order = \(monthArray[lastMonthLastOrder][0])")
        
        showMonthArray.append(monthArray[order - x + 1])
        print("填入 \(monthArray[order - x + 1][0])")
        
        
        repeat{
            if monthArray[order - x + 1][2] == monthArray[order - x + 1 + z][2]{
                showMonthArray.append(monthArray[order - x + 1 + z])
                print("填入 \(monthArray[order - x + 1 + z][0])")
                
                formatter.dateFormat = "yyyy'/'MM'/'dd"
                
                formatter.timeZone = TimeZone(abbreviation: "GMT+8:00")
                
                formatter.string(from: nowTime as Date)
                
                print(formatter.string(from: nowTime as Date))
                
                //這裡有改到月曆核心，20170918
                if monthArray[order - x + 1 + z][0] == formatter.string(from: nowTime as Date) {
                    print("this is x = \(x) ; this is z = \(z) ; this empty = \(empty)")
                    todayIndexPath = IndexPath(row: z + empty, section: 0)
                    print("todayIndexPath is \(todayIndexPath?.row)")
                    
                }
                z += 1
            }
        }while monthArray[order - x + 1][2] == monthArray[order - x + 1 + z][2]
        nextMonth1stOrder = order - x + 1 + z
        print("共有\(showMonthArray.count) next month 1st = \(monthArray[nextMonth1stOrder][0])")
        theLastIndexPath = IndexPath(row: showMonthArray.count - 1, section: 0)
        print("theLastIndexPath is \(theLastIndexPath?.row)")
        
        
    }
    
    func scrollCollectionViewToMid(){
        
        let x = Double(self.photoCollectionView.bounds.width / self.photoCollectionView.bounds.height)
        print(x)
        
        
        print(x.truncatingRemainder(dividingBy: 1.0))
        let y = (1 - x.truncatingRemainder(dividingBy: 1.0)) / 2
        print(y)
        
        let scrllToXPosition = (self.photoCollectionView.bounds.height * CGFloat(photoArray.count)) - self.photoCollectionView.bounds.width - (self.photoCollectionView.bounds.height * CGFloat(y))
        self.photoCollectionView.scrollRectToVisible(CGRect(x: scrllToXPosition, y: 0, width: self.photoCollectionView.bounds.width, height: self.photoCollectionView.bounds.height), animated: true)
    }
    
    func setupCollectionView(){
        
        let layout = UICollectionViewFlowLayout()
        
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = layout
        
        //collectionView.register(monthCollectionViewCell.self, forCellWithReuseIdentifier: "dateCell") //b.註冊剛建好的UICollectionViewCell Class並給他一個identifier 這邊給他叫"foodCell" 然後用在步驟c
        
        collectionView.delegate = self
        
        collectionView.dataSource = self
        
        collectionView.backgroundColor = UIColor.clear
        
        
        // for foodCollectionCell
        let foodLayout = UICollectionViewFlowLayout()
        
        foodLayout.minimumLineSpacing = 2
        foodLayout.minimumInteritemSpacing = 2
        foodLayout.scrollDirection = .horizontal
        foodCollectionView.collectionViewLayout = foodLayout
        foodCollectionView.register(foodCollectionViewCell.self, forCellWithReuseIdentifier: "foodCell")
        foodCollectionView.delegate = self
        
        foodCollectionView.dataSource = self
        
        foodCollectionView.backgroundColor = UIColor.clear
        
        //for photoCollectionView
        let photoLayout = UICollectionViewFlowLayout()
        
        photoLayout.minimumLineSpacing = 0
        photoLayout.minimumInteritemSpacing = 0
        photoLayout.scrollDirection = .vertical
        photoCollectionView.collectionViewLayout = photoLayout
        
        photoCollectionView.register(photoCollectionViewCell.self, forCellWithReuseIdentifier: "photoCell") //b.註冊剛建好的UICollectionViewCell Class並給他一個identifier 這邊給他叫"foodCell" 然後用在步驟c
        
        photoCollectionView.delegate = self
        
        photoCollectionView.dataSource = self
        
        photoCollectionView.backgroundColor = UIColor.clear
        
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { //如果要show不同大小或不同類別的cell, 可以設更多sections
        
        if collectionView == self.collectionView {
            
            return 1
            
        }else{
            
            return 1
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.collectionView {
            
            return showMonthArray.count
            
        }
        
        if collectionView == self.photoCollectionView {
            
            return photoArray.count
            
        }else{
            
            return nuitritionArray.count * 900
            
        }
    }
    
    // dequeue & set up
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collectionView {
            
            // a.去建cocoa touch UICollectionViewCell Class
            
            //步驟c
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dateCell", for: indexPath) as! monthCollectionViewCell
            
            cell.delegate = self // protocol STEP 4
            cell.delegate2 = self
            cell.awakeFromNib() //呼叫 FoodCollectionViewCell 的 awakeFromNib 一種delegate的意思
            
            if self.showMonthArray[indexPath.row][4] != "999999" {
                
                cell.layer.borderWidth = 0.0
                cell.layer.cornerRadius = 3
                
                //        //以下偶數列背景區分
                //        if indexPath.row % 2 == 0 {
                //            cell.backgroundColor = UIColor.clear
                //        } else {
                //            cell.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
                //        }
                //        //以上偶數列背景區分
            }else{
                cell.layer.borderWidth = 0.0
                cell.backgroundColor = UIColor.clear
            }
            
            cell.backgroundColor = UIColor.clear
            
            return cell
            
        }
        
        if collectionView == photoCollectionView{
            
            let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! photoCollectionViewCell
            
            photoCell.awakeFromNib()
            
            return photoCell
            
        }else{
            
            let foodCell = collectionView.dequeueReusableCell(withReuseIdentifier: "foodCell", for: indexPath) as! foodCollectionViewCell
            
            //            foodCell.delegate = self // protocol STEP 4
            
            foodCell.awakeFromNib() //呼叫 FoodCollectionViewCell 的 awakeFromNib 一種delegate的意思
            
            foodCell.layer.borderWidth = 0.5
            foodCell.layer.cornerRadius = 3
            //以下偶數列背景區分
            if indexPath.row % 2 == 0 {
                foodCell.backgroundColor = UIColor.clear
            } else {
                foodCell.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
            }
            //以上偶數列背景區分
            
            return foodCell
            
        }
    }
    
    // populate the data of given cell
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {//生命週期為 after (cellForItemAt indexPath) but before the cell Displayed
        
        if collectionView == self.collectionView {
            
            let dateCell = cell as! monthCollectionViewCell
            dateCell.button.setTitle("\(self.showMonthArray[indexPath.row][3])", for: .normal)
            dateCell.button.tag = Int(self.showMonthArray[indexPath.row][4])!
            dateCell.indexPath = indexPath
            //test
            
            if self.showMonthArray[indexPath.row][4] == "\(order)"{
                dateCell.button.backgroundColor = UIColor.orange
            }else{
                dateCell.button.backgroundColor = UIColor.clear
            }
            dateCell.button.setTitleColor(UIColor.black, for: .normal)
            dateCell.button.clipsToBounds = true
            if orderArray.contains(Int(self.showMonthArray[indexPath.row][4])!) {
                dateCell.button.setTitleColor(UIColor.black, for: .normal)
            }else{
                dateCell.button.setTitleColor(UIColor.lightGray, for: .normal)
            }
            
        }
        
        if collectionView == photoCollectionView{
            
            let photoCell = cell as! photoCollectionViewCell
            if photoArray.count == 0 {
//                photoCell.photoButton.setBackgroundImage(UIImage(named: "camera"), for: .normal)
//                photoCell.photoButton.alpha = 0.5
            } else {
                photoCell.photoButton.setBackgroundImage(photoArray[indexPath.row], for: .normal)
                photoCell.photoButton.alpha = 1.0
            }
        }
        
        if collectionView == foodCollectionView{
            
            let foodCell = cell as! foodCollectionViewCell
            foodCell.label.adjustsFontSizeToFitWidth = true
            foodCell.label.font = UIFont(name: "System", size: 4)
            foodCell.label.numberOfLines = 0
            foodCell.label.textAlignment = .center
            let x = ["熱量","蛋白","醣分","膳食纖維","膽固醇","脂肪","脂肪酸(S)","脂肪酸(M)","脂肪酸(P)","鈉","鉀","鈣","鎂","鐵","鋅","磷","銅","A","E","B1","B2","B3","B6","B9","B12","C","ω3","ω6"]
            foodCell.label.text = " \(x[indexPath.row % 28]) \n\(Int(nuitritionArray[indexPath.row % 28])) %"
            
        }
    }
    
    //set the size of cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.collectionView {
            
            return CGSize(width: collectionView.frame.width * 0.142, height: collectionView.frame.height * 0.166)
            
        }
        
        if collectionView == photoCollectionView{
            
            //            return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.width)
            
        }else{
            
            let specificHeight = CGFloat(Int(collectionView.frame.height / CGFloat(collectionView.frame.height / 30)))
            
            return CGSize(width: self.photoCollectionView.layer.bounds.width * 1.0, height: collectionView.frame.height)
            
        }
    }
    
    //    //移動collectionView中的cell到中間的方法
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    //
    //        if collectionView == self.photoCollectionView{
    //
    //            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
    //
    //            let totalCellWidth = collectionView.bounds.height * CGFloat(photoArray.count)
    //
    //            let totalSpacingWidth = flowLayout.minimumLineSpacing * CGFloat(photoArray.count - 1)
    //
    //            let leftInset = max(0, (self.photoCollectionView.bounds.width - CGFloat(totalCellWidth + totalSpacingWidth))) / 2
    //            print("photoCollectionView total width \(self.photoCollectionView.bounds.width)")
    //
    //            print("cell width \(self.photoCollectionView.bounds.height)")
    //
    //            print("UIEdgeInsets leftInset \(leftInset)")
    //
    //            let rightInset = leftInset
    //            print("UIEdgeInsets rightInset \(rightInset)")
    //
    //            return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
    //        }else{
    //            return UIEdgeInsetsMake(0,0,0,0)
    //        }
    //    }
    
    //點擊要做的事
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt\(indexPath.row)")
        if collectionView == self.collectionView {
            collectionView.reloadItems(at: [indexPath])
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("didDeselectItemAt\(indexPath.row)")
        if collectionView == self.collectionView {
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
}

extension ViewController: monthCollectionViewCellDelegate, Test2Delegate { // protocol STEP 5
    
    func changeColorOfButton(forCell: monthCollectionViewCell) {
        indexOfDateCell = forCell.indexPath!
        order = forCell.button.tag
        ieat.loadEntryFromCoreData()
        showLabelDiaryFood()
        UIView.performWithoutAnimation {
            collectionView.reloadItems(at: [indexOfDateCell!])
            print("\(oldIndexPathOfDateCell?.row)")
            collectionView.reloadItems(at: [oldIndexPathOfDateCell ?? indexOfDateCell!])
        }
        print("order now is \(order)")
        print("this indexOfDateCell.row \(indexOfDateCell?.row)")
        print("this oldIndexPathOfDateCell.row \(oldIndexPathOfDateCell?.row)")
    }
    
    func testAgain(sender: monthCollectionViewCell) {
        print("i am using protocol and delegate")
    }
    
}


extension ViewController: UIScrollViewDelegate{
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scroll start")
        
        self.myTimerForMovingCollectionView.invalidate()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scroll stop")
        
        startFromX = max(scrollView.contentOffset.x, CGFloat(1))
        if self.myTimerForMovingCollectionView.isValid == false{
            if startDeceleratinX >= startFromX {
                self.movingSpeed = CGFloat(-0.5)
            }else{
                self.movingSpeed = CGFloat(0.5)
            }
            self.myTimerForMovingCollectionView = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.keepMovingCollectionView), userInfo: nil, repeats: true)
            RunLoop.current.add(self.myTimerForMovingCollectionView, forMode: .commonModes)
            
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        startDeceleratinX = max(scrollView.contentOffset.x, CGFloat(1))
    }
    //    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    //        print("scroll stop")
    //        print(scrollView.contentOffset.x)
    //        startFromX = max(scrollView.contentOffset.x, CGFloat(1))
    //
    //        if self.resetLock.isValid == false{
    //
    //        self.resetLock = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.keepMovingCollectionView), userInfo: nil, repeats: true)
    //            RunLoop.current.add(self.resetLock, forMode: .commonModes)
    //        }
    //    }
}
























