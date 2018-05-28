//
//  Function.swift
//  myCalandar
//
//  Created by 華宇 on 2016/12/8.
//  Copyright © 2016年 華宇. All rights reserved.
//

import Foundation

var foodItemArrayForSpeech:[[String]] = []

var nowTime = NSDate()

var selectedTime = NSDate()

var selectedSteps = ""

let formatter = DateFormatter()

var selectedFood = "🔍"

let defaults = UserDefaults.standard

let pathOfmonththArray = Bundle.main.path(forResource: "monthArray", ofType: "txt")

let pathOffoodItemArray = Bundle.main.path(forResource: "foodItemArray", ofType: "txt")
let pathOffoodNutritionDictionary = Bundle.main.path(forResource: "foodNutritionDictionary", ofType: "txt")

//let pathOffoodArray = Bundle.main.path(forResource: "foodArray", ofType: "txt")

//let pathOfdiaryArray = Bundle.main.path(forResource: "diaryArray", ofType: "txt")


var monthArray: [[String]] = []

var fooodNutritionDictionary: [String:String] = [:]

var nuitritionMaleDailyNeeds = ["熱量": Double(weight * 35.0), "醣分": Double(weight * 4.375), "蛋白質": Double(weight * 1.2), "脂肪": Double(weight * 0.97), "膳食纖維": Double(weight * 0.35), "A":5000, "B1":1.4, "B2":1.8, "B3":22, "B5":7, "B6":1.8, "B9":300, "B12":3, "C":100, "D":7, "E":12, "H":200, "vitK": Double(weight), "Ca":800, "P": Double(weight * 15.0), "K":2000, "Mg":360, "Na":3000, "Cl":200, "S":200, "Fe":10, "Cu":2500, "I":120, "Mn":3.6, "Zn":15, "Co":1, "Mo":28, "F":5, "Cr":33, "Se":50, "膽固醇":300, "飽和脂肪酸S": Double(weight * 0.292), "單元不飽和脂肪酸": Double(weight * 0.389), "多元不飽和脂肪酸": Double(weight * 0.292), "omega3": Double(weight * 0.073), "omega6": Double(weight * 0.219)]


var nuitritionFemaleDailyNeeds = ["熱量": Double(weight * 30.0), "醣分": Double(weight * 3.75), "蛋白質": Double(weight * 1.1), "脂肪": Double(weight * 0.83), "膳食纖維": Double(weight * 0.3), "A":4200, "B1":1.1, "B2":1.5, "B3":17, "B5":7, "B6":1.5, "B9":300, "B12":3, "C":100, "D":7.0, "E":10, "H":200, "vitK": Double(weight), "Ca":700, "P": Double(weight * 14.0), "K":2000, "Mg":315, "Na":3000, "Cl":200, "S":200, "Fe":15, "Cu":2500, "I":120, "Mn":4, "Zn":12, "Co":1, "Mo":28, "F":5, "Cr":23, "Se":50, "膽固醇":300, "飽和脂肪酸S": Double(weight * 0.25), "單元不飽和脂肪酸": Double(weight * 0.33), "多元不飽和脂肪酸": Double(weight * 0.25), "omega3": Double(weight * 0.0625), "omega6": Double(weight * 0.1875)]

var nuitritionPregnantDailyNeeds = ["熱量": Double(weight * 38.0), "醣分": Double(weight * 4.75), "蛋白質": Double(weight * 1.4), "脂肪": Double(weight * 1.06), "膳食纖維": Double(weight * 0.38), "A":4200, "B1":1.1, "B2":1.5, "B3":17, "B5":9, "B6":1.5, "B9":800, "B12":3, "C":100, "D":9.0, "E":10, "H":200, "vitK": Double(weight), "Ca":1300, "P": Double(weight * 14.0), "K":2000, "Mg":355, "Na":3000, "Cl":200, "S":200, "Fe":18, "Cu":2500, "I":120, "Mn":4, "Zn":15, "Co":1, "Mo":28, "F":5, "Cr":23, "Se":50, "膽固醇":300, "飽和脂肪酸S": Double(weight * 0.317), "單元不飽和脂肪酸": Double(weight * 0.422), "多元不飽和脂肪酸": Double(weight * 0.317), "omega3": Double(weight * 0.0792), "omega6": Double(weight * 0.2375)]


var nuitritionBreastDailyNeeds = ["熱量": Double(weight * 36.0), "醣分": Double(weight * 4.5), "蛋白質": Double(weight * 1.4), "脂肪": Double(weight), "膳食纖維": Double(weight * 0.36), "A":4200, "B1":1.1, "B2":1.5, "B3":17, "B5":9, "B6":1.5, "B9":600, "B12":3, "C":100, "D":9.0, "E":10, "H":200, "vitK": Double(weight), "Ca":1300, "P": Double(weight * 14), "K":2000, "Mg":355, "Na":3000, "Cl":200, "S":200, "Fe":45, "Cu":2500, "I":120, "Mn":4, "Zn":15, "Co":1, "Mo":28, "F":5, "Cr":23, "Se":50, "膽固醇":300, "飽和脂肪酸S": Double(weight * 0.3), "單元不飽和脂肪酸": Double(weight * 0.4), "多元不飽和脂肪酸": Double(weight * 0.3), "omega3": Double(weight * 0.075), "omega6": Double(weight * 0.225)]



var whitIDaillyNeed:[String:Double]{
    get{
        return defaults.object(forKey: "whitIDaillyNeed") as? [String:Double] ?? nuitritionMaleDailyNeeds
    }
    
    set{
        defaults.set(newValue, forKey: "whitIDaillyNeed")
        defaults.synchronize()
    }
}

var specificNeeds:[String:Double]{
    get{
        return defaults.object(forKey: "specificNeeds") as? [String:Double] ?? nuitritionMaleDailyNeeds
    }
    
    set{
        defaults.set(newValue, forKey: "specificNeeds")
        defaults.synchronize()
    }
}

// SMP 3:4:3



var orderArray: [Int] {
get{
    return defaults.object(forKey: "orderArray") as? [Int] ?? []
}
set{
    defaults.set(newValue, forKey: "orderArray")
    defaults.synchronize()
}
}

var page: Int{
get{
    return defaults.object(forKey: "page") as? Int ?? 1
}
set{
return defaults.set(newValue, forKey: "page")
}
}

var diary: String = ""

var foodAmountArray: [String] = []

var foodArray: [String] = []

var step: String = ""

var nuitritionArray: [Double] = []

var photoArray: [UIImage] = []

var makeNewRecipeOrModify = ""


var recipeName: String = ""

var recipeDiary: String = ""

var recipeFoodAmountArray: [String] = []

var recipeFoodArray: [String] = []

var recipeNuitritionArray: [Double] = []

var recipePhotoArray: [UIImage] = []

//var xxlivePhoto : [String : Any]{
//get{
//    
//    if let x = defaults.object(forKey: "xxlivePhoto") as? NSData {
//        
//        let y = NSKeyedUnarchiver.unarchiveObject(with: x as Data)
//        
//        let z = y as [String : Any]
//                
//        return z
//        
//    }else{
//        return [String : Any]()
//    }
//}
//set{
//    defaults.set(NSKeyedArchiver.archivedData(withRootObject: newValue), forKey: "xxlivePhoto")
//}
//}
//
//
//
//var livePhotoArray : [[String : Any]]{
//
//get{
//    
//    if let x = defaults.object(forKey: "livePhotoArray") as? NSData {
//    
//    let y = NSKeyedUnarchiver.unarchiveObject(with: x as Data)
//    
//    let z = y as! [[String : Any]]
//    
//    return z
//        
//    }else{
//        return []
//    }
//}
//set{
//    defaults.set(NSKeyedArchiver.archivedData(withRootObject: newValue) as NSData, forKey: "livePhotoArray")
//    defaults.synchronize()
//}
//}


//let pathOffoodAmountArray = Bundle.main.path(forResource: "foodAmountArray", ofType: "txt")

var order = 0

var orderInOrderArrayIndex: Int {

get{
    
    if orderArray.contains(order) {
        
        return orderArray.index(of: order)!
        
    }else{
        
        return 999999
        
    }
}
}


var doIInitializeReferenceFiles: Int{
get{
    return defaults.object(forKey: "doIInitializeReferenceFiles") as? Int ?? 0
}
set{
    defaults.setValue(newValue, forKey: "doIInitializeReferenceFiles")
}
}

var todayOrder: Int{
get{
    return defaults.object(forKey: "todayOrder") as? Int ?? 0
}
set{
    defaults.setValue(newValue, forKey: "todayOrder")
}
}


var segueFromCalendar: Int{
get{
    return defaults.object(forKey: "segueFromCalendar") as? Int ?? 0
}
set{
    defaults.setValue(newValue, forKey: "segueFromCalendar")
}
}

var gender: String{
    get{
        return defaults.object(forKey: "gender") as? String ?? "male"
    }
    set{
        defaults.setValue(newValue, forKey: "gender")
    }
}

var age: String{
    get{
        return defaults.object(forKey: "age") as? String ?? "young"
    }
    set{
        defaults.setValue(newValue, forKey: "age")
    }
}

var weight: Double{
    get{
        return defaults.object(forKey: "weight") as? Double ?? 60.0
    }
    set{
        defaults.setValue(newValue, forKey: "weight")
    }
}

var restrintion: String{
    get{
        return defaults.object(forKey: "restrintion") as? String ?? "none"
    }
    set{
        defaults.setValue(newValue, forKey: "restrintion")
    }
}





