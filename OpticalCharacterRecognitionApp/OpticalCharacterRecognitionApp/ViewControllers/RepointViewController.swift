import UIKit

class RepointViewController: UIViewController {
    private var imageView: UIImageView!
    private var lines: [CAShapeLayer] = []
    private var points: [CGPoint] = []
    private var selectedPointIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        // 이미지 설정
        guard let image = UIImage(named: "sample") else { return }
        imageView.image = image
        
        imageForRectanglesInImage(input: image)
        
        // 사각형 그리기
        drawLinesAndPoints()
    }
    
    func imageForRectanglesInImage(input: UIImage) {
        guard let sourceImage = CIImage(image: input) else { return }
        
        let features = rectangleDetection(image: sourceImage)
        
        if let rectangleFeatures = features as? [CIRectangleFeature], let firstRectangle = rectangleFeatures.first {
            let point1 = firstRectangle.topLeft
            let point2 = firstRectangle.bottomLeft
            let point3 = firstRectangle.bottomRight
            let point4 = firstRectangle.topRight
            
            points = [point1, point2, point3, point4]
        }
    }
    
    private func rectangleDetection(image: CIImage) -> [CIFeature] {
        let detector: CIDetector = CIDetector(
            ofType: CIDetectorTypeRectangle,
            context: nil,
            options: [CIDetectorAccuracy : CIDetectorAccuracyHigh]
        )!
        
        let features = detector.features(in: image)
        
        return features
    }
    
    // 선과 점 그리기
    private func drawLinesAndPoints() {
        // 기존의 선 및 점 제거
        for line in lines {
            line.removeFromSuperlayer()
        }
        lines.removeAll()
        
        // 사각형 선 그리기
        let linePath = UIBezierPath()
        linePath.move(to: points[0])
        for i in 1..<points.count {
            linePath.addLine(to: points[i])
        }
        linePath.close()
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.strokeColor = UIColor.red.cgColor
        lineLayer.lineWidth = 2.0
        lineLayer.fillColor = UIColor.clear.cgColor
        imageView.layer.addSublayer(lineLayer)
        lines.append(lineLayer)
        
        // 각 꼭지점에 점 그리기
        for point in points {
            let dotLayer = CAShapeLayer()
            dotLayer.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
            dotLayer.position = point
            dotLayer.path = UIBezierPath(ovalIn: dotLayer.bounds).cgPath
            dotLayer.fillColor = UIColor.blue.cgColor
            imageView.layer.addSublayer(dotLayer)
            lines.append(dotLayer)
        }
    }
    
    // 터치 이벤트 처리
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
    
    // 가장 가까운 꼭지점 인덱스 찾기
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

// CGPoint 간의 거리 계산
extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = self.x - point.x
        let dy = self.y - point.y
        return sqrt(dx * dx + dy * dy)
    }
}
