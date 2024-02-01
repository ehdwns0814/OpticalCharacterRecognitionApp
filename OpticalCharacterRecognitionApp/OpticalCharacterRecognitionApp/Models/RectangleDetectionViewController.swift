import UIKit
import AVFoundation
import Vision

class RectangleDetectionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var detectionOverlay: CALayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 카메라 캡처 세션 설정
        captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            fatalError("카메라 장치를 가져올 수 없습니다.")
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch {
            fatalError("카메라 입력을 생성할 수 없습니다.")
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInitiated))
        captureSession.addOutput(videoOutput)
        
        // 프리뷰 레이어 설정
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        // 감지 결과를 표시할 오버레이 레이어 설정
        detectionOverlay = CALayer()
        detectionOverlay.bounds = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        detectionOverlay.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        detectionOverlay.backgroundColor = UIColor.clear.cgColor
        previewLayer.addSublayer(detectionOverlay)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    // 샘플 버퍼마다 호출되는 AVCaptureVideoDataOutputSampleBufferDelegate 메서드
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        
        // Vision 프레임워크를 사용하여 사각형 검출
        let request = VNDetectRectanglesRequest { (request, error) in
            if let error = error {
                print("사각형 검출 중 오류 발생: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self.processDetectionResults(request.results)
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("사각형 검출 요청 중 오류 발생: \(error.localizedDescription)")
        }
    }
    
    // 사각형 검출 결과 처리
    func processDetectionResults(_ results: [Any]?) {
        guard let results = results, results.count > 0 else {
            detectionOverlay.sublayers = nil
            return
        }
        
        detectionOverlay.sublayers = nil
        
        for result in results {
            if let rectangle = result as? VNRectangleObservation {
                let transformedRect = previewLayer.layerRectConverted(fromMetadataOutputRect: rectangle.boundingBox)
                drawBoundingBox(transformedRect)
            }
        }
    }
    
    // 검출된 사각형을 박스로 표시
    func drawBoundingBox(_ rect: CGRect) {
        let boundingBoxLayer = CALayer()
        boundingBoxLayer.frame = rect
        boundingBoxLayer.borderWidth = 2.0
        boundingBoxLayer.borderColor = UIColor.red.cgColor
        detectionOverlay.addSublayer(boundingBoxLayer)
    }
}
