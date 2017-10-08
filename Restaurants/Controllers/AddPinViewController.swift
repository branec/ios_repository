//
//  AddPinViewController.swift
//  Restaurants
//
//  Created by Branko Crnogorac on 05.10.2017..
//  Copyright © 2017. Branko Crnogorac. All rights reserved.
//

import UIKit
import CoreData
import Material
import MapKit


class AddPinViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var imagePicker: UIImagePickerController!
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var addview: UIView!
    var addphotobutton: UIButton!
    var label = UILabel(frame: CGRect(x:0, y: 0,width: 200,height: 21))
    var latitude: Double  = 0.0
    var longitude: Double = 0.0
    let imageService = ImageService()
  
    
    fileprivate var nameField: TextField!
    fileprivate var addressField: TextField!


    convenience init(lat: Double, long: Double ){
        self.init()
        self.latitude = lat
        self.longitude = long
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareImageView()
        prepareNameInputField()
        prepareAddressInputField()
        addbutton()
        prepareLabels()
        prepareAddView()
        prepareScrollView()
        prepareTransition()
        prepareView()

    }
    
    func prepareView(){
        
        self.view.backgroundColor = Color.red.base
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector (dismissKeyboard))
        
        view.addSubview(scrollView)
        view.addGestureRecognizer(tap)
        
    }
    
    func prepareLabels(){
        
        label.textAlignment = NSTextAlignment.center
        label.text = "Press the icon twice to set a picture"
        label.textColor = Color.grey.lighten5
        label.font  =  RobotoFont.regular(with: 18)
    
    }
    
    func prepareScrollView(){
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.backgroundColor = Color.red.base
        scrollView.contentSize = CGSize(width: self.view.bounds.width, height: 930)
        scrollView.addSubview(imageView)
        scrollView.addSubview(addview)
    
    }
    
    func prepareAddView(){
        
        addview = UIView()
        addview.backgroundColor = Color.red.base
        addview.frame = CGRect(x: 0, y: 410, width: self.view.bounds.width, height: 500)
        
        addview.layout(label).center(offsetX: 0, offsetY: -235)
        addview.layout(nameField).center(offsetX: 0, offsetY: -170).left(20).right(20)
        addview.layout(addressField).center(offsetX: 0, offsetY: -80).left(20).right(20)
        addview.layout(addphotobutton).center(offsetX: 0, offsetY: 10)
        
    }
    
    func prepareImageView(){
        
        imageView = UIImageView(image: UIImage(named: "new.jpg"))
        imageView.backgroundColor = Color.grey.lighten5
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.frame = CGRect(x: 0, y: -20, width: self.view.bounds.width, height: 430)
        
        //Set a tap over the imageView
        let Tap = UITapGestureRecognizer(target: self, action: #selector(tapDetected))
        Tap.numberOfTapsRequired = 2
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(Tap)
        
    }
   
    
    
    func prepareTransition(){
        motionModalTransitionType = .autoReverse(presenting: .cover(direction: .up))
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //A Tap function for the imageView which opens a camera
     @objc func tapDetected() {
        
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func prepareNameInputField(){
        nameField = TextField()
        nameField.placeholder = "Name"
        nameField.detail = "Please enter full name of the restaurant"
        nameField.dividerActiveColor = Color.white
        nameField.textColor = Color.grey.lighten5
        nameField.leftViewActiveColor = Color.grey.lighten5
        nameField.placeholderActiveColor = Color.grey.lighten5
        nameField.placeholderNormalColor = Color.grey.lighten5
        nameField.clearButtonMode = .whileEditing
    }

    
    func prepareAddressInputField(){
        addressField = TextField()
        addressField.placeholder = "Address"
        addressField.detail = "Please enter correct address of the restaurant"
        addressField.dividerActiveColor = Color.white
        addressField.textColor = Color.grey.lighten5
        addressField.leftViewActiveColor = Color.grey.lighten5
        addressField.placeholderActiveColor = Color.grey.lighten5
        addressField.placeholderNormalColor = Color.grey.lighten5
        addressField.clearButtonMode = .whileEditing
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    func addbutton(){
        
        addphotobutton =  UIButton(frame: CGRect(x:0,y:0,width: self.view.bounds.width ,height: 70))
        addphotobutton.setTitle("Done", for: .normal)
        addphotobutton.titleLabel?.font = RobotoFont.regular(with: 25)
        addphotobutton.setTitleColor(Color.grey.lighten5, for: .normal)
        addphotobutton.backgroundColor = Color.red.base
        addphotobutton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
    }
    
    //Function for adding new Pin
    @objc func buttonAction(sender: UIButton!) {
        print("selected")
        
        if(nameField.text! != "" && addressField.text! != ""){
        _ = createRestaurant()
        _ = createImage()
        
        do {
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
            
        } catch let error {
            print(error)
        }
        
        
        }
        
        self.dismiss(animated: true)
    }
    
    
    func createRestaurant() -> NSManagedObject? {
        
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        if let restaurant = NSEntityDescription.insertNewObject(forEntityName: "Restaurant", into: context) as? Restaurant {
            restaurant.address = addressField.text
            restaurant.latitude = latitude
            restaurant.longitude = longitude
            restaurant.name = nameField.text
            return restaurant
        }
        return nil
    }
    
    
    func createImage() -> NSManagedObject?{
        
        var filename: String? = nil
        
        if let image = imageView.image {
           filename = imageService.save(image: image)
        }
        
        
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        if let picture = NSEntityDescription.insertNewObject(forEntityName: "Picture", into: context) as? Picture {
            if let name = filename{
                   picture.file_name = name
            }else{
                    picture.file_name = ""
            }
 
            picture.name = nameField.text
            return picture
        }
        return nil
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
    
}
