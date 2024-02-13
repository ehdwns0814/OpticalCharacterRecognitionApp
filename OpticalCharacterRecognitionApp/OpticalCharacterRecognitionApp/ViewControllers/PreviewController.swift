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
    
//    private var imageArray = [UIImage]()
    private var imageIndex = 0
    private let imageManager = ImageManager.shared
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        imageArray.append(UIImage(named: "sample")!)
        imageArray.append(UIImage(named: "sample4")!)
        imageArray.append(UIImage(named: "sample1")!)
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

    
    func selectImage(index: Int) {
        
        imageIndex += index
        if imageIndex < 0 {
            imageIndex = 0
        } else if imageIndex == imageManager.originalPhotos.count {
            imageIndex = imageManager.originalPhotos.count - 1
        }
        imageView.image = imageManager.originalPhotos[imageIndex]
        
        if let image = imageView.image {
            processImage(input: image)
        }
    }
    
    //이미지 편면화 함수
    func flattenImage(image: CIImage, topLeft: CGPoint, topRight: CGPoint,bottomLeft: CGPoint, bottomRight: CGPoint) -> CIImage {
        
        return image.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: topLeft),
            "inputTopRight": CIVector(cgPoint: topRight),
            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
            "inputBottomRight": CIVector(cgPoint: bottomRight)
        ])
    }
    
    func processImage(input: UIImage) {
        
        if let flattenedImage = imageManager.imageForRectanglesInImage(input: input) {
            
            let context = CIContext(options: nil)
            guard let cgImage = context.createCGImage(flattenedImage, from: flattenedImage.extent) else {
                return
            }
            let uiImage = UIImage(cgImage: cgImage)

            imageView?.image = uiImage
        }
    }
    
    func imageForRectanglesInImage(input: UIImage) -> CIImage? {
        guard let sourceImage = CIImage(image: input) else {
            return nil
        }
        
        let features = performRectangleDetection(image: sourceImage)
        
        if let rectangleFeatures = features as? [CIRectangleFeature], let firstRectangle = rectangleFeatures.first {
            let topLeft = firstRectangle.topLeft
            let topRight = firstRectangle.topRight
            let bottomLeft = firstRectangle.bottomLeft
            let bottomRight = firstRectangle.bottomRight
            
            let cgTopLeft = CGPoint(x: topLeft.x, y: topLeft.y)
            let cgTopRight = CGPoint(x: topRight.x, y: topRight.y)
            let cgBottomLeft = CGPoint(x: bottomLeft.x, y: bottomLeft.y)
            let cgBottomRight = CGPoint(x: bottomRight.x, y: bottomRight.y)
            
            return flattenImage(image: sourceImage, topLeft: cgTopLeft, topRight: cgTopRight, bottomLeft: cgBottomLeft, bottomRight: cgBottomRight)
        }
        
        return nil
    }
    
    // 이미지 내 사각형 탐지
    func performRectangleDetection(image: CIImage) -> [CIFeature] {
        
        let detector:CIDetector = CIDetector(
            ofType: CIDetectorTypeRectangle,
            context: nil,
            options: [CIDetectorAccuracy : CIDetectorAccuracyHigh]
        )!
        
        let features = detector.features(in: image)
        
        return features
    }
    
    // Core Image -> UIKit coordinate으로 변환
    func pathTransformForImageView(imageView: UIImageView) -> CGAffineTransform {
        
        guard let image = imageView.image else {
            return CGAffineTransformIdentity
        }
        
        guard let imageScale = imageView.imageScale else {
            return CGAffineTransformIdentity
        }
        
        guard let imageTransform = imageView.normalizedTransformForOrientation else {
            return CGAffineTransformIdentity
        }
        
        let frame = imageView.frame
        
        let imageWidth = image.size.width * imageScale.width
        let imageHeight = image.size.height * imageScale.height
        
        var transform = CGAffineTransformIdentity
        
        // Rotate to match the image orientation.
        transform = CGAffineTransformConcat(imageTransform, transform)
        
        // Flip vertically (flipped in CIDetector).
        transform = CGAffineTransformTranslate(transform, 0, CGRectGetHeight(frame))
        transform = CGAffineTransformScale(transform, 1.0, -1.0)
        
        // Centre align.
        let tx: CGFloat = (CGRectGetWidth(frame) - imageWidth) * 0.5 + -5
        let ty: CGFloat = (CGRectGetHeight(frame) - imageHeight) * 0.5 + 70
        transform = CGAffineTransformTranslate(transform, tx, ty)
        
        // Scale to match UIImageView scaling.
        transform = CGAffineTransformScale(transform, imageScale.width, imageScale.height)
        
        return transform
    }
}
