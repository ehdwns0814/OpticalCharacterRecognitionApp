//
//  Color.swift
//  OpticalCharacterRecognitionApp
//
//  Created by 동준 on 2/1/24.
//

import UIKit

enum Color {
    case mainColor
    case subColor
    
    var rgbValue: (Int, Int, Int) {
        switch self {
        case .mainColor:
            return (66, 171, 225)
        case .subColor:
            return (79, 84, 125)
        }
    }

    var cgColor: CGColor {
        let (r, g, b) = rgbValue
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1.0).cgColor
    }
    
    func uiColor(alpha: CGFloat) -> UIColor {
            let (r, g, b) = rgbValue
            return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: alpha)
    }
}
