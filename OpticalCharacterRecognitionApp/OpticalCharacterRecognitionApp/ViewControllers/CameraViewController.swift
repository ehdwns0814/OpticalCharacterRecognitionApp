import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    
    let pathLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.green.withAlphaComponent(0.3).cgColor
        layer.strokeColor = UIColor.green.withAlphaComponent(0.9).cgColor
        layer.lineWidth = 2.0
        return layer
    }()
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {

        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession?.addInput(input)
        } catch {
            print(error.localizedDescription)
            return
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
        captureSession?.addOutput(videoOutput)
        
        viewPreview

        imageView?.layer.addSublayer(pathLayer)

        selectImage(image: UIImage(named: "sample"))
    }

    func selectImage(image: UIImage?) {

        imageView?.image = image

        if let image = image {
            processImage(input: image)
        }
    }

    func processImage(input: UIImage) {

        let path = pathsForRectanglesInImage(input: input)

        let transform = pathTransformForImageView(imageView: imageView!)
        path?.apply(transform)

        pathLayer.path = path?.cgPath
    }

    func pathsForRectanglesInImage(input: UIImage) -> UIBezierPath? {

        guard let sourceImage = CIImage(image: input) else {
            return nil
        }

        let features = performRectangleDetection(image: sourceImage)

        return pathForFeatures(features: features)
    }

    func performRectangleDetection(image: CIImage) -> [CIFeature] {
        
        let detector:CIDetector = CIDetector(
            ofType: CIDetectorTypeRectangle,
            context: nil,
            options: [CIDetectorAccuracy : CIDetectorAccuracyHigh]
        )!

        let features = detector.features(in: image)

        return features
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

        transform = CGAffineTransformConcat(imageTransform, transform)

        transform = CGAffineTransformTranslate(transform, 0, CGRectGetHeight(frame))
        transform = CGAffineTransformScale(transform, 1.0, -1.0)

        let tx: CGFloat = (CGRectGetWidth(frame) - imageWidth) * 0.5
        let ty: CGFloat = (CGRectGetHeight(frame) - imageHeight) * 0.5
        transform = CGAffineTransformTranslate(transform, tx, ty)

        transform = CGAffineTransformScale(transform, imageScale.width, imageScale.height)

        return transform
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
}
