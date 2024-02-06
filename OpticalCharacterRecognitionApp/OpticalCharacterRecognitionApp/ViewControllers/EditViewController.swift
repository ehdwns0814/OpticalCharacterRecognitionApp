//
//  EditViewController.swift
//  OpticalCharacterRecognitionApp
//
//  Created by 동준 on 2/1/24.
//

import UIKit

class EditViewController: UIViewController {

    var capturedImage: UIImage?
    var cornerPoints: [CGPoint] = [] // Set the initial corner points
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let imageView = UIImageView(image: capturedImage)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = view.bounds
        view.addSubview(imageView)

        addPanGestureToCorners()
    }

    func addPanGestureToCorners() {
        for point in cornerPoints {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCornerPan(_:)))
            let cornerView = UIView(frame: CGRect(x: point.x - 15, y: point.y - 15, width: 30, height: 30))
            cornerView.backgroundColor = UIColor.blue
            cornerView.layer.cornerRadius = 15
            cornerView.addGestureRecognizer(panGesture)
            view.addSubview(cornerView)
        }
    }

    @objc func handleCornerPan(_ gesture: UIPanGestureRecognizer) {
        // Handle corner dragging to adjust the rectangle
        if let cornerView = gesture.view {
            let translation = gesture.translation(in: view)
            cornerView.center = CGPoint(x: cornerView.center.x + translation.x, y: cornerView.center.y + translation.y)
            gesture.setTranslation(.zero, in: view)
        }
    }
}
