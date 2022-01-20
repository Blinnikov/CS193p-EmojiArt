//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Igor Blinnikov on 12.01.2022.
//

import SwiftUI

@main
struct EmojiArtApp: App {
  let document = EmojiArtDocument()
  let paletteStore = PaletteStore(named: "Default")
  
  var body: some Scene {
    WindowGroup {
      EmojiArtDocumentView(document: document)
    }
  }
}
