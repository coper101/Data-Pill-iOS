//
//  ColorValue.swift
//  Data Pill
//
//  Created by Wind Versi on 7/2/24.
//

import SwiftUI

extension Color: RawRepresentable {

    public init?(rawValue: String) {
        let defaultColor = UIColor.white
        
        guard let data = Foundation.Data(base64Encoded: rawValue) else {
            self = .init(defaultColor)
            return
        }
        do {
            let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) ?? defaultColor
            self = .init(uiColor)
        } catch {
            self = .init(defaultColor)
        }
    }

    public var rawValue: String {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false) as Foundation.Data
            return data.base64EncodedString()
        } catch{
            return ""
        }
    }
}
