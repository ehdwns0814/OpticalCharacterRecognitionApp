//
//  PreviewViewController.swift
//  OpticalCharacterRecognitionApp
//
//  Created by 동준 on 2/1/24.
//

import UIKit

class PreviewController: UIViewController {

    var capturedImage: UIImage?
    var detectedRectanglePoints: [CGPoint] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let imageView = UIImageView(image: capturedImage)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = view.bounds
        view.addSubview(imageView)
        
        drawRectangle()
    }

    func drawRectangle() {
        let rectangleLayer = CAShapeLayer()
        rectangleLayer.strokeColor = UIColor.red.cgColor
        rectangleLayer.lineWidth = 2.0
        rectangleLayer.fillColor = UIColor.clear.cgColor

        let path = UIBezierPath()
        path.move(to: detectedRectanglePoints[0])
        for point in detectedRectanglePoints {
            path.addLine(to: point)
        }
        path.close()

        rectangleLayer.path = path.cgPath
        view.layer.addSublayer(rectangleLayer)
    }
}

