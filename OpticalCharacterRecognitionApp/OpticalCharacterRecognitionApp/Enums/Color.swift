//
//  Color.swift
//  OpticalCharacterRecognitionApp
//
//  Created by 동준 on 2/1/24.
//

import Foundation

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
}
