//
//  iPetViewController.swift
//  myCalandar
//
//  Created by 華宇 on 2016/12/13.
//  Copyright © 2016年 華宇. All rights reserved.
//

import UIKit
import CoreData

class iPetViewController: UIViewController {

    
    var howManyEntrysInUsersRecipes = 0 {
        didSet{
            if oldValue != howManyEntrysInUsersRecipes{
                DispatchQueue.main.async {
                    self.recipeCollectionView.reloadData()
                }
            }
        }
    }
    
    var indexpathOfRecipeCell = 0
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var recipeCollectionView: UICollectionView!
    
    @IBAction func addButtonClick(_ sender: Any) {
        
        makeNewRecipeOrModify = "new"
        
        recipeDiary = ""
        
        recipeFoodAmountArray = []
        
        recipeFoodArray = []
        
        recipeNuitritionArray = Array(repeating: 0.0, count: 28)
        
        recipePhotoArray = []

        performSegue(withIdentifier: "popoverToMakeRecipe", sender: nil)
    }
    
    override func awakeFromNib() {
        //ESTabBar用的
        self.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(), title: "Home", image: UIImage(named: "home"), selectedImage: UIImage(named: "home_1"))
        //ESTabBar用的
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        setupCollectionView()
        
        print("iPetVC VIewDidLoad")
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        let anotherQuaneForMyRecipe = DispatchQueue(label: "loadMyRecipe")
        anotherQuaneForMyRecipe.async {
            self.loadDataFromCoreData(resultID: 0)
            
        }
        

        
    }
    
    
    
    func loadDataFromCoreData(resultID: Int){
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UsersRecipes")
        
        request.returnsObjectsAsFaults = false
        
        do
        {
            let results = try context.fetch(request)
            
            howManyEntrysInUsersRecipes = results.count
            
            if results.count != 0 {
                print("coreData UsersRecipes 裡有\(results.count)組資料")
                
                
                let result = results[resultID] as! NSManagedObject
                
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
    
    
    func setupCollectionView(){
        
        //for recipeCollectionView
        let recipeLayout = UICollectionViewFlowLayout()
        
        recipeLayout.minimumLineSpacing = recipeCollectionView.frame.width * 0.015
        recipeLayout.minimumInteritemSpacing = recipeCollectionView.frame.width * 0.015
        recipeCollectionView.collectionViewLayout = recipeLayout
        
        recipeCollectionView.register(RecipeCollectionViewCell.self, forCellWithReuseIdentifier: "recipeCell")
        recipeCollectionView.delegate = self
        
        recipeCollectionView.dataSource = self
        
        recipeCollectionView.backgroundColor = UIColor.clear
        
    }
}

extension iPetViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return howManyEntrysInUsersRecipes
    }
    
    // dequeue & set up
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let recipeCell = recipeCollectionView.dequeueReusableCell(withReuseIdentifier: "recipeCell", for: indexPath) as! RecipeCollectionViewCell
        
        recipeCell.layer.borderWidth = 0.1
        recipeCell.layer.cornerRadius = 5
        recipeCell.awakeFromNib()
        return recipeCell
    }
    
    // populate the data of given cell
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let recipeCell = cell as! RecipeCollectionViewCell
        
        self.loadDataFromCoreData(resultID: indexPath.row)
        print(recipeName)
        recipeCell.label.text = recipeName
        recipeCell.image.image = recipePhotoArray.count != 0 ? recipePhotoArray[0] : UIImage(named: "Dining Room resize Filled-100")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width * 0.32, height: collectionView.frame.width * 0.32)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("click \(indexPath.row) cell")
        
        makeNewRecipeOrModify = "modify"
        
        self.indexpathOfRecipeCell = indexPath.row
        
        performSegue(withIdentifier: "popoverToMakeRecipe", sender: nil)
    
    }
    
}


extension iPetViewController: UIPopoverPresentationControllerDelegate{
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mrvc = segue.destination as? makeRecipeViewController{
            if let ppc = mrvc.popoverPresentationController{
                ppc.delegate = self
                ppc.sourceView = self.view
                ppc.sourceRect = CGRect(x:  self.view.bounds.midX, y:self.view.bounds.midY, width: 0, height: 0)
            }
            mrvc.theIndexPathRaw = indexpathOfRecipeCell
            mrvc.loadEntryFromCoreData()    
        }
    }
    
//    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
//        return .none
//    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
    }
}
