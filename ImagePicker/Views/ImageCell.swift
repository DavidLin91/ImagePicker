//
//  ImageCell.swift
//  ImagePicker
//
//  Created by Alex Paul on 1/20/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit


// Step 1 (custom delegation): creating custom delegation -define protocol
protocol ImageCellDelegate: AnyObject {  // AnyObject requires ImageCellDelegate only works with class types
    
    // list required functions, initializers, variables
    func didLongPress(_ imageCell: ImageCell)

}




class ImageCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    // step 2 (custom delegation): define optional delegate variable
    weak var delegate: ImageCellDelegate?
    
    // Step 1: long press setup
    private lazy var longPressedGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer()
        gesture.addTarget(self, action: #selector(longPressAction(gesture:)))
        return gesture
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 20.0
        backgroundColor = .orange
        
        // step 3: long press setup - added gesture to view
        addGestureRecognizer(longPressedGesture)
        
    }
    
    // Step 2: long press setup
    // function gets called when long press is activated
    @objc private func longPressAction(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began { // if gesture is active
            gesture.state = .cancelled
            return
        }
        print("long pressed button")
        // Step 3 (custom delegation): explicitly -use delegate objec to notify of any updates
        // notify the imagesViewCOntroller when the user long presed on the cel
        delegate?.didLongPress(self)
        // cell.delegate = sef
        //imagesViewCOntroller.didLongPress(:)
        
    }
    
    public func configureCell(imageObject: ImageObject) {
        guard let image = UIImage(data: imageObject.imageData) else {
            return
        }
        imageView.image = image
    }
    
}
