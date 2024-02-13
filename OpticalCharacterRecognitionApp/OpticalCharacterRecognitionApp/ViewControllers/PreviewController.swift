//
//  PreviewViewController.swift
//  OpticalCharacterRecognitionApp
//
//  Created by 동준 on 2/1/24.
//

import UIKit

final class PreviewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var capturedImageCount: UILabel!
    
    private var imageIndex = 0
    private let imageManager = ImageManager.shared
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        imageManager.originalPhotos.removeFirst()
        selectImage(index: imageIndex)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(Swipe(sender:)))
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(Swipe(sender:)))
        
        swipeLeft.direction = .left
        swipeRight.direction = .right
        
        self.view.addGestureRecognizer(swipeLeft)
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @objc func Swipe(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .right:
            selectImage(index: -1)
            print("left이동")
        case .left:
            selectImage(index: 1)
            print("right이동")
        default:
            break
        }
    }
    
    @IBAction func counterclockwiseButton(_ sender: Any) {
        if let image = imageView?.image {
            if let ciImage = CIImage(image: image) {
                imageView?.image = imageManager.createRotatedImage(from: ciImage )
            }
        }
    }
    
    
    @IBAction func removeImageButton(_ sender: UIButton) {
        if imageManager.originalPhotos.count == 0 {
            selectImage(index: 0)
        }else if imageManager.originalPhotos.count == 1 {
            imageManager.originalPhotos.removeLast()
            imageManager.originalPhotos.insert(UIImage(named: "noImage")!, at: 0)
            selectImage(index: -1)
        } else {
            imageManager.originalPhotos.removeLast()
            selectImage(index: -1)
        }
    }
    
    
    private func selectImage(index: Int) {
        
        imageIndex += index
        if imageIndex < 0 {
            imageIndex = 0
        } else if imageIndex == imageManager.originalPhotos.count {
            imageIndex = imageManager.originalPhotos.count - 1
        }
        capturedImageCount.text = "\(imageIndex + 1)/\(imageManager.originalPhotos.count - 1)"
        imageView.image = imageManager.originalPhotos[imageIndex]
        
        if let image = imageView.image {
            processImage(input: image)
        }
    }
    
    private func processImage(input: UIImage) {
        
        if let flattenedImage = imageManager.imageForRectanglesInImage(input: input) {
            
            let context = CIContext(options: nil)
            guard let cgImage = context.createCGImage(flattenedImage, from: flattenedImage.extent) else {
                return
            }
            let uiImage = UIImage(cgImage: cgImage)
            
            imageView?.image = uiImage
        }
    }
}
