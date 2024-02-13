//
//  ImageManager.swift
//  OpticalCharacterRecognitionApp
//
//  Created by 동준 on 2/13/24.
//

import UIKit

final class ImageManager {
    static let shared = ImageManager()
    
    var capturedImageList: [UIImage] = []
    var perspectivedImageList: [UIImage] = []
    
    func takeImage() {
        
    }
    
    func storeImage() {
        
    }
    
    func createRotatedImage(from ciImage: CIImage) -> UIImage? {
        let flattenedImage = ciImage // 이미지를 가져오는 코드
        UIGraphicsBeginImageContext(CGSize(width: flattenedImage.extent.size.height, height: flattenedImage.extent.size.width))
        UIImage(ciImage: flattenedImage, scale: 1.0, orientation: .left).draw(in: CGRect(x: 0, y: 0, width: flattenedImage.extent.size.height, height: flattenedImage.extent.size.width))
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rotatedImage
    }
    
    func flattenImage(image: CIImage, topLeft: CGPoint, topRight: CGPoint,bottomLeft: CGPoint, bottomRight: CGPoint) -> CIImage {
        
        return image.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: topLeft),
            "inputTopRight": CIVector(cgPoint: topRight),
            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
            "inputBottomRight": CIVector(cgPoint: bottomRight)
        ])
    }
    
    

    // Detect rectangles in an image and return a UIBezierPath.
    func pathsForRectanglesInImage(input: UIImage) -> UIBezierPath? {

        guard let sourceImage = CIImage(image: input) else {
            return nil
        }

        let features = performRectangleDetection(image: sourceImage)

        return pathForFeatures(features: features)
    }

    // Detect rectangles in image.
    func performRectangleDetection(image: CIImage) -> [CIFeature] {

        let detector:CIDetector = CIDetector(
            ofType: CIDetectorTypeRectangle,
            context: nil,
            options: [CIDetectorAccuracy : CIDetectorAccuracyHigh]
        )!

        let features = detector.features(in: image)

        return features
    }

    // Compose a UIBezierPath from CIRectangleFeatures.
    func pathForFeatures(features: [CIFeature]) -> UIBezierPath {

        let path = UIBezierPath()

        for feature in features {

            guard let rect = feature as? CIRectangleFeature else {
                continue
            }

            path.move(to: rect.topLeft)
            path.addLine(to: rect.topRight)
            path.addLine(to: rect.bottomRight)
            path.addLine(to: rect.bottomLeft)
            path.close()
        }

        return path
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
        let tx: CGFloat = (CGRectGetWidth(frame) - imageWidth) * 0.5
        let ty: CGFloat = (CGRectGetHeight(frame) - imageHeight) * 0.5
        transform = CGAffineTransformTranslate(transform, tx, ty)

        // Scale to match UIImageView scaling.
        transform = CGAffineTransformScale(transform, imageScale.width, imageScale.height)

        return transform
    }
    
    

}
