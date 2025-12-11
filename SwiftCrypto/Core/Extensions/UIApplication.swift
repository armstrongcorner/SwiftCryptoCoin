//
//  UIApplication.swift
//  SwiftCrypto
//
//  Created by Armstrong Liu on 24/11/2025.
//

import Foundation
import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
