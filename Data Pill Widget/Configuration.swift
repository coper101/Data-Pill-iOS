//
//  Configuration.swift
//  Data Pill WidgetExtension
//
//  Created by Wind Versi on 7/1/24.
//

import SwiftUI

extension WidgetConfiguration {
    
    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}
