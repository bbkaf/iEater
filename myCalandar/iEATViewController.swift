//
//  iEATViewController.swift
//  myCalandar
//
//  Created by 華宇 on 2016/12/13.
//  Copyright © 2016年 華宇. All rights reserved.
//

import UIKit
import CoreData
import Charts    // bar chart  .....1
import Speech
//for live photo
//import Photos
//import PhotosUI
//import MobileCoreServices


class iEATViewController: BaseViewController, SFSpeechRecognizerDelegate {
    
    //隨keyboard移動textView記住這條constrain到bottom的距離(這邊是99) ...1~5
    @IBOutlet weak var sliderUpImage: UIImageView!
    @IBOutlet weak var upICON: UIImageView!
    @IBOutlet weak var downICON: UIImageView!
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    var mode = "selectedFood"
    var historyFood = ""
    var historyAmount = "0"
    var functionPage = "foodPage"
    
    @IBOutlet weak var speechButton: UIButton!
    @IBOutlet weak var yearMonthDay: UILabel!
    @IBOutlet weak var sundayLabel: UILabel!
    @IBOutlet weak var mondayLabel: UILabel!
    @IBOutlet weak var tuesdayLabel: UILabel!
    @IBOutlet weak var wednesdayLabel: UILabel!
    @IBOutlet weak var thursdayLabel: UILabel!
    @IBOutlet weak var fridayLabel: UILabel!
    @IBOutlet weak var saturdayLabel: UILabel!
    @IBOutlet weak var diaryTextView: UITextView!
    @IBOutlet weak var unLockButton: UIButton!
    @IBOutlet weak var foodCollectionView: UICollectionView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var searchFoodButton: UIButton!
    @IBOutlet weak var eatFoodButton: UIButton!
    
    @IBOutlet weak var lowerButtonForGesture: UIButton!
    // 3 line
    @IBOutlet weak var Open: UIBarButtonItem!
    
    
    @IBAction func threeLine(_ sender: UIButton) {
        //        revealViewController().revealToggle(self)
    }
    // 3 line
    
    @IBOutlet weak var amountSlider: UISlider!
    @IBOutlet weak var amonutSliderImage: UIImageView!
    @IBOutlet weak var buttonForGesture: UIButton!
    
    
    
    @IBOutlet weak var barChartView: BarChartView!   // bar chart  .....2
    
    var barChartX = ["熱量","S","M","P","蛋白質","礦物質","礦物質","蛋白質","礦物質","礦物質","蛋白質","礦物質","礦物質"]
    
    var nuitsSold = [12.3, 35.2, 1.1, 30.2, 5.2, 1.1, 30.4, 5.2, 1.1, 30.1, 5.2, 1.1, 30.4]
    
    
    
    var singleFoodNuitrition:[Double] = []
    
    //MARK: SpeechKit properties
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "zh_Hant_TW"))!
    
    //這個物件負責發起語音識別請求。它為語音識別器指定一個音頻輸入源。
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    //這個物件用於保存發起語音識別請求后的返回值。通過這個物件，你可以取消或中止當前的語音識別任務。
    private var recognitionTask: SFSpeechRecognitionTask?
    
    //這個物件引用了語音引擎。它負責提供錄音輸入。
    private let audioEngine = AVAudioEngine()
    private var NumberOfResultStringChar = 0
    
    //自動結束計時
    var detectionTimer = Timer()
    
    
    @IBAction func searchFoodButtonClick(_ sender: UIButton) {
        performSegue(withIdentifier: "popoverToFoodItem", sender: nil)
    }
    
    @IBAction func speechButtonClick(_ sender: UIButton?) {
        switchSpeechButton()
    }
    
    func switchSpeechButton() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            speechButton.isEnabled = false
            speechButton.setTitle("Start Recording", for: .normal)
        } else {
            startRecording()
            speechButton.setTitle("Stop Recording", for: .normal)
        }
    }
    @IBAction func eatFoodButtonClick(_ sender: UIButton) {
        
        if searchFoodButton.currentTitle != "🔍" && searchFoodButton.currentTitle != "今日攝取" {
            
            //append food & food amount & nuitrition Array
            foodArray.append(self.searchFoodButton.currentTitle!)
            foodAmountArray.append("\(Int(self.amountSlider.value))")
            
            for i in 0...(nuitritionArray.count - 1){
                let x = nuitritionArray[i]
                print(x)
                
                let y = x + Double(NSString(format: "%.2f", singleFoodNuitrition[i]) as String)!
                print(y)
                
                nuitritionArray[i] = y
            }
            //這邊輸出還是小數點好多位???
            print(nuitritionArray)
            
            
            //reload collectionView
            foodCollectionView.reloadData()
            
            //updata coreData
            newEntryUpdateOrInsertToCoreData(saveType: "notPhoto")
            
            //searchFoodButton currentTitle = 🔍
            searchFoodButton.setTitle("🔍", for: .normal)
            
        }
    }
    
    @IBAction func unLockButtonClick(_ sender: UIButton) {
        
        if sender.currentTitle == "🔒" {
            sender.setTitle("🔓", for: .normal)
            //            diaryTextView.isEditable = true
        }else{
            sender.setTitle("🔒", for: .normal)
            //            diaryTextView.isEditable = false
            //            diaryTextView.isSelectable = false
            diaryTextView.resignFirstResponder()
            //updata entry
            diary = diaryTextView.text
            newEntryUpdateOrInsertToCoreData(saveType: "not photo")
        }
        
    }
    
    @IBAction func amountSliderAction(_ sender: UISlider) {
        
        if mode != "todayTotalFood" {
            
            eatFoodButton.setTitle("\((NSString(format: "%.0f", sender.value))) 克", for: .normal)
            
            showFoodInBarChart(mode: mode, page: page)
            
        }
    }
    
    func startRecording() {
        
        //檢查 recognitionTask 任務是否處於運行狀態。如果是，取消任務，開始新的語音識別任務
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        //建立一個 AVAudioSession 用於錄音。將它的 category 設置為 record，
        //mode 設置為 measurement，然後開啟 audio session。
        //因為對這些屬性進行設置有可能出現異常情況，因此你必須將它們放到 try catch 語句中。
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        //初始化 recognitionRequest 物件。這裡我們建立了一個 SFSpeechAudioBufferRecognitionRequest 物件。
        //在後面，我們會用它將錄音數據轉發給蘋果伺務器。
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        
        //檢查 audioEngine (即你的iPhone) 是否擁有有效的錄音設備。如果沒有，我們產生一個致命錯誤。
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }  //4
        
        //第 23-25 行 – 檢查 recognitionRequest 物件是否初始化成功 （即是值不能設為nil）。
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        //告訴 recognitionRequest 在用戶說話的同時，將識別結果分批返回。
        recognitionRequest.shouldReportPartialResults = true  //6
        
        //呼叫 speechRecognizer 裡的recognitionTask 方法開始識別。
        //方法參數中包括一個處理函數。當語音識別引擎每次採集到語音數據、修改當前識別、取消、停止、以及返回最終譯稿時都會調用處理函數。
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            //定義一個 boolean 變數，用於檢查識別是否結束。
            var isFinal = false  //8
            
            //如果 result 不是 nil，將 textView.text 設置為 result 的最佳音譯。
            if result != nil {
                print("speech results log")
                print(result?.bestTranscription.formattedString)  //9
                
                //如果 result 是最終譯稿，將 isFinal 設置為 true。
                isFinal = (result?.isFinal)!
                print("isFinal = \(isFinal)")
                let resultsString = result!.bestTranscription.formattedString

                // 如果沒有錯誤發生，或者 result 已經結束，停止 audioEngine (錄音) 並終止 recognitionRequest 和 recognitionTask。同時，使 「開始錄音」按鈕可用。
                if error != nil || isFinal {  //10
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    self.speechButton.isEnabled = true
                    self.speechButton.titleLabel?.text = "結束！"
                    
                    let parameters = ["subscription-key":"cac611e28ecc4e76be0939b3e8639419","staging":"true", "verbose":"true", "timezoneOffset":"0"]
                    
                    var urlComponents = URLComponents(string: "https://westus.api.cognitive.microsoft.com/luis/v2.0/apps/15a4f688-21fa-48cc-886d-9b32c9cfd32d")!
                    urlComponents.queryItems = []
                    
                    for (key, value) in parameters{
                        guard let value = value as? String else{return}
                        urlComponents.queryItems?.append(URLQueryItem(name: key, value: value))
                    }
                    let queueContent = "我吃了一百克白飯"
                    let queueContentUtf8Str = queueContent.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                    let queueKey = "q"
                    let queryItem1 = URLQueryItem(name: queueKey, value: queueContentUtf8Str)
                    urlComponents.queryItems?.append(queryItem1)
                    guard let queryedURL = urlComponents.url else{return}
                    
                    
                    var url = queryedURL //change the url
                    print("shiny url = \(url)")
                    //create the session object
                    let session = URLSession.shared
                    
                    //now create the URLRequest object using the url object
                    var request = URLRequest(url: url)
                    
                    let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                        
                        guard error == nil else { print("asddd 1"); return }
                        
                        guard let data = data else { print("asddd 2"); return }
                        
                        do {
                            //create json object from data
                            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                print("json")
                                print(json)
                                // handle json...
                            }
                        } catch let error {
                            print("asddd 3")
                            print(error.localizedDescription)
                        }
                    })
                    print("asddd 4")
                    task.resume()
                    
                    if resultsString != "" {
                        for i in 0...foodItemArrayForSpeech.count - 1 {
                            if foodItemArrayForSpeech[i][0].lowercased().contains(resultsString.lowercased()) || foodItemArrayForSpeech[i][1].lowercased().contains(resultsString.lowercased()) || foodItemArrayForSpeech[i][2].lowercased().contains(resultsString.lowercased()) {
                                selectedFood = foodItemArrayForSpeech[i][0]
                                self.refreshBarChart()
                                print("i find this food \(foodItemArrayForSpeech[i][0])")
                                
                                break
                            }
                        }
                    }
                }
                
                if self.detectionTimer.isValid {
                    print("here 0")
                    if isFinal {
                        print("here 1")
                        self.detectionTimer.invalidate()
                    } else {
                        self.detectionTimer.invalidate()
                        
                        print("here 2")
                        self.detectionTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { (timer) in
                            print("1.5秒到了")
                            isFinal = true
                            timer.invalidate()
                            self.audioEngine.stop()
                            inputNode.removeTap(onBus: 0)
                            self.recognitionRequest = nil
                            self.recognitionTask = nil
                            self.speechButton.isEnabled = true
                            self.speechButton.titleLabel?.text = "結束！"
                            
                            let parameters = ["subscription-key":"cac611e28ecc4e76be0939b3e8639419","staging":"true", "verbose":"true", "timezoneOffset":"0"]
                            
                            var urlComponents = URLComponents(string: "https://westus.api.cognitive.microsoft.com/luis/v2.0/apps/15a4f688-21fa-48cc-886d-9b32c9cfd32d")!
                            urlComponents.queryItems = []
                            
                            for (key, value) in parameters{
                                guard let value = value as? String else{return}
                                urlComponents.queryItems?.append(URLQueryItem(name: key, value: value))
                            }
                            let queueContent = "我吃了一百克白飯"
                            let queueContentUtf8Str = queueContent.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                            let queueKey = "q"
                            let queryItem1 = URLQueryItem(name: queueKey, value: queueContentUtf8Str)
                            urlComponents.queryItems?.append(queryItem1)
                            guard let queryedURL = urlComponents.url else{return}
                            
                            
                            var url = queryedURL //change the url
                            print("shiny url = \(url)")
                            //create the session object
                            let session = URLSession.shared
                            
                            //now create the URLRequest object using the url object
                            var request = URLRequest(url: url)
                            
                            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                                
                                guard error == nil else { print("asddd 1"); return }
                                
                                guard let data = data else { print("asddd 2"); return }
                                
                                do {
                                    //create json object from data
                                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                        print("json")
                                        print(json)
                                        // handle json...
                                    }
                                } catch let error {
                                    print("asddd 3")
                                    print(error.localizedDescription)
                                }
                            })
                            print("asddd 4")
                            task.resume()
                            
                            if resultsString != "" {
                                for i in 0...foodItemArrayForSpeech.count - 1 {
                                    if foodItemArrayForSpeech[i][0].lowercased().contains(resultsString.lowercased()) || foodItemArrayForSpeech[i][1].lowercased().contains(resultsString.lowercased()) || foodItemArrayForSpeech[i][2].lowercased().contains(resultsString.lowercased()) {
                                        selectedFood = foodItemArrayForSpeech[i][0]
                                        self.refreshBarChart()
                                        print("i find this food \(foodItemArrayForSpeech[i][0])")
                                        
                                        break
                                    }
                                }
                            }
                        })
                        
                        
                    }
                } else {
                    print("here 2")
                    self.detectionTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { (timer) in
                        print("1.5秒到了")
                        isFinal = true
                        timer.invalidate()
                        self.audioEngine.stop()
                        inputNode.removeTap(onBus: 0)
                        self.recognitionRequest = nil
                        self.recognitionTask = nil
                        self.speechButton.isEnabled = true
                        self.speechButton.titleLabel?.text = "結束！"
                        
                        let parameters = ["subscription-key":"cac611e28ecc4e76be0939b3e8639419","staging":"true", "verbose":"true", "timezoneOffset":"0"]
                        
                        var urlComponents = URLComponents(string: "https://westus.api.cognitive.microsoft.com/luis/v2.0/apps/15a4f688-21fa-48cc-886d-9b32c9cfd32d")!
                        urlComponents.queryItems = []
                        
                        for (key, value) in parameters{
                            guard let value = value as? String else{return}
                            urlComponents.queryItems?.append(URLQueryItem(name: key, value: value))
                        }
                        let queueContent = "我吃了一百克白飯"
                        let queueContentUtf8Str = queueContent.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                        let queueKey = "q"
                        let queryItem1 = URLQueryItem(name: queueKey, value: queueContentUtf8Str)
                        urlComponents.queryItems?.append(queryItem1)
                        guard let queryedURL = urlComponents.url else{return}
                        
                        
                        var url = queryedURL //change the url
                        print("shiny url = \(url)")
                        //create the session object
                        let session = URLSession.shared
                        
                        //now create the URLRequest object using the url object
                        var request = URLRequest(url: url)
                        
                        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                            
                            guard error == nil else { print("asddd 1"); return }
                            
                            guard let data = data else { print("asddd 2"); return }
                            
                            do {
                                //create json object from data
                                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                    print("json")
                                    print(json)
                                    // handle json...
                                }
                            } catch let error {
                                print("asddd 3")
                                print(error.localizedDescription)
                            }
                        })
                        print("asddd 4")
                        task.resume()
                        
                        if resultsString != "" {
                            for i in 0...foodItemArrayForSpeech.count - 1 {
                                if foodItemArrayForSpeech[i][0].lowercased().contains(resultsString.lowercased()) || foodItemArrayForSpeech[i][1].lowercased().contains(resultsString.lowercased()) || foodItemArrayForSpeech[i][2].lowercased().contains(resultsString.lowercased()) {
                                    selectedFood = foodItemArrayForSpeech[i][0]
                                    self.refreshBarChart()
                                    print("i find this food \(foodItemArrayForSpeech[i][0])")
                                    
                                    break
                                }
                            }
                        }
                    })
                }
            }
        })
        
        //向 recognitionRequest 加入一個音頻輸入。注意，可以在啟動 recognitionTask 之後再添加音頻輸入。Speech 框架會在添加完音頻輸入後立即開始識別。
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            speechButton.isEnabled = true
        } else {
            speechButton.isEnabled = false
        }
    }
    
    func getPhoto(){
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        pickerController.allowsEditing = true
        
        self.present(pickerController, animated: true, completion: nil)
    }
    
    func showTodayFood(){
        //準備放入 編輯 與 顯示今日攝取總量
        
        searchFoodButton.setTitle("🔍", for: .normal)
        
        mode = "todayTotalFood"
        
        searchFoodButton.setTitle("今日攝取", for: .normal)
        
        var totalEatGram = 0.0
        
        if foodArray.count != 0 {
            for i in 0...foodAmountArray.count - 1 {
                let x = Double(foodAmountArray[i])!
                totalEatGram += x
            }
        }else{
            totalEatGram = 0
        }
        
        eatFoodButton.setTitle("\(Int(totalEatGram)) 克", for: .normal)
        
        showFoodInBarChart(mode: mode, page: page)
        
        print("change mode to \(mode)")
        print(nuitritionArray)
    }
    
    func showFoodInBarChart(mode: String, page:Int){
        
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
                nuitsSold = [nuitritionArray[0],nuitritionArray[1],nuitritionArray[2],nuitritionArray[3],nuitritionArray[4],nuitritionArray[5],nuitritionArray[6],nuitritionArray[7],nuitritionArray[8],nuitritionArray[26],nuitritionArray[27]]
                
                
            case 2:
                
                barChartX = ["鈉","鉀","鈣","鎂","鐵","鋅","磷","銅"]
                nuitsSold = [nuitritionArray[9],nuitritionArray[10],nuitritionArray[11],nuitritionArray[12],nuitritionArray[13],nuitritionArray[14],nuitritionArray[15],nuitritionArray[16]]
                
            default:
                
                barChartX = ["A","E","B1","B2","B3","B6","B9","B12","C"]
                nuitsSold = [nuitritionArray[17],nuitritionArray[18],nuitritionArray[19],nuitritionArray[20],nuitritionArray[21],nuitritionArray[22],nuitritionArray[23],nuitritionArray[24],nuitritionArray[25]]
                
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
                setChart(dataPoints: barChartX, values: nuitsSold)
            }
        }
    }
    
    
    // bar chart  .....2
    
    func setChart(dataPoints: [String], values: [Double]) {
        
        
        barChartView.leftAxis.removeAllLimitLines()
        
        
        barChartView.noDataText = "點擊放大鏡 選擇食物種類"
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), yValues: [min(values[i], 99900.0)], label: dataPoints[i])
            dataEntries.append(dataEntry)
        }
        
        var foodToShowAtLimitLine = ""
        if mode == "selectedFood" {
            foodToShowAtLimitLine = "餐桌上的\(Int(amountSlider.value))g\(selectedFood)營養"
        }
        
        if mode == "historyFood" {
            foodToShowAtLimitLine = "肚子裡的\(historyAmount)g\(historyFood)"
        }
        
        if mode == "todayTotalFood" {
            foodToShowAtLimitLine = "今天攝取的營養"
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "每日所需(％)")
        
        let chartData = BarChartData()
        
        chartData.addDataSet(chartDataSet)
        
        barChartView.data = chartData
        
        //        let limit100 = ChartLimitLine(limit: 100.0, label: "\(foodToShowAtLimitLine)/每日所需(％)")
        let limit100 = ChartLimitLine(limit: 100.0, label: "")
        
        let xaxis = barChartView.xAxis
        xaxis.valueFormatter = axisFormatDelegate
        
        chartDataSet.colors = [UIColor.gray, UIColor.darkGray]
        barChartView.animate(xAxisDuration: 0.5, yAxisDuration: 0.9)
        barChartView.chartDescription?.text = ""
        
        barChartView.xAxis.wordWrapEnabled = true
        barChartView.xAxis.labelPosition = .bottomInside
        barChartView.xAxis.setLabelCount(barChartX.count + 1, force: true)
        barChartView.xAxis.centerAxisLabelsEnabled = true
        barChartView.xAxis.labelWidth = 0.2
        
        barChartView.scaleXEnabled = false
        barChartView.scaleYEnabled = false
        
        //        barChartView.layer.borderWidth = 0.5
        //        barChartView.layer.borderColor = UIColor.gray.cgColor
        barChartView.layer.cornerRadius = 5
        
        
        
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.drawLabelsEnabled = true
        barChartView.xAxis.enabled = true
        barChartView.xAxis.axisLineColor = UIColor.clear
        barChartView.backgroundColor = UIColor.clear
        
        barChartView.leftAxis.axisMaximum = 150
        barChartView.leftAxis.axisMinimum = -13
        barChartView.leftAxis.addLimitLine(limit100)
        
        barChartView.rightAxis.drawLabelsEnabled = false
        barChartView.leftAxis.drawLabelsEnabled = true
        
        barChartView.leftAxis.drawAxisLineEnabled = false
        barChartView.rightAxis.drawAxisLineEnabled = false
        
        barChartView.rightAxis.drawGridLinesEnabled = false
        barChartView.leftAxis.drawGridLinesEnabled = false
        
        //        barChartView.drawBarShadowEnabled = true  //畫出一條醜醜的灰色陰影
        
    }
    
    //手勢切換營養顯示種類...1~2
    func turnPageUp(){
        if page < 3 {
            page += 1
        }else{
            page = 1
        }
        self.showFoodInBarChart(mode: mode, page: page)
        print("turn page to \(page) page")
    }
    
    func turnPageDown(){
        if page > 1 {
            page -= 1
        }else{
            page = 3
        }
        self.showFoodInBarChart(mode: mode, page: page)
        
        print("turn page to \(page) page")
    }
    
    override func awakeFromNib() {
        //ESTabBar用的
        self.tabBarItem = ESTabBarItem.init(ExampleIrregularityContentView(), title: nil, image: UIImage(named: "Dining Room resize Filled-100"), selectedImage: UIImage(named: "Dining Room resize-100"))
        
        //ESTabBar用的
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("iEAT ViewDidLoad")
        print(self.tabBarController?.tabBar.frame.height)
        //隨keyboard移動textView ...2
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        //手勢切換營養顯示種類...2
        let swipeToRight = UISwipeGestureRecognizer(target: self, action: #selector(self.turnPageUp))
        swipeToRight.direction = .right
        self.buttonForGesture.addGestureRecognizer(swipeToRight)
        
        let swipeToLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.turnPageDown))
        swipeToRight.direction = .left
        self.buttonForGesture.addGestureRecognizer(swipeToLeft)
        
        //手勢切換功能頁
        let swipeToDown = UISwipeGestureRecognizer(target: self, action: #selector(self.foodEntryMode))
        swipeToDown.direction = .down
        //self.view.addGestureRecognizer(swipeToDown)
        self.lowerButtonForGesture.addGestureRecognizer(swipeToDown)
        //        self.barChartView.addGestureRecognizer(swipeToDown)
        
        let swipeToUp = UISwipeGestureRecognizer(target: self, action: #selector(self.diaryEntryMode))
        swipeToUp.direction = .up
        //self.view.addGestureRecognizer(swipeToUp)
        self.lowerButtonForGesture.addGestureRecognizer(swipeToUp)
        //        self.barChartView.addGestureRecognizer(swipeToUp)
        
        
        setupCollectionView()
        
        axisFormatDelegate = self
        barChartView.noDataText = ""
        //setButtonShape
        searchFoodButton.layer.cornerRadius = self.searchFoodButton.layer.bounds.width / 2
        searchFoodButton.layer.borderWidth = 1
        searchFoodButton.layer.borderColor = UIColor.orange.cgColor
        searchFoodButton.clipsToBounds = true
        
        eatFoodButton.layer.cornerRadius = self.eatFoodButton.layer.bounds.width / 2
        eatFoodButton.layer.borderWidth = 1
        eatFoodButton.layer.borderColor = UIColor.orange.cgColor
        eatFoodButton.clipsToBounds = true
        
        
        speechButton.layer.borderWidth = 1
        speechButton.layer.cornerRadius = self.searchFoodButton.layer.bounds.width / 2
        UIView.animate(withDuration: 2.0, delay: 0.1, options: [.repeat, .curveEaseInOut], animations: {
            self.speechButton.layer.borderWidth = 3
        }) { (true) in
            self.speechButton.layer.borderWidth = 1
        }
        speechButton.layer.borderColor = UIColor.getCustomDarkGreenColor().cgColor
        speechButton.clipsToBounds = true
        
        
        //這條是把文字窗關掉，以後新建的textView 叫的鍵盤可以關掉 viewDidLoad先委託代理 最下面實作extension
        diaryTextView.delegate = self
        self.addDoneButtonOnKeyboard()
        
        //        // 3 lines
        //        Open.target = self.revealViewController()
        //        Open.action = #selector(SWRevealViewController.revealToggle(_:))
        //        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        //        // 3 lines
        
        
        //MARK: SpeechKit ViewDidLoad
        speechButton.isEnabled = false
        
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.speechButton.isEnabled = isButtonEnabled
            }
        }
    
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            //self.speechButton.isHidden = !self.speechButton.isHidden
            print("Shaking")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
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
        //whitIDaillyNeed = nuitritionMaleDailyNeeds
        
        diaryTextView.text = diary
        
        unLockButton.isHidden = true
        
        print("iEAT ViewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //用scrollRectToVisible設定photoCollection的顯示位置 置中
        let x = Double(self.photoCollectionView.bounds.width / self.photoCollectionView.bounds.height)
        print(x)
        
        
        print(x.truncatingRemainder(dividingBy: 1.0))
        let y = (1 - x.truncatingRemainder(dividingBy: 1.0)) / 2
        print(y)
        
        let scrllToXPosition = (self.photoCollectionView.bounds.height * CGFloat(photoArray.count)) - self.photoCollectionView.bounds.width - (self.photoCollectionView.bounds.height * CGFloat(y))
        self.photoCollectionView.scrollRectToVisible(CGRect(x: scrllToXPosition, y: 0, width: self.photoCollectionView.bounds.width, height: self.photoCollectionView.bounds.height), animated: true)
        print("viewDidAppear")
        DispatchQueue.main.async {
            self.foodCollectionView.reloadData()
            self.photoCollectionView.reloadData()
            self.showYearMonthDay()
            self.showTodayFood()
        }
        
    }
    
    
    
    //隨keyboard移動textView ...3
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //隨keyboard移動textView ...4
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                
                //隨keyboard移動textView 下面程式碼為keyboard消失時 步驟1的constrin要回到原本值(99.0) ...5
                self.keyboardHeightLayoutConstraint?.constant = 99.0
                self.unLockButton.setTitle("🔒", for: .normal)
                
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
                self.unLockButton.setTitle("🔓", for: .normal)
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    func showDiary(){
        
        diaryTextView.text =  diary
    }
    
    func showYearMonthDay(){
        yearMonthDay.text = "\(monthArray[order][1])/\(monthArray[order][2])/\(monthArray[order][3])"
        
        sundayLabel.alpha = 0.2
        mondayLabel.alpha = 0.2
        tuesdayLabel.alpha = 0.2
        wednesdayLabel.alpha = 0.2
        thursdayLabel.alpha = 0.2
        fridayLabel.alpha = 0.2
        saturdayLabel.alpha = 0.2
        
        let dayOfWeek = Int(monthArray[order][4])! % 7
        switch dayOfWeek {
        case 0:
            sundayLabel.alpha = 1
        case 1:
            mondayLabel.alpha = 1
        case 2:
            tuesdayLabel.alpha = 1
        case 3:
            wednesdayLabel.alpha = 1
        case 4:
            thursdayLabel.alpha = 1
        case 5:
            fridayLabel.alpha = 1
        case 6:
            saturdayLabel.alpha = 1
            saturdayLabel.textColor = UIColor.red
        default:
            break
        }
    }
    
    
    func diaryEntryMode(){
        
        //need to hide food entry things
        
        if functionPage == "diaryPage" {
            
            self.getPhoto()
            
        }
        
        functionPage = "diaryPage"
        
        photoCollectionView.isHidden = false
        
        photoCollectionView.alpha = 1.0
        
        diaryTextView.isHidden = false
        
        foodCollectionView.isHidden = true
        
        searchFoodButton.isHidden = true
        
        eatFoodButton.isHidden = true
        
        barChartView.isHidden = true
        
        buttonForGesture.isHidden = true
        
        upICON.image = UIImage(named: "Dining Room resize Filled-100")
        sliderUpImage.image = UIImage(named: "Book Stack-100")
        downICON.image = UIImage(named: "photo_big")
        
        amountSlider.isHidden = true
        amonutSliderImage.isHidden = true
        
    }
    
    func foodEntryMode(){
        
        //need to show food entry things
        
        if fooodNutritionDictionary.count == 0 {
            
            let anotherQuane = DispatchQueue(label: "loadDictionary")
            anotherQuane.async {
                fooodNutritionDictionary = NSDictionary(contentsOfFile: pathOffoodNutritionDictionary!)! as! [String : String]
                
                print("load foodNuitritionDictionary")
            }
        }
        
        if functionPage == "foodPage" {
            
            self.showTodayFood() //讓他顯示一日總量
            
        }
        
        functionPage = "foodPage"
        
        photoCollectionView.alpha = 0.1
        
        diaryTextView.isHidden = true
        
        foodCollectionView.isHidden = false
        
        searchFoodButton.isHidden = false
        
        eatFoodButton.isHidden = false
        
        barChartView.isHidden = false
        
        buttonForGesture.isHidden = false
        
        amountSlider.isHidden = false
        amonutSliderImage.isHidden = false
        upICON.image = UIImage(named: "DOT-100")
        sliderUpImage.image = UIImage(named: "Dining Room resize Filled-100")
        downICON.image = UIImage(named: "Book Stack-100")
    }
    
    func newEntryUpdateOrInsertToCoreData(saveType: String){
        
        if orderInOrderArrayIndex != 999999 {
            //which mean update(replace) entry to coreData
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let context = appDelegate.persistentContainer.viewContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
            
            request.returnsObjectsAsFaults = false
            
            do
            {
                if let results = try context.fetch(request) as? [NSManagedObject] {
                    
                    if results.count != 0{
                        
                        let result = results[orderInOrderArrayIndex]
                        
                        let foodArrayData = NSKeyedArchiver.archivedData(withRootObject: foodArray) as NSData
                        result.setValue(foodArrayData, forKey: "foodArray")
                        
                        if saveType == "photo" {
                            let photoArrayData = NSKeyedArchiver.archivedData(withRootObject: photoArray) as NSData
                            result.setValue(photoArrayData, forKey: "photoArray")
                            print("updated photo")
                        }
                        
                        let foodAmountArrayData = NSKeyedArchiver.archivedData(withRootObject: foodAmountArray) as NSData
                        result.setValue(foodAmountArrayData, forKey: "foodAmountArray")
                        
                        let nuitritionArrayData = NSKeyedArchiver.archivedData(withRootObject: nuitritionArray) as NSData
                        result.setValue(nuitritionArrayData, forKey: "nuitritionArray")
                        
                        let diaryData = NSKeyedArchiver.archivedData(withRootObject: diary) as NSData
                        result.setValue(diaryData, forKey: "diary")
                        
                        let stepData = NSKeyedArchiver.archivedData(withRootObject: step) as NSData
                        result.setValue(stepData, forKey: "step")
                        
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
            
            orderArray.append(order)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let context = appDelegate.persistentContainer.viewContext
            
            let newUser = NSEntityDescription.insertNewObject(forEntityName: "Users", into: context)
            
            let foodArrayData = NSKeyedArchiver.archivedData(withRootObject: foodArray) as NSData
            newUser.setValue(foodArrayData, forKey: "foodArray")
            
            //            if saveType == "photo" {
            let photoArrayData = NSKeyedArchiver.archivedData(withRootObject: photoArray) as NSData
            newUser.setValue(photoArrayData, forKey: "photoArray")
            print("saved photo")
            //            }
            
            let foodAmountArrayData = NSKeyedArchiver.archivedData(withRootObject: foodAmountArray) as NSData
            newUser.setValue(foodAmountArrayData, forKey: "foodAmountArray")
            
            let nuitritionArrayData = NSKeyedArchiver.archivedData(withRootObject: nuitritionArray) as NSData
            newUser.setValue(nuitritionArrayData, forKey: "nuitritionArray")
            
            
            let diaryData = NSKeyedArchiver.archivedData(withRootObject: diary) as NSData
            newUser.setValue(diaryData, forKey: "diary")
            
            let stepData = NSKeyedArchiver.archivedData(withRootObject: step) as NSData
            newUser.setValue(stepData, forKey: "step")
            
            
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
    
    func loadEntryFromCoreData(){
        
        if orderInOrderArrayIndex == 999999 {
            
            foodArray = []
            diary = ""
            foodAmountArray = []
            step = ""
            nuitritionArray = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
            photoArray = []
            
            print("orderInOrderArrayIndex is \(orderInOrderArrayIndex)")
            
        }else{
            print("iEAT load coredata")
            print("orderInOrderArrayIndex is \(orderInOrderArrayIndex)")
            print("orderArray.count = \(orderArray.count)")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let context = appDelegate.persistentContainer.viewContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
            
            request.returnsObjectsAsFaults = false
            
            do
            {
                let results = try context.fetch(request)
                
                if results.count != 0 {
                    print("coreData裡有\(results.count)組資料")
                    
                    
                    var result = results[orderInOrderArrayIndex] as! NSManagedObject
                    
                    let foodArrayData = result.value(forKey: "foodArray") as! NSData
                    let foodArrayUnarchiveObject = NSKeyedUnarchiver.unarchiveObject(with: foodArrayData as Data)
                    foodArray = foodArrayUnarchiveObject as! [String]
                    
                    let photoArrayData = result.value(forKey: "photoArray") as! NSData
                    let photoArrayUnarchiveObject = NSKeyedUnarchiver.unarchiveObject(with: photoArrayData as Data)
                    photoArray = photoArrayUnarchiveObject as! [UIImage]
                    
                    let foodAmountArrayData = result.value(forKey: "foodAmountArray") as! NSData
                    let foodAmountArrayUnarchiveObject = NSKeyedUnarchiver.unarchiveObject(with: foodAmountArrayData as Data)
                    foodAmountArray = foodAmountArrayUnarchiveObject as! [String]
                    
                    let nuitritionArrayData = result.value(forKey: "nuitritionArray") as! NSData
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
                    nuitritionArray = oldNuitritionArray
                    
                    let diaryData = result.value(forKey: "diary") as! NSData
                    let diaryUnarchiveObject = NSKeyedUnarchiver.unarchiveObject(with: diaryData as Data)
                    diary = diaryUnarchiveObject as! String
                    
                    let stepData = result.value(forKey: "step") as! NSData
                    let stepUnarchiveObject = NSKeyedUnarchiver.unarchiveObject(with: stepData as Data)
                    step = stepUnarchiveObject as! String
                    
                }
                print("this is order \(order)")
                print("this is foodArray from CoreData \(foodArray)")
                print("this is foodAmountArray from CoreData \(foodAmountArray)")
            }
            catch
            {
            }
        }
        print(nuitritionArray.count)
    }
    
    func setupCollectionView(){
        
        //for foodCollectionView
        var foodLayout = UICollectionViewFlowLayout()
        
        foodLayout.minimumLineSpacing = 4
        foodLayout.minimumInteritemSpacing = self.foodCollectionView.layer.bounds.width / 4
        foodCollectionView.collectionViewLayout = foodLayout
        foodCollectionView.register(foodCollectionViewCell.self, forCellWithReuseIdentifier: "foodCell")
        foodCollectionView.delegate = self
        
        foodCollectionView.dataSource = self
        
        foodCollectionView.backgroundColor = UIColor.clear
        
        
        
        //for photoCollectionView
        let photoLayout = UICollectionViewFlowLayout()
        
        photoLayout.minimumLineSpacing = 0
        photoLayout.minimumInteritemSpacing = 0
        photoLayout.scrollDirection = .horizontal
        photoCollectionView.collectionViewLayout = photoLayout
        
        photoCollectionView.register(photoCollectionViewCell.self, forCellWithReuseIdentifier: "photoCell") //b.註冊剛建好的UICollectionViewCell Class並給他一個identifier 這邊給他叫"foodCell" 然後用在步驟c
        
        photoCollectionView.delegate = self
        
        photoCollectionView.dataSource = self
        
        photoCollectionView.backgroundColor = UIColor.clear
        
        
    }
}

extension iEATViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == self.foodCollectionView {
            
            return 1
            
        }else{
            
            return 1
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.foodCollectionView {
            
            return foodArray.count
            
        }else{
            
            return photoArray.count
            
        }
    }
    
    // dequeue & set up
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.foodCollectionView {
            
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
            
        }else{
            
            let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! photoCollectionViewCell
            
            photoCell.awakeFromNib()
            
            return photoCell
        }
    }
    
    // populate the data of given cell
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if collectionView == self.foodCollectionView {
            
            let foodCell = cell as! foodCollectionViewCell
            foodCell.label.adjustsFontSizeToFitWidth = true
            foodCell.label.font = UIFont(name: "System", size: 8)
            foodCell.label.numberOfLines = 2
            foodCell.label.textAlignment = .center
            foodCell.label.text = "\(foodArray[indexPath.row])\n\(foodAmountArray[indexPath.row]) g"
            
        }else{
            
            let photoCell = cell as! photoCollectionViewCell
            photoCell.photoButton.setBackgroundImage(photoArray[indexPath.row], for: .normal)
            
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.foodCollectionView {
            
            return CGSize(width: collectionView.frame.width * 0.32, height: 30)
            
        }else{
            return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView == self.photoCollectionView{
            
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            
            let totalCellWidth = collectionView.bounds.height * CGFloat(photoArray.count)
            
            let totalSpacingWidth = flowLayout.minimumLineSpacing * CGFloat(photoArray.count - 1)
            
            let leftInset = max(0, (self.photoCollectionView.bounds.width - CGFloat(totalCellWidth + totalSpacingWidth))) / 2
            
            let rightInset = leftInset
            
            return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
        }else{
            return UIEdgeInsetsMake(0,0,0,0)
        }
    }
    
    //點擊要做的事
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == foodCollectionView {
            
            mode = "selectedFood" //等於是拿掉historyMode的功能 改成類似歷史查詢 同時快速key in 資料
            
            print("change mode tp \(mode)  -- 等於是拿掉historyMode的功能 改成類似歷史查詢 同時快速key in 資料")
            
            historyFood = foodArray[indexPath.row]
            
            historyAmount = foodAmountArray[indexPath.row]
            
            selectedFood = historyFood
            
            searchFoodButton.setTitle(historyFood, for: .normal)
            
            eatFoodButton.setTitle("\(historyAmount) 克", for: .normal)
            
            amountSlider.setValue(Float(historyAmount)!, animated: true)
            
            showFoodInBarChart(mode: mode, page: page)
            
        }
        
        print(indexPath.row)
    }
}

//這條是把文字窗關掉，以後新建的textView 叫的鍵盤可以關掉 viewDidLoad先委託代理 最下面實作extension
extension iEATViewController: UITextViewDelegate {
    
    //    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    //        if(text == "\n"){
    //            view.endEditing(true)
    //            return false
    //        }else{
    //            return true
    //        }
    //    }
    
    func addDoneButtonOnKeyboard(){
        
        let doneToolBar: UIToolbar = UIToolbar(frame: CGRect(x:0, y:0 ,width:320, height:50))
        doneToolBar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.done, target: self, action: #selector(iEATViewController.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolBar.items = items
        doneToolBar.sizeToFit()
        
        self.diaryTextView.inputAccessoryView = doneToolBar
        
    }
    
    func doneButtonAction(){
        self.diaryTextView.resignFirstResponder()
        //store new entry
        diary = diaryTextView.text
        unLockButton.setTitle("🔒", for: .normal)
        //        diaryTextView.isEditable = false
        //        diaryTextView.isSelectable = false
        newEntryUpdateOrInsertToCoreData(saveType: "not Photo")
        
    }
}

import Photos
import PhotosUI

extension iEATViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        let chosenImage = info[UIImagePickerControllerEditedImage] as! UIImage
        photoArray.append(chosenImage)
        
        // UIImagePickerControllerEditedImage -> 輸出編輯後的照片
        //UIImagePickerControllerLivePhoto -> 輸出livePhoto
        
        
        print("asdasdadasd 11")
        let assetURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        print("asdasdadasd 112, \(assetURL)")
        let asset = PHAsset.fetchAssets(withALAssetURLs: [assetURL as URL], options: nil)
        print("asdasdadasd 113")
        guard let result = asset.firstObject else {
            return
        }
        print("asdasdadasd 12")
        let imageManager = PHImageManager.default()
        imageManager.requestImageData(for: result , options: nil, resultHandler:{
            (data, responseString, imageOriet, info) -> Void in
            let imageData: NSData = data! as NSData
//            if let imageSource = CGImageSourceCreateWithData(imageData, nil) {
//                let imageProperties2 = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)! as Dictionary
//                let exifDict = imageProperties2[kCGImagePropertyExifDictionary]
//                let dateTimeOriginal = exifDict![kCGImagePropertyExifDateTimeOriginal]
//                let dateTimeOriginal1 = exifDict![kCGImagePropertyDepth]
//                let dateTimeOriginal2 = exifDict![kCGImagePropertyWidth]
//                let dateTimeOriginal3 = exifDict![kCGImagePropertyGPSDOP]
//                let dateTimeOriginal4 = exifDict![kCGImagePropertyExifOECF]
//                let dateTimeOriginal5 = exifDict![kCGImagePropertyDPIWidth]
//                let dateTimeOriginal6 = exifDict![kCGImagePropertyGPSTrack]
//                let dateTimeOriginal7 = exifDict![kCGImagePropertyExifGamma]
//                let dateTimeOriginal8 = exifDict![kCGImagePropertyDepth]
//                let dateTimeOriginal9 = exifDict![kCGImagePropertyPixelWidth]
//                let dateTimeOriginal10 = exifDict![kCGImagePropertyJFIFYDensity]
//                print("---------------------------------------------------")
//                print(exifDict)
//                print("---------------------------------------------------")
////                print("dateTimeOriginal: \(dateTimeOriginal)")
////                print("dateTimeOriginal: \(dateTimeOriginal1)")
////                print("dateTimeOriginal: \(dateTimeOriginal2)")
////                print("dateTimeOriginal: \(dateTimeOriginal3)")
////                print("dateTimeOriginal: \(String(describing: dateTimeOriginal4))")
////                print("dateTimeOriginal: \(dateTimeOriginal5)")
////                print("dateTimeOriginal: \(dateTimeOriginal6)")
////                print("dateTimeOriginal: \(dateTimeOriginal7)")
////                print("dateTimeOriginal: \(dateTimeOriginal8)")
////                print("dateTimeOriginal: \(dateTimeOriginal9)")
////                print("dateTimeOriginal: \(dateTimeOriginal10)")
//                
//                for (key, value) in imageProperties2 {
//                    print("asdasdadasd in dic")
//                    print(key)
//                    print(value)
//                }
//                print("imageProperties2: \(imageProperties2)")
//               print("imageProperties2: \(imageProperties2.count)")
//            }
            
        })
        print("asdasdadasd 13")
        
        
        self.dismiss(animated: true, completion: nil)
        
        newEntryUpdateOrInsertToCoreData(saveType: "photo")
        
        photoCollectionView.reloadData()
        
    }
}

extension iEATViewController: UIPopoverPresentationControllerDelegate{
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "popoverToFoodItem", let fivc = segue.destination as? FoodItemTableViewController {
            fivc.delegateOfDidDismissPopover = self  // protocol STEP 4
            if let ppc = fivc.popoverPresentationController{
                ppc.delegate = self
                ppc.sourceView = self.view
                ppc.sourceRect = CGRect(x:  self.view.bounds.midX, y:self.view.bounds.midY, width: 0, height: 0)
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func refreshBarChart () {
        mode = "selectedFood"
        
        self.searchFoodButton.setTitle("\(selectedFood)", for: .normal)
        
        switch selectedFood {
        case "善存(1錠1.4g)":
            self.amountSlider.setValue(1.4, animated: true)
        case "燕麥麵(1把75g)":
            self.amountSlider.setValue(75, animated: true)
        case "可可粉(costco 1包28g)":
            self.amountSlider.setValue(28, animated: true)
        case "魚油(costco 一錠1.7g)":
            self.amountSlider.setValue(1.7, animated: true)
            
        default:
            break
        }
        
        eatFoodButton.setTitle("\((NSString(format: "%.1f", amountSlider.value))) 克", for: .normal)
        
        self.showFoodInBarChart(mode: mode, page: page)
        
        print("dismiss FoodItemTableViewController and viewDidLoad")
        
        print("change mode tp \(mode)")
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
        mode = "selectedFood"
        
        self.searchFoodButton.setTitle("\(selectedFood)", for: .normal)
        
        switch selectedFood {
        case "善存(1錠1.4g)":
            self.amountSlider.setValue(1.4, animated: true)
        case "燕麥麵(1把75g)":
            self.amountSlider.setValue(75, animated: true)
        case "可可粉(costco 1包28g)":
            self.amountSlider.setValue(28, animated: true)
        case "魚油(costco 一錠1.7g)":
            self.amountSlider.setValue(1.7, animated: true)
            
        default:
            break
        }
        
        eatFoodButton.setTitle("\((NSString(format: "%.1f", amountSlider.value))) 克", for: .normal)
        
        self.showFoodInBarChart(mode: mode, page: page)
        
        print("dismiss FoodItemTableViewController and viewDidLoad")
        
        print("change mode tp \(mode)")
        
    }
    
}

extension iEATViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        var xLabel = ""
        
        for i in 0...(barChartX.count - 1){
            if value >= (Double(i) - 0.5) && value <= (Double(i) + 0.5) {
                xLabel = barChartX[i]
            }
        }
        
        return xLabel
        
    }
}

extension iEATViewController: DelegateDidDismissPopover { //protocol STEP 5
    func upDataUI(sender: FoodItemTableViewController) {
        refreshBarChart()
    }
}


