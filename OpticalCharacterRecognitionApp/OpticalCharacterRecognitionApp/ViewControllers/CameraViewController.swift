import UIKit
import AVFoundation

import Foundation
import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    let session = AVCaptureSession()
    let videoOutput = AVCaptureVideoDataOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()
    let pathLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.green.withAlphaComponent(0.3).cgColor
        layer.strokeColor = UIColor.green.withAlphaComponent(0.9).cgColor
        layer.lineWidth = 2.0
        return layer
    }()
    
    @IBOutlet var cameraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCamera()
        cameraView.layer.addSublayer(previewLayer)
        cameraView.layer.addSublayer(pathLayer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = cameraView.bounds
    }
    
    func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video) else {
            print("Failed to get camera device")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            session.addInput(input)
            session.addOutput(videoOutput)
            
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            
            previewLayer.session = session
            previewLayer.videoGravity = .resizeAspectFill
            
            session.startRunning()
        } catch {
            print("Failed to setup camera")
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let features = performRectangleDetection(image: ciImage)
        let path = pathForFeatures(features: features)
        
        DispatchQueue.main.async {
            let transformedPath = path.copy() as! UIBezierPath
            transformedPath.apply(self.pathTransformForImageView())
            self.pathLayer.path = transformedPath.cgPath
        }
    }
    
    func performRectangleDetection(image: CIImage) -> [CIFeature] {
        let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = detector?.features(in: image)
        return features ?? []
    }
    
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
    
    func pathTransformForImageView() -> CGAffineTransform {
        let videoOrientation = previewLayer.connection?.videoOrientation ?? .portrait
        
        var transform = CGAffineTransform.identity
        
        switch videoOrientation {
        case .portrait:
            transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        case .portraitUpsideDown:
            transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
        case .landscapeRight:
            transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        default:
            break
        }
        
        return transform
    }
}
