//
//  UIImageView.swift
//  OpticalCharacterRecognitionApp
//
//  Created by 동준 on 2/6/24.
//

import UIKit

extension UIImageView {
    
    var imageScale: CGSize? {
        
        guard let image = image else {
            return nil
        }
        
        let scaleX = Double(self.frame.size.width / image.size.width)
        let scaleY = Double(self.frame.size.height / image.size.height)
        var scale = 1.0
        switch (self.contentMode) {
        case .scaleAspectFit:
            scale = fmin(scaleX, scaleY)
            return CGSize (width: scale, height: scale)
            
        case .scaleAspectFill:
            scale = fmax(scaleX, scaleY)
            return CGSize(width:scale, height:scale)
            
        case .scaleToFill:
            return CGSize(width:scaleX, height:scaleY)
            
        default:
            return CGSize(width:scale, height:scale)
        }
    }
    
    var normalizedTransformForOrientation: CGAffineTransform? {
        
        guard let image = image else {
            return nil
        }
        
        let rotation: CGFloat
        
        switch image.imageOrientation {
            
        case .up:
            rotation = 0
            
        case .down:
            rotation = +1.0
            
        case .left:
            rotation = -0.5
            
        case .right:
            rotation = +0.5
            
        default:
            fatalError()
        }
        
        let cx = CGRectGetMidX(bounds)
        let cy = CGRectGetMidY(bounds)
        
        var transform = CGAffineTransformIdentity
        transform = CGAffineTransformTranslate(transform, cx, cy)
        transform = CGAffineTransformRotate(transform, CGFloat(Double.pi) * rotation)
        transform = CGAffineTransformTranslate(transform, -cx, -cy)
        return transform
    }
    
    func imageFrameInImageView() -> CGRect {
        guard let image = self.image else {
            return CGRect.zero
        }
        
        let imageSize = image.size
        let imageViewSize = self.bounds.size
        
        let imageAspect = imageSize.width / imageSize.height
        let imageViewAspect = imageViewSize.width / imageViewSize.height
        
        var imageFrame = CGRect.zero
        
        if imageAspect > imageViewAspect {
            let scale = imageViewSize.height / imageSize.height
            let width = scale * imageSize.width
            let x = (imageViewSize.width - width) / 2
            imageFrame = CGRect(x: x, y: 0, width: width, height: imageViewSize.height)
        } else {
            let scale = imageViewSize.width / imageSize.width
            let height = scale * imageSize.height
            let y = (imageViewSize.height - height) / 2
            imageFrame = CGRect(x: 0, y: y, width: imageViewSize.width, height: height)
        }
        
        return imageFrame
    }
}

