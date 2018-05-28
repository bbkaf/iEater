//
//  BatteryVer2ViewController.swift
//  myCalandar
//
//  Created by HankTseng on 2017/9/18.
//  Copyright © 2017年 華宇. All rights reserved.
//

import UIKit

class BatteryVer2ViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var batteryTableView: UITableView! {
        didSet{
            self.batteryTableView.delegate = self
            self.batteryTableView.dataSource = self
        }
    }
    
    let ieat = iEATViewController()
    let nuitritionNameArray = ["熱量","蛋白","醣分","膳食纖維","膽固醇","脂肪","飽和酸(S)","單元不飽和酸(M)","多元不飽和酸(P)","鈉","鉀","鈣","鎂","鐵","鋅","磷","銅","A","E","B1","B2","B3","B6","B9","B12","C","ω3","ω6"]
    fileprivate var batteryArray: [[String: String]] = []
    var suggestionFoodArray:[String] = []
    var calculateNutritionArray = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
    let suggestionFoodDic = ["膳食纖維":["黑木耳","黑芝麻","山粉圓","(大)紅豆","綠豆","黑巧克力(85%)","燕麥","燙青菜","蠶豆","可可粉(純)"],"鈣":["山粉圓","黑芝麻","髮菜","脫脂牛奶","小魚乾"],"鎂":["海帶","黑芝麻","可可粉(純)","南瓜籽","葵瓜籽","腰果","杏仁果"],"鐵":["豬血湯","豬肝湯","牛排","髮菜"],"鋅":["牡蠣","滷豬腳","螃蟹","黑木耳","牛肋條","南瓜籽","香菇","可可粉(純)"],"磷":["滷豬腳","南瓜籽","雞蛋豆腐","可可粉(純)","黑木耳","牛奶"],"A":["胡蘿蔔","雞肝","小番茄","海帶","香菜","紅肉甘薯","豬肝","紅鳳菜","莧菜","菠菜"],"E":["黑芝麻油","紅豆","綠豆","蠶豆"],"B1":["葵瓜子","絲瓜花","豬瘦肉","黑芝麻"],"B2":["豬肝湯","香菇","雞肝"],"B3":["香菇","花生","豬肝湯","雞肉"],"B6":["開心果","麥片","黑木耳","雞肉","豬耳朵","大蒜","瘦牛肉"],"B9":["豬肝湯","雞肝","綠豆","香菇","菠菜","空心菜","蛋黃","葵瓜子"],"B12":["蜆","牡蠣","文蛤","豬肝湯","雞肝","鯖魚"],"C":["糯米椒","芭樂","青椒","甜椒","奇異果","木瓜","青花菜","草莓","花椰菜","苦瓜"],"單元不飽和酸(M)":["橄欖油","芥花油"],"ω3":["魚油","生魚片","鯖魚","鮭魚","鮪魚"]]
    
    let lackingProblemDic =
        ["醣分":"人體最主要的熱量來源，雖然在減肥還是要吃點醣類喔～",
         "熱量":"提供身體運作最重要的能量，雖然在減肥還是要吃到足夠的熱量喔～",
         "蛋白":"修復身體細胞最重要的營養素，現代人蛋白質攝取量往往超過日常所需，建議多攝取植物性蛋白質。",
         "膳食纖維":"膳食纖維可促進消化降低罹患結腸癌的風險，另外膳食纖維可與膽酸鹽相結合，減少脂肪及膽固醇的吸收可預防心血管疾病。",
         "鈣":"鈣缺乏容易造成骨骼脆弱，血液偏酸等症狀。",
         "鎂":"鎂缺乏容易造成焦慮，高血壓，心律不整等症狀。",
         "鐵":"鐵以各種性式存在於人體中，例如運送氧的血紅蛋白或傳輸電子的細胞色素，缺鐵性貧血是缺鐵的直接後果。",
         "鋅":"鋅缺乏易造成免疫力下降、食慾不振、前列腺肥大、男性生殖功能減退、動脈硬化與貧血等問題。攝取足量的鋅有助於增強記憶力，促進傷口癒合，目前已知的含鋅酵素超過３００多種，鋅位於催化中心，或穩定酶蛋白質的立體結構，缺乏鋅將導致酵素失去活性。",
         "磷":"磷參與人體能量代謝與血液酸鹼平衡，如三磷酸腺芉(adenosine triphosphate ATP)與ADP-ATP系統(ATP為呼吸作用與光合作用中的能量儲存物質)、磷酸肌酸(phosphocreatine)由ATP與肌酸在肌肉中組成，提供肌肉所需的能量。磷缺乏會造成骨質流失、心肌病變、白血球功能減弱、橫紋肌溶解等症狀。",
         "A":"維生素Ａ的前體是存在於多種植物中的胡蘿蔔素，人體通常將維生素Ａ轉為視黃醇儲存於肝臟中，維生素Ａ是視網膜內感光色素的組成部分，若缺乏易導致夜盲症與結膜表皮組織化造成淚腺阻塞，俗稱乾眼症，甚至引發結膜炎。另外維生素Ａ也是骨髓細胞分化時的調節因素，缺乏時會影響造血功能而導致貧血、免疫力下降等症狀。",
         "E":"補充足量的維生素Ｅ能促進性激素分泌，使男性精子活力與數量增加；使女性雌性激素濃度增高，提高生育率並預防流產。維生素Ｅ可用作抗氧化劑，可保護維生素Ａ不受氧化破壞並加強其作用，防止血小板過度聚集，增進紅血球膜安定及紅血球的合成，並減少老人斑沉積。缺乏維生素Ｅ易導致溶血性貧血、腸胃不適、陽痿、掉髮、月經失調與末梢血液循環不良。",
         "B1":"又稱硫胺素，缺乏易導致身體敏銳度降低、腳氣病，嚴重可導致代謝性昏迷等症狀。",
         "B2":"１８７９年英國化學家布魯斯法現牛奶上面的乳清層中存在一種黃綠色的螢光色素，又稱核黃素，缺乏易導致口角炎、眼睛易疲勞、畏光、視力模糊、眼睛痠痛。",
         "B3":"又稱菸鹼酸，缺乏易導致疲勞、頭痛、食欲不振、胃酸缺乏、對稱性皮膚炎、神經症狀等等。過量攝取易導致感臟損壞。",
         "B6":"女性雌激素代謝需要維生素B6，許多女性會因服用避孕藥導致情緒悲觀、脾氣暴躁等症狀，每日補充６０毫克(每日所需40倍)就可以緩解症狀。女性若有PMS困擾可攝取50~100毫克維生素B6便可完全緩解。",
         "B9":"又稱葉酸(來源於拉丁文的葉子folium 由H · K · Mitchell，1941與他的同事首次從波菜葉純化出來，在快速的細胞分裂和生長過程(如嬰兒發育、懷孕)中有尤其重要的作用，由於葉酸對神經管的形成有重要作用，因此孕婦在懷孕前攝入足夠的葉酸對胎兒正常發育很重要。",
         "B12":"維生素B12可以治療肝臟疾病(肝炎、肝硬化)，促進紅血球的形成與再生，預防貧血、維持神經系統的正常功能、促使注意力集中、增進記憶力與平衡感、抵抗神經疾病如神經炎、神經萎縮、憂鬱症等等。維生素B12一但經過高溫加熱和遇上維生素C就會失效。",
         "C":"攝取足量的維生素C有助於避免壞血症、預防牙齦出血、口臭、青光眼，維生素Ｃ同時可以增強血管組織和減少血液中的膽固醇含量，對於動脈硬化性心血管疾病與高血壓、中風等成人病都有很好的預防效果。水晶體和視網膜都含有高濃度的維生素C，缺乏時水晶體中的膠原質會失去透明性而產生白內障，缺乏維生素C時膽固醇不易分解成膽酸，而使血清膽固醇提高，容易導致血管粥狀硬化與血栓症。",
         "單元不飽和酸(M)":"單元不飽和脂肪酸(M)可降低LDL(壞膽固醇)、稍微升高HDL(好膽固醇)、兼具抗氧化劑、保護動脈，抵抗氧化造成的傷害。琉球人攝取的單元不飽和脂肪酸(M)佔整體脂肪的50%，血液中的飽和脂肪酸(S):單元不飽和脂肪酸(M):多元不飽和脂肪酸(P) = 20:50:30。",
         "ω3":"ω3脂肪酸可以降低血壓、降低三酸甘油酯、降低LDL，ω3有血小板抑制劑的效果，可以避免血小板在冠狀動脈形成血塊，使血液變得稀薄，較能自由流動，非常有助於預防心血管疾病。琉球人一週吃三次魚，血液中ω3脂肪酸濃度為美國人的三倍，琉球人攝取的ω3:ω6比例為1:3，現代製油工業發達導致人們往往食用過量的植物油，如沙拉油、大豆油、玉米油、葵花油等等，導致ω6的攝取量常常達到ω3的20~30倍，當ω3:ω6比例超過1:20時會產生壞的花生油酸，容易導致癌症、動脈硬化、心肌梗塞、腦中風、過敏等等疾病，調整ω3與ω3的比例最有效率的辦法就是提高多脂魚肉與魚油的攝取量，並以單元不飽和脂肪酸的油品(如橄欖油、芥花油)來取代富含多元不飽和脂肪酸的油品(如沙拉油、大豆油、玉米油、葵花油)。"]
    
    let simpleLackingProblemDic =
        ["醣分":"人體最主要的熱量來源，雖然在減肥還是要吃點醣類喔～",
         "熱量":"提供身體運作最重要的能量，雖然在減肥還是要吃到足夠的熱量喔～",
         "蛋白":"修復身體細胞最重要的營養素，現代人蛋白質攝取量往往超過日常所需，建議多攝取植物性蛋白質。",
         "膳食纖維":"膳食纖維可促進消化降低罹患結腸癌的風險，另外膳食纖維可與膽酸鹽相結合，減少脂肪及膽固醇的吸收可預防心血管疾病。",
         "鈣":"鈣缺乏容易造成骨骼脆弱，血液偏酸等症狀。",
         "鎂":"鎂缺乏容易造成焦慮，高血壓，心律不整等症狀。",
         "鐵":"鐵以各種性式存在於人體中，例如運送氧的血紅蛋白或傳輸電子的細胞色素，缺鐵性貧血是缺鐵的直接後果。",
         "鋅":"鋅缺乏易造成免疫力下降。攝取足量的鋅有助於增強記憶力，促進傷口癒合，目前已知的含鋅酵素超過３００多種，缺乏鋅將導致酵素失去活性。",
         "磷":"磷參與人體能量代謝與血液酸鹼平衡，提供肌肉所需的能量。磷缺乏會造成骨質流失、心肌病變、白血球功能減弱、橫紋肌溶解等症狀。",
         "A":"維生素Ａ的前體是存在於多種植物中的胡蘿蔔素，維生素Ａ是視網膜內感光色素的組成部分，若缺乏易導致夜盲症，甚至引發結膜炎。缺乏時會影響造血功能而導致貧血、免疫力下降等症狀。",
         "E":"補充足量的維生素Ｅ能促進性激素分泌，提高生育率並預防流產。維生素Ｅ可用作抗氧化劑，保護維生素Ａ不受氧化破壞並加強其作用。缺乏維生素Ｅ易導致末梢血液循環不良。",
         "B1":"缺乏易導致身體敏銳度降低、腳氣病，嚴重可導致代謝性昏迷等症狀。",
         "B2":"１８７９年英國化學家布魯斯法現牛奶上面的乳清層中存在一種黃綠色的螢光色素，又稱核黃素，缺乏易導致口角炎、眼睛易疲勞、畏光、視力模糊、眼睛痠痛。",
         "B3":"又稱菸鹼酸，缺乏易導致疲勞、頭痛、食欲不振、胃酸缺乏、對稱性皮膚炎、神經症狀等等。過量攝取易導致感臟損壞。",
         "B6":"女性雌激素代謝需要維生素B6，許多女性會因服用避孕藥導致情緒悲觀、脾氣暴躁等症狀，每日補充６０毫克(每日所需40倍)就可以緩解症狀。女性若有PMS困擾可攝取50~100毫克維生素B6便可緩解。",
         "B9":"又稱葉酸，在快速的細胞分裂和生長過程(如嬰兒發育、懷孕)中有尤其重要的作用，由於葉酸對神經管的形成有重要作用，因此孕婦在懷孕前攝入足夠的葉酸對胎兒正常發育很重要。",
         "B12":"維生素B12可以治療肝臟疾病(肝炎、肝硬化)，促進紅血球的形成與再生，預防貧血、維持神經系統的正常功能、促使注意力集中、增進記憶力與平衡感、抵抗神經疾病如神經炎、神經萎縮、憂鬱症等等。維生素B12一但經過高溫加熱和遇上維生素C就會失效。",
         "C":"維生素C有助於避免壞血症、預防牙齦出血，維生素Ｃ同時可以增強血管組織和減少血液中的膽固醇含量，對於動脈硬化性心血管疾病與高血壓、中風等成人病都有很好的預防效果。水晶體和視網膜都含有高濃度的維生素C，缺乏時水晶體中的膠原質會失去透明性而產生白內障，缺乏維生素C時膽固醇不易分解成膽酸，而使血清膽固醇提高，容易導致血管粥狀硬化與血栓症。",
         "單元不飽和酸(M)":"單元不飽和脂肪酸(M)可降低LDL(壞膽固醇)、稍微升高HDL(好膽固醇)、保護動脈。琉球人攝取的單元不飽和脂肪酸(M)佔整體脂肪的50%。",
         "ω3":"ω3脂肪酸可以降低血壓、降低三酸甘油酯、降低LDL，ω3有血小板抑制劑的效果，可以避免血小板在冠狀動脈形成血塊，使血液變得稀薄，較能自由流動，非常有助於預防心血管疾病。攝取最有效率的辦法就是提高多脂魚肉與魚油的攝取量，並以單元不飽和脂肪酸的油品(如橄欖油、芥花油)來取代富含多元不飽和脂肪酸的油品(如沙拉油、大豆油、玉米油、葵花油)。"]
    
    var lackingNuitritionArray:[String] = []
    
    override func awakeFromNib() {
        //ESTabBar用的
        self.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(), title: "ANLS", image: UIImage(named: "Class-100"), selectedImage: UIImage(named: "Class Filled-100"))
        //ESTabBar用的
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.calculateNuitrition(days: 3)
        batteryTableView.estimatedRowHeight = 120
        batteryTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        batteryArray = []
        let anotherQuaneForMyRecipe = DispatchQueue(label: "calculateNuitrition(days: 3)")
        anotherQuaneForMyRecipe.async {
            self.calculateNuitrition(days: 3)
            DispatchQueue.main.async {
                self.batteryTableView.reloadData()
                print("battery viewDidAppear")
            }
        }
    }
    
    func calculateNuitrition(days: Int){
        let currentOrder = order
        for i in 0...days - 1 {
            order = todayOrder - i //count today yesterday yesyesterday
            let ratio = 0.6 * (pow(0.5,Double(i)))
            ieat.loadEntryFromCoreData()
            for i in 0...nuitritionArray.count - 1{
                calculateNutritionArray[i] += nuitritionArray[i] * ratio
            }
        }
        
        let totalSMP = ((calculateNutritionArray[6] + calculateNutritionArray[7] + calculateNutritionArray[8]))
        var calculateSRatio = 0.0
        var calculateMRatio = 0.0
        var calculatePRatio = 0.0
        if totalSMP != 0 {
            calculateMRatio = (calculateNutritionArray[7] / totalSMP) * 100.0
            calculatePRatio = (calculateNutritionArray[8] / totalSMP) * 100.0
            calculateSRatio = 100.0 - calculateMRatio - calculatePRatio
            
        }
        /*
        DispatchQueue.main.async {
            self.SMPButton.setTitle("S:M:P = \(calculateSRatio):\(calculateMRatio):\(calculatePRatio)", for: .normal)
            let omega6vers3 = self.calculateNutritionArray[27] / self.calculateNutritionArray[26]
            
            if self.calculateNutritionArray[27] != 0 && self.calculateNutritionArray[26] != 0 {
                self.omega3vs6Button.setTitle("ω3:ω6 = 1:\((NSString(format: "%.1f", omega6vers3)))", for: .normal)
            }else{
                self.omega3vs6Button.setTitle("ω3:ω6 = no data", for: .normal)
            }
        }
        */
        for i in 0...calculateNutritionArray.count - 1 {
            
            if  nuitritionNameArray[i] != "膽固醇" && nuitritionNameArray[i] != "脂肪" && nuitritionNameArray[i] != "鈉" && nuitritionNameArray[i] != "鉀" && nuitritionNameArray[i] != "銅" && nuitritionNameArray[i] != "飽和酸(S)" && nuitritionNameArray[i] != "單元不飽和酸(M)" && nuitritionNameArray[i] != "多元不飽和酸(P)" && nuitritionNameArray[i] != "ω3" && nuitritionNameArray[i] != "ω6" {
                lackingNuitritionArray.append(nuitritionNameArray[i])
                batteryArray.append([ "name": nuitritionNameArray[i], "amount": "\(Int(calculateNutritionArray[i]))", "description": simpleLackingProblemDic[nuitritionNameArray[i]] ?? "ha"])
            }
        }
        
        var smp = 0
        if calculateMRatio != 0 && calculateSRatio != 0 && calculatePRatio != 0 {
            smp = Int(calculateMRatio / (calculateSRatio + calculatePRatio) * 80)
        }
        
        
        var ω3ω6 = 0
        if self.calculateNutritionArray[27] != 0 && self.calculateNutritionArray[26] != 0 {
            ω3ω6 = Int(self.calculateNutritionArray[26] / self.calculateNutritionArray[27] * 3 * 80)
        }
        
        print("ω3ω6ω3ω6\(ω3ω6)")
        batteryArray.append(["name":"單元不飽和酸(M)", "amount":"\(smp)", "description":simpleLackingProblemDic["單元不飽和酸(M)"]!])
        batteryArray.append(["name":"ω3", "amount":"\(ω3ω6)", "description":simpleLackingProblemDic["ω3"]!])
        print(batteryArray)
        defer { //defer表示在func結束前做的事情
            order = currentOrder
            ieat.loadEntryFromCoreData()
            calculateNutritionArray = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
            print("in defer state this is order \(order)")
            print("orderInOrderArrayIndex is \(orderInOrderArrayIndex)")
        }
    }
    
    //MARK: TableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return batteryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "batteryCellVer2", for: indexPath) as! BatteryCellver2TableViewCell
        cell.dic = batteryArray[indexPath.row]
        cell.showData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "batteryCellVer2", for: indexPath) as! BatteryCellver2TableViewCell
        print("didEndDisplaying")
        cell.circleImage.layer.removeAllAnimations()
        cell.circleImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0)
    }
    
    
    
    
    
    
    
    
}
