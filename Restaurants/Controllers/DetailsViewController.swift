//
//  DetailsViewController.swift
//  Restaurants
//
//  Created by Branko Crnogorac on 07.10.2017..
//  Copyright © 2017. Branko Crnogorac. All rights reserved.
//

import UIKit
import CoreData
import Material
import MapKit

class DetailsViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
    
    var imagechanged: Bool = false
    var isImageSet: Bool = false
    var imagePicker: UIImagePickerController!
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var addview: UIView!
    var donebutton: UIButton!
    var label = UILabel(frame: CGRect(x:0, y: 0,width: 200,height: 21))
    var selectedPin: MKPointAnnotation = MKPointAnnotation()
    fileprivate var nameField: TextField!
    fileprivate var addressField: TextField!
    let imageService = ImageService()

    convenience init(pin:  MKPointAnnotation){
        self.init()
        self.selectedPin = pin
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        prepareImageView()
        prepareNameInputField()
        prepareAddressInputField()
        prepareDoneButton()
        prepareLabels()
        prepareAddView()
        prepareScrollView()
        prepareView()
        prepareTransition()
   
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareTransition(){
        motionModalTransitionType = .autoReverse(presenting: .cover(direction: .up))
    }
    
    func prepareScrollView(){
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.backgroundColor = Color.blue.base
        scrollView.contentSize = CGSize(width: self.view.bounds.width, height: 930)
        scrollView.addSubview(imageView)
        scrollView.addSubview(addview)
        
    }
    
    func prepareAddView(){
        addview = UIView()
        addview.backgroundColor = Color.blue.base
        addview.frame = CGRect(x: 0, y: 410, width: self.view.bounds.width, height: 500)
        
        addview.layout(label).center(offsetX: 0, offsetY: -235)
        addview.layout(nameField).center(offsetX: 0, offsetY: -170).left(20).right(20)
        addview.layout(addressField).center(offsetX: 0, offsetY: -80).left(20).right(20)
        addview.layout(donebutton).center(offsetX: 0, offsetY: 10)
        
        
    }
    
    
    func prepareLabels(){
        label.textAlignment = NSTextAlignment.center
        label.text = "Press the icon twice to set a picture"
        label.textColor = Color.grey.lighten5
        label.font  =  RobotoFont.regular(with: 18)
        
    }
    
    func prepareDoneButton(){
        
        donebutton =  UIButton(frame: CGRect(x:0,y:0,width: self.view.bounds.width ,height: 70))
        donebutton.setTitle("Done", for: .normal)
        donebutton.titleLabel?.font = RobotoFont.regular(with: 25)
        donebutton.setTitleColor(Color.grey.lighten5, for: .normal)
        donebutton.backgroundColor = Color.blue.base
        donebutton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        
    }
    
    func prepareView(){
        
        self.view.backgroundColor = Color.blue.base
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector (dismissKeyboard))
        
        view.addSubview(scrollView)
        view.addGestureRecognizer(tap)
        
        
    }
    
    func prepareAddressInputField(){
        addressField = TextField()
        addressField.placeholder = selectedPin.subtitle!
        addressField.detail = "Please enter new address to modify"
        addressField.dividerActiveColor = Color.white
        addressField.textColor = Color.grey.lighten5
        addressField.leftViewActiveColor = Color.grey.lighten5
        addressField.placeholderActiveColor = Color.grey.lighten5
        addressField.placeholderNormalColor = Color.grey.lighten5
        addressField.clearButtonMode = .whileEditing
        
    }
    
    func prepareNameInputField(){
        nameField = TextField()
        nameField.placeholder = selectedPin.title!
        nameField.detail = "Please enter new name to modify"
        nameField.dividerActiveColor = Color.white
        nameField.textColor = Color.grey.lighten5
        nameField.leftViewActiveColor = Color.grey.lighten5
        nameField.placeholderActiveColor = Color.grey.lighten5
        nameField.placeholderNormalColor = Color.grey.lighten5
        nameField.clearButtonMode = .whileEditing
    }

    func prepareImageView(){
    
        checkPicture()
        
        imageView.backgroundColor = Color.grey.lighten5
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        
        imageView.frame = CGRect(x: 0, y: -20, width: self.view.bounds.width, height: 430)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(tapDetected))
        singleTap.numberOfTapsRequired = 2
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(singleTap)
        
    }
    
    func checkPicture(){
        
        let fetchRequest:NSFetchRequest<Picture> = Picture.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", selectedPin.title!)
        
        do{
            let searchresults = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest)
            if searchresults.count > 0{
                isImageSet = true
                print(searchresults)
                let picture = searchresults[0]
                let imagename: String = picture.file_name!
                
                if let image =  imageService.load(fileName: imagename)
                {
                    imageView    = UIImageView(image: image)
                }
                
                
            }else{
                print(searchresults)
                imageView = UIImageView(image: UIImage(named: "new.jpg"))
            }
            
            
        }catch let error{
            print(error)
        }
        
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func updateRestaurant() {
        
        let fetchRequest:NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", selectedPin.title!)
        
        let fetchRequestPic:NSFetchRequest<Picture> = Picture.fetchRequest()
        fetchRequestPic.predicate = NSPredicate(format: "name == %@", selectedPin.title!)
        
        do{
            let searchresults = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequest)
            let searchresultsPic = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchRequestPic)
            var picture: Picture = Picture()
            if searchresultsPic.count > 0 {
                
                picture = searchresultsPic[0]
                if(nameField.text! != ""){
                    picture.setValue(nameField.text!, forKey: "name")
                }

                
            }
            let restaurant = searchresults[0]
            
            if(nameField.text! != ""){
            restaurant.setValue(nameField.text!, forKey: "name")
            }
            if(addressField.text! != ""){
            restaurant.setValue(addressField.text!, forKey: "address")
            }
     
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()

            
        }catch let error{
            print(error)
        }
        
        
     
    }
    
    
    func createImage() {
       
        if isImageSet{
            
            if let oldfilename = CoreDataStack.sharedInstance.returnUniqueIDPicture(restaurantName: selectedPin.title!){
            imageService.delete(fileName: oldfilename)
             CoreDataStack.sharedInstance.clearDataWithAtributte(entity: "Picture", attribute: "file_name", value: oldfilename)
            }
            
        }
        

        
        if let image = imageView.image {
            
            if let filename = imageService.save(image: image){
                
                let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
                if let picture = NSEntityDescription.insertNewObject(forEntityName: "Picture", into: context) as? Picture {
                    picture.file_name = filename
                    
                    if nameField.text! != ""{
                        picture.name = nameField.text
                    }else{
                        picture.name = nameField.placeholder
                    }
                    
                    do {
                        try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
                        
                    } catch let error {
                        print(error)
                    }
                    
                    
                }
                
            }
        }
        
   
     
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func tapDetected() {
        print("Imageview Clicked")
        
        
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func buttonAction(sender: UIButton!) {

        
        if((nameField.text! != selectedPin.title!) || (addressField.text! != selectedPin.subtitle!)){
        updateRestaurant()
        }
        if imagechanged{
            
         createImage()
        }
    
        
        
        self.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        imagechanged = true
        
    }
 

}
