//
//  ViewController.swift
//  ImagePicker
//
//  Created by Alex Paul on 1/20/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import AVFoundation  // we want to use AVMakeRect() to maintain image aspect ratio

class ImagesViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var imageObjects = [ImageObject]()
    private let imagePickerController = UIImagePickerController()
    private let dataPersistence = PersistenceHelper(filename: "images.plist")
    
    
    private var selectedImage: UIImage? {
        didSet {
            //gets called when new image is selected
            appendNewPhotoToCollection()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Set UIImagePickerController delegate as this view controller
        imagePickerController.delegate = self
        loadImageObjects()
    }
    
    private func loadImageObjects() {
        do {
            imageObjects = try dataPersistence.loadEvents()
        } catch {
            print("loading objects error: \(error)")
        }
    }
    
    private func appendNewPhotoToCollection() {
        guard let image = selectedImage else {
            print("image is nil")
            return
        }
        
        
        // resize image
        let size = UIScreen.main.bounds.size
        
        // we will maintain the aspect ratio of the image
        let rect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(origin: CGPoint.zero, size: size))
        
        // resize image
        let resizeImage = image.resizeImage(to: rect.size.width, height: rect.size.height)
        
        print("resized image size is \(resizeImage.size)")
        
        guard let resizedImageData = resizeImage.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        // create an image object using the image selected
        let imageObject = ImageObject(imageData: resizedImageData, date: Date())
        
        //add new object to image object array "[ImageObject]"
        
        //imageObjects.insert(imageObject, at: 0)
        imageObjects.append(<#T##newElement: ImageObject##ImageObject#>)
        
        // create an indexPath for insertion into collection view
        let indexPath = IndexPath(row: 0, section: 0)
        
        // insert new cell into collection view
        collectionView.insertItems(at: [indexPath])
        
        
        // persist imageObject to documents directory
        do {
            try dataPersistence.create(event: imageObject)
        } catch{
            print("Saving error \(error)")
        }
    }
    
    
    @IBAction func addPictureButtonPressed(_ sender: UIBarButtonItem) {
        //present an action sheet to the user
        // action: camera, photo library, cancel
        //creates the actions
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) {[weak self] alertAction in self?.showImageController(isCameraSelected: true)
            
        }
        
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { [weak self] alertAction in
            self?.showImageController(isCameraSelected: false)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        
        // check if camera is available, if camera is not available, the app will crash
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(cameraAction)
        }
        
        // adds the action to alert controller
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    
    private func showImageController(isCameraSelected: Bool) {
        //source type default will be .photoLibrary
        
        imagePickerController.sourceType = .photoLibrary
        
        if isCameraSelected {
            imagePickerController.sourceType = .camera
        }
        
        present(imagePickerController, animated: true)
        
    }
    
    
    
}

// MARK: - UICollectionViewDataSource
extension ImagesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // step 4 (crete custom delegation) - must have an instance of object B
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCell else {
            fatalError("could not downcast to an ImageCell")
        }
        let imageObject = imageObjects[indexPath.row]
        
        // Step 5 (create custom delegate) - set delegate object
        cell.delegate = self
        
        cell.configureCell(imageObject: imageObject)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ImagesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxWidth: CGFloat = UIScreen.main.bounds.size.width
        let itemWidth: CGFloat = maxWidth * 0.80
        return CGSize(width: itemWidth, height: itemWidth)  }
}


extension ImagesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // we need to access the UIImagePickerController.infoKey.originalImage key to get the UIImage that was selected
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            print("image selection not found")
            return
        }
        selectedImage = image
        
        // dismiss the UIImagePickerController
        dismiss(animated: true)
    }
}


// Step 6 (create custom delegation) - conform to delegate
extension ImagesViewController: ImageCellDelegate {
    func didLongPress(_ imageCell: ImageCell) {
        
        guard let indexPath = collectionView.indexPath(for: imageCell) else {
            return
        }
        
        
        
        // present an action sheet
        
        
        //action: delete, cancel
        let alertCOntroller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
            [weak self] alertAction in self?.deleteImageObject(indexPath: indexPath)
        }
        let cancelActiom = UIAlertAction(title: "Cancel", style: .cancel)
        alertCOntroller.addAction(deleteAction)
        alertCOntroller.addAction(cancelActiom)
        present(alertCOntroller,animated: true)
    }
    
    
    private func deleteImageObject(indexPath: IndexPath){
        
        
        do {
            // delete image object from documents directory
            try dataPersistence.delete(event: indexPath.row)
            
            // delete imageObjecy from imageObjects
            imageObjects.remove(at: indexPath.row)
            
            // delete cell from the collection view
            collectionView.deleteItems(at: [indexPath])
        } catch {
            print("error deleting item: \(error)")
        }
    }
    
    
}






// more here: https://nshipster.com/image-resizing/
// MARK: - UIImage extension
extension UIImage {
    func resizeImage(to width: CGFloat, height: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

