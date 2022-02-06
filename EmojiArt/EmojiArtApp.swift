//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Igor Blinnikov on 12.01.2022.
//

import SwiftUI

@main
struct EmojiArtApp: App {
  @StateObject var paletteStore = PaletteStore(named: "Default")
  
  var body: some Scene {
    DocumentGroup(newDocument: { EmojiArtDocument() }) { config in
      EmojiArtDocumentView(document: config.document)
        .environmentObject(paletteStore)
    }
  }
}
