//
//  AnimatableSystemFontModifier.swift
//  EmojiArt
//
//  Created by Igor Blinnikov on 16.01.2022.
//

import SwiftUI

struct AnimatableSystemFontModifier: AnimatableModifier {
  var fontSize: CGFloat
  
  var animatableData: CGFloat {
    get { fontSize }
    set { fontSize = newValue }
  }
  
  func body(content: Content) -> some View {
    content
      .font(.system(size: fontSize))
  }
}

extension View {
  func animatableSystemFont(fontSize: CGFloat) -> some View {
    self.modifier(AnimatableSystemFontModifier(fontSize: fontSize))
  }
}
