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
}
