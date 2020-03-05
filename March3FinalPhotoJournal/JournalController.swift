//
//  JournalController.swift
//  March3FinalPhotoJournal
//
//  Created by Margiett Gil on 3/3/20.
//  Copyright © 2020 Margiett Gil. All rights reserved.
//

import UIKit
import DataPersistence
import AVFoundation

protocol ImagePhotoDelegate: AnyObject {
    func getImageData(_ image: ImageObject)
}

class JournalController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    public var imageObjects = [ImageObject]() {
        didSet {
            collectionView.reloadData()
        }
        
    }
    
    public var selectedImage: ImageObject?
    public var persistence = DataPersistence<ImageObject>(filename: "images.plist")
    public var newPhoto = false
    
    
    weak var imageDelegate: ImagePhotoDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        loadImageObjects()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let addPhotoVC = segue.destination as?
            AddPhotoViewController,let Indexpath = collectionView.indexPathsForSelectedItems?.first else {
                return
        }
        addPhotoVC.photosDelegate = self
        addPhotoVC.originalPhoto = imageObjects[Indexpath.row]
        print(imageObjects[Indexpath.row].description)
    
    }
    
    @IBAction func addPhotoButtonPressed(_ sender: UIBarButtonItem) {
        newPhoto = true
        showAddPhotoVC()
    }
    
    private func loadImageObjects() {
        do {
            imageObjects = try persistence.loadItems()
        } catch {
            print("could not get photos")
        }
    }
    
    private func showAddPhotoVC(_ photo: ImageObject? = nil) {
        guard let createPhotoController = storyboard?.instantiateViewController(identifier: "AddPhotoController") as? AddPhotoViewController else {
             fatalError("could not downcast to AddPhotoController")
            
        }
        createPhotoController.photosDelegate = self
        if !newPhoto {
            guard let photoData = photo?.imageData else { return }
            createPhotoController.selectedImage = UIImage(data: photoData)
            createPhotoController.originalPhoto = photo
        }
        present(createPhotoController, animated:  true )
    
    
    }
    
}
//MARK: Extensions
extension JournalController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? JournalCell else {
            fatalError("could not downcast to Journal cell")
        }
        let imageObject = imageObjects[indexPath.row]
        cell.cellDelegate = self
        cell.index = indexPath
        
        selectedImage = imageObject
        imageDelegate?.getImageData(imageObject)
        cell.configureCell(for: imageObject)
        
        return cell
    }
    
}

extension JournalController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxWidth: CGFloat = UIScreen.main.bounds.size.width
        let itemWidth: CGFloat = maxWidth * 0.80
        return CGSize(width: itemWidth, height: itemWidth)
    }
}

extension JournalController: JournalCollectionDelegate {
    func clickCell(index: Int, photoCell: JournalCell) {
        print("\(index) is clicked")
        
        guard let indexPath = photoCell.index else { return }
        
        let imageObject = imageObjects[indexPath.row]
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: "Edit", style: .default) { [weak self] alertAction in self?.showAddPhotoVC(imageObject)
            
        }
        let shareAction = UIAlertAction(title: "Share", style: .default)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] alertAction in
            self?.deletePhoto(indexPath: indexPath)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(editAction)
        alertController.addAction(shareAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated:  true)

    }
    
    private func deletePhoto(indexPath: IndexPath) {
        imageObjects.remove(at: indexPath.row)
        do{
            try persistence.deleteItem(at: indexPath.row)
            
        }catch {
            print(" there was an error deleting")
        }
    }
}

extension JournalController: AddPhotoToCollectionDelegate {
    func updateCollectionViewDelegate(image: ImageObject) {
        imageObjects.insert(image, at: 0)
        do {
            try persistence.createItem(image)
        } catch {
            print("was unable to create")
        }
    }
    
    func editPhotoDelegate(original: ImageObject, newPhoto: ImageObject) {
        let index = imageObjects.firstIndex(of: original)!
        imageObjects.remove(at: index)
        imageObjects.insert(newPhoto, at: index)
        persistence.update(original, with: newPhoto)
    }
    
            
}
