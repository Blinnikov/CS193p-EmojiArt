//
//  File.swift
//  EmojiArt
//
//  Created by Igor Blinnikov on 16.01.2022.
//

import SwiftUI

struct SelectionBorderViewModifier: AnimatableModifier {
  var isOn: Bool
  var lineWidth: CGFloat = 1
  
  var animatableData: AnimatablePair<Double, Double> {
    get {
      AnimatablePair(isOn ? 1.0 : 0.0, lineWidth)
    }
    set {
      isOn = newValue.first == 1.0
      lineWidth = newValue.second
    }
  }
  
  func body(content: Content) -> some View {
    content
      .overlay(
        isOn
          ? RoundedRectangle(cornerRadius: 15).stroke(Color.blue, lineWidth: lineWidth)
          : nil
      )
  }
}

extension View {
  func selectionBorder(isOn: Bool, lineWidth: CGFloat) -> some View {
    self.modifier(SelectionBorderViewModifier(isOn: isOn, lineWidth: lineWidth))
  }
}
