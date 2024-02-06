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
    }
}
