//
//  CGPoint.swift
//  OpticalCharacterRecognitionApp
//
//  Created by 동준 on 2/13/24.
//

import UIKit

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = self.x - point.x
        let dy = self.y - point.y
        return sqrt(dx * dx + dy * dy)
    }
}
