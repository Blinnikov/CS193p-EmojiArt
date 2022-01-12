//
//  UtilityExtensions.swift
//  EmojiArt
//
//  Created by Igor Blinnikov on 12.01.2022.
//

import SwiftUI

extension Collection where Element: Identifiable {
  func index(matching element: Element) -> Self.Index? {
    firstIndex(where: { $0.id == element.id })
  }
}

extension CGRect {
  var center: CGPoint {
    CGPoint(x: midX, y: midY)
  }
}
