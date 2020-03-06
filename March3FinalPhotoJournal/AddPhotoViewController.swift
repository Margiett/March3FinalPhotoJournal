//
//  AddPhotoViewController.swift
//  March3FinalPhotoJournal
//
//  Created by Margiett Gil on 3/3/20.
//  Copyright © 2020 Margiett Gil. All rights reserved.
//

import UIKit
import DataPersistence
import AVFoundation
//import ImageKit

protocol AddPhotoToCollectionDelegate: AnyObject {
    func updateCollectionViewDelegate(image: ImageObject)
    func editPhotoDelegate(original: ImageObject, newPhoto: ImageObject)
}

class AddPhotoViewController: UIViewController, ImagePhotoDelegate {
    
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var textField: UITextField!
    @IBOutlet var photoImage: UIImageView!
    @IBOutlet var photoLibraryButton: UIBarButtonItem!
    @IBOutlet var cameraButton: UIBarButtonItem!
    
    private let imagePickerController = UIImagePickerController()
    
    public var dataPresistence = DataPersistence<ImageObject>(filename: "images.plist")
    
    public var imageObjects = [ImageObject]()
    
    public var originalPhoto: ImageObject?
    
    public var imageDescription = String()
    
    public var selectedImage: UIImage?
   
    
    
    weak var photosDelegate: AddPhotoToCollectionDelegate?
    public var isEditingPhoto = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        saveButton.isEnabled = false
        updateUI()

    }
    private func updateUI(){
        guard let image = originalPhoto?.imageData else {
            return
        }
        print("testing checking is this works !")
        print("here \(originalPhoto?.description ?? "")")
        
        textField.text = originalPhoto?.description
        photoImage.image = UIImage(data: image)
        if imageDescription.isEmpty {
            cameraButton.isEnabled = false
            photoLibraryButton.isEnabled = false
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        do {
            imageObjects = try dataPresistence.loadItems()
            
        } catch {
            print("is this cancel button working")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        guard let image = selectedImage else {
            print("there is no images images is nil")
            return
        }
         // the size for resizing of the image
        let size = UIScreen.main.bounds.size
        
        // we will maintain the aspect ratio of the image
        let rect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: CGPoint.zero, size: size))
        
        // resize image
        let resizeImage = image.resizeImage(to: rect.size.width, height: rect.size.height)
        print("resized image size is \(resizeImage.size)")
        
        // jpegData(compressionQuality: 1.0) converts UIImage to Data
        guard let resizedImageData = resizeImage.jpegData(compressionQuality: 1.0) else {
            return
        }  // create an ImageObject using the image selected
        let imageObject = ImageObject(imageData: resizedImageData, date: Date(), description: imageDescription)
        
        
        
        if cameraButton.isEnabled {
            photosDelegate?.updateCollectionViewDelegate(image: imageObject)
            
        } else {
            guard let original = originalPhoto else {
                print("original photo does not exsist ")
                return
            }
            photosDelegate?.editPhotoDelegate(original: original, newPhoto: imageObject)
        }
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func photoLibraryButtonPressed(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            imagePickerController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePickerController.sourceType = .photoLibrary
            
            self.present(imagePickerController, animated:  true )
        }
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion:  nil)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let journalVC = segue.destination as? JournalViewController else { return }
        
        journalVC.imageDelegate = self
        getImageData(originalPhoto!)
    }
    func getImageData(_ image: ImageObject) {
        self.photoImage.image = UIImage(data: image.imageData)
        print(image.description)
        print("getImageData")
    }
}

extension AddPhotoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text != "" && photoImage.image != nil {
            saveButton.isEnabled = true
        }
        imageDescription = textField.text ?? "no photo description"
        return true
    }
}

extension AddPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            else {
                print("image selected was not found")
                return
        }
        selectedImage = image
        photoImage.image = image
        dismiss(animated: true)
    }
}

extension UIImage {
    func resizeImage(to width: CGFloat, height: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
