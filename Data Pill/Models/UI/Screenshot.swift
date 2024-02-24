//
//  Screenshot.swift
//  Data Pill
//
//  Created by Wind Versi on 27/1/24.
//

import SwiftUI

struct Screenshot: Identifiable {
    let id: String = UUID().uuidString
    let image: UIImage
}

extension UIImage {
    
    static func createBlank(size: CGSize) -> UIImage {
        let image = UIGraphicsImageRenderer(size: size).image { _ in
            UIColor(Colors.onSurfaceDark2.color).setFill()
            UIRectFill(
                CGRect(x: 0, y: 0, width: size.width, height: size.height)
            )
        }
        return image
    }
    
    static let testImage = createBlank(size: .init(width: 1080, height: 1920))
}
