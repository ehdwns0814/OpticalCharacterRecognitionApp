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
        
        let sx = Double(self.frame.size.width / image.size.width)
        let sy = Double(self.frame.size.height / image.size.height)
        var s = 1.0
        switch (self.contentMode) {
        case .scaleAspectFit:
            s = fmin(sx, sy)
            return CGSize (width: s, height: s)
            
        case .scaleAspectFill:
            s = fmax(sx, sy)
            return CGSize(width:s, height:s)
            
        case .scaleToFill:
            return CGSize(width:sx, height:sy)
            
        default:
            return CGSize(width:s, height:s)
        }
    }
    
    var normalizedTransformForOrientation: CGAffineTransform? {
        
        guard let image = image else {
            return nil
        }
        
        let r: CGFloat
        
        switch image.imageOrientation {
            
        case .up:
            r = 0
            
        case .down:
            r = +1.0
            
        case .left:
            r = -0.5
            
        case .right:
            r = +0.5
            
        default:
            fatalError()
        }
        
        let cx = CGRectGetMidX(bounds)
        let cy = CGRectGetMidY(bounds)
        
        var transform = CGAffineTransformIdentity
        transform = CGAffineTransformTranslate(transform, cx, cy)
        transform = CGAffineTransformRotate(transform, CGFloat(Double.pi) * r)
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

