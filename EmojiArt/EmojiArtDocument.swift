//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Igor Blinnikov on 12.01.2022.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
  @Published private(set) var emojiArt: EmojiArtModel {
    didSet {
      autosave()
      if emojiArt.background != oldValue.background {
        fetchBackgroundImageDataIfNecessary()
      }
    }
  }
  
  private struct Autosave {
    static let filename = "Autosaved.emojiart"
    static var url: URL? {
      let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
      return documentDirectory?.appendingPathComponent(filename)
    }
  }
  
  private func autosave() {
    if let url = Autosave.url {
      save(to: url)
    }
  }
  
  private func save(to url: URL) {
    let thisfunction = "\(String(describing: self)).\(#function)"
    do {
      let data: Data = try emojiArt.json()
      print("\(thisfunction) json = \(String(data: data, encoding: .utf8) ?? "nil")")
      try data.write(to: url)
      print("\(thisfunction) success!")
    } catch let encodingError where encodingError is EncodingError {
      print("\(thisfunction) couldn't encode EmojiArt as JSON because \(encodingError.localizedDescription)")
    } catch {
      print("\(thisfunction) error = \(error)")
    }
  }
  
  init() {
    emojiArt = EmojiArtModel()
    emojiArt.addEmoji("🥱", at: (-200, -100), size: 80)
    emojiArt.addEmoji("😵‍💫", at: (50, 100), size: 40)
  }
  
  var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
  var background: EmojiArtModel.Background { emojiArt.background }
  
  @Published var backgroundImage: UIImage?
  @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
  
  enum BackgroundImageFetchStatus {
    case idle
    case fetching
  }
  
  private func fetchBackgroundImageDataIfNecessary() {
    backgroundImage = nil
    switch emojiArt.background {
    case .url(let url):
      // fetch the url
      backgroundImageFetchStatus = .fetching
      Task.detached(priority: .userInitiated) {
        let imageData = try? Data(contentsOf: url)
        
        await MainActor.run { [weak self] in
          if self?.emojiArt.background == EmojiArtModel.Background.url(url) {
            self?.backgroundImageFetchStatus = .idle
            if imageData != nil {
              self?.backgroundImage = UIImage(data: imageData!)
            }
          }
        }
      }
    case .imageData(let data):
      backgroundImage = UIImage(data: data)
    case .blank:
      break
    }
  }
  
  // MARK: - Intent(s)
  
  func setBackground(_ background: EmojiArtModel.Background) {
    emojiArt.background = background
    print("background set to \(background)")
  }
  
  func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
    emojiArt.addEmoji(emoji, at: location, size: Int(size))
  }
  
  func removeEmoji(_ emoji: EmojiArtModel.Emoji) {
    emojiArt.removeEmoji(emoji)
  }
  
  @discardableResult
  func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) -> (x: Int, y: Int) {
    if let index = emojiArt.emojis.index(matching: emoji) {
      emojiArt.emojis[index].x += Int(offset.width)
      emojiArt.emojis[index].y += Int(offset.height)
      
      return (emojiArt.emojis[index].x, emojiArt.emojis[index].y)
    }
    
    return (0,0)
  }
  
  func increaseSize(for emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
    if let index = emojiArt.emojis.index(matching: emoji) {
      let newSize = Int(CGFloat(emojiArt.emojis[index].size) * scale)
      let finalSize = max(1, newSize)
      emojiArt.emojis[index].size = finalSize
    }
  }
}
