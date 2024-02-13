//
//  RepointViewController.swift
//  OpticalCharacterRecognitionApp
//
//  Created by 동준 on 2/1/24.
//

import UIKit

final class RepointViewController: UIViewController {
    
    let pathLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = Color.subColor.cgColor
        layer.strokeColor = UIColor.green.withAlphaComponent(0.9).cgColor
        layer.lineWidth = 2.0
        return layer
    }()
    
    @IBOutlet var imageView: UIImageView?
    
    private let imageManager = ImageManager.shared
    private var lines: [CAShapeLayer] = []
    private var points: [CGPoint] = []
    private var selectedPointIndex: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectImage(image: UIImage(named: "sample1"))
        addCirclePointsAtPathVertices()
        drawLinesAndPoints()
    }
    
    private func selectImage(image: UIImage?) {
        
        imageView?.image = image
        
        if let image = image {
            processImage(input: image)
        }
    }
    
    private func processImage(input: UIImage) {
        
        let path = imageManager.pathsForRectanglesInImage(input: input)
        
        let transform = imageManager.pathTransformForImageView(imageView: imageView!)
        path?.apply(transform)
        
        pathLayer.path = path?.cgPath
    }
    
    private func drawLinesAndPoints() {
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines.removeAll()
        
        let linePath = UIBezierPath()
        linePath.move(to: points[0])
        for i in 1..<points.count {
            linePath.addLine(to: points[i])
        }
        linePath.close()
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.strokeColor = Color.subColor.cgColor
        lineLayer.lineWidth = 2.0
        lineLayer.fillColor = Color.mainColor.uiColor(alpha: 0.5).cgColor
        imageView?.layer.addSublayer(lineLayer)
        lines.append(lineLayer)
        
        for point in points {
            let dotLayer = CAShapeLayer()
            dotLayer.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
            dotLayer.position = point
            dotLayer.path = UIBezierPath(ovalIn: dotLayer.bounds).cgPath
            dotLayer.fillColor = Color.subColor.cgColor
            imageView?.layer.addSublayer(dotLayer)
            lines.append(dotLayer)
        }
    }
    
    private func addCirclePointsAtPathVertices() {
        guard let path = pathLayer.path else {
            return
        }
        
        path.applyWithBlock { element in
            let point: CGPoint
            switch element.pointee.type {
            case .moveToPoint, .addLineToPoint:
                point = element.pointee.points[0]
            case .addQuadCurveToPoint:
                point = element.pointee.points[1]
            case .addCurveToPoint:
                point = element.pointee.points[2]
            default:
                return
            }
            points.append(point)
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchPoint = touch.location(in: imageView)
        selectedPointIndex = nearestPointIndex(to: touchPoint)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let selectedIndex = selectedPointIndex else {
            return
        }
        
        let touchPoint = touch.location(in: imageView)
        points[selectedIndex] = touchPoint
        drawLinesAndPoints()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedPointIndex = nil
    }
    
    private func nearestPointIndex(to point: CGPoint) -> Int? {
        var nearestIndex: Int?
        var minDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        
        for (index, p) in points.enumerated() {
            let distance = point.distance(to: p)
            if distance < minDistance {
                minDistance = distance
                nearestIndex = index
            }
        }
        
        if minDistance <= 20 {
            return nearestIndex
        }
        
        return nil
    }
}
