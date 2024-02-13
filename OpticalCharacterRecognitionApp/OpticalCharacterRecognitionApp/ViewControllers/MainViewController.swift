import UIKit
import AVFoundation
import CoreImage

class MainViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var previewView: UIView!
    
    
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    private var maskLayer = CAShapeLayer()
    
    private var isTapped = false
    
    override func viewDidAppear(_ animated: Bool) {
        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        
        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }
        
        refreshCapturedImageView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.videoDataOutput.setSampleBufferDelegate(nil, queue: nil)
        self.captureSession.stopRunning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCameraInput()
        self.showCameraFeed()
        self.setCameraOutput()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer.frame = self.previewView.bounds
    func checkCameraPermission() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch cameraAuthorizationStatus {
        case .notDetermined:
            print("카메라 권한 인증 전")
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { access in
                if access {
                    print("카메라 권한 허용")
                } else {
                    print("카메라 권한 거부")
                    return
                }
            })
        case .restricted:
            print("카메라 권한 불가 상태")
        case .denied:
            print("카메라 권한 거부 상태")
        case .authorized:
            print("카메라 권한 허용 상태")
        @unknown default:
            print("카메라 권한 알수 없는 상태")
        }
    }
    
    //MARK: Session initialisation and video output
    private func setCameraInput() {
        guard let device = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
            mediaType: .video,
            position: .back).devices.first else {
            fatalError("No back camera device found.")
        }
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        self.captureSession.addInput(cameraInput)
    }
    
    private func showCameraFeed() {
        self.previewLayer.videoGravity = .resizeAspectFill
        self.previewView.layer.addSublayer(self.previewLayer)
        self.previewLayer.frame = self.previewView.frame
    }
    
    private func setCameraOutput() {
        self.videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        
        self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        self.captureSession.addOutput(self.videoDataOutput)
        
        guard let connection = self.videoDataOutput.connection(with: AVMediaType.video),
              connection.isVideoOrientationSupported else { return }
        
        connection.videoOrientation = .portrait
    }
    
    //MARK: AVCaptureVideo Delegate
    func captureOutput(_ output: AVCaptureOutput,didOutput sampleBuffer: CMSampleBuffer,from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            debugPrint("unable to get image from sample buffer")
            return
        }
        
        lazy var ciImage = CIImage(cvPixelBuffer: frame)
        lazy var image = UIImage(ciImage: ciImage)
        ciImage = ciImage.oriented(forExifOrientation: Int32(UIImage.Orientation.leftMirrored.rawValue))
        captureImage = image
    }
    
    private func capturePhoto() {
        refreshCapturedImageView()
        do {
            try imageManager.setPhoto(image: captureImage)
        } catch {
            print("사진 저장실패 \(error)")
        }
    }
    
    
}

extension MainViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    
}

extension MainViewController {
    @IBAction func captureButtonTapped(_ sender: UIButton) {
        capturePhoto()
    }
}
