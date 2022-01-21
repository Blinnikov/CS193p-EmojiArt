//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by Igor Blinnikov on 22.01.2022.
//

import SwiftUI

struct PaletteChooser: View {
  var emojiFontSize: CGFloat = 40
  var emojiFont: Font { .system(size: emojiFontSize) }
  
  var body: some View {
    ScrollingEmojisView(emojis: testEmojis)
      .font(emojiFont)
  }
  
  let testEmojis = "📟🐮🐞🪃🚀🇨🇿🤓🧅🍟🍔💎😔🥳🥶👺"
}

struct ScrollingEmojisView: View {
  let emojis: String
  
  var body: some View {
    ScrollView(.horizontal) {
      HStack {
        ForEach(emojis.removingDuplicateCharacters.map { String($0) }, id: \.self) { emoji in
          Text(emoji)
            .onDrag { NSItemProvider(object: emoji as NSString) }
        }
      }
    }
  }
}

struct PaletteChooser_Previews: PreviewProvider {
  static var previews: some View {
    PaletteChooser()
  }
}
