//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Igor Blinnikov on 12.01.2022.
//

import SwiftUI

struct EmojiArtDocumentView: View {
  typealias Emoji = EmojiArtModel.Emoji
  
  @ObservedObject var document: EmojiArtDocument
  @State private var selection: Set<Int> = []
  
  func isSelected(emoji: Emoji) -> Bool {
    selection.contains(emoji.id)
  }
  
  var selectedEmojis: [Emoji] {
    document.emojis.filter(isSelected)
  }
  
  private func toggleSelection(for emoji: Emoji) {
    if isSelected(emoji: emoji) {
      selection.remove(emoji.id)
    } else {
      selection.insert(emoji.id)
    }
  }
  
  private func clearSelection() {
    selection.removeAll()
  }
  
  let defaultEmojiFontSize: CGFloat = 40
  
  var body: some View {
    VStack(spacing: 0) {
      documentBody
      palette
    }
  }
  
  var documentBody: some View {
    GeometryReader { geometry in
      ZStack {
        Color.white.overlay(
          OptionalImage(uiImage: document.backgroundImage)
            .scaleEffect(zoomScale)
            .position(convertFromEmojiCoordinates((0,0), in: geometry))
        )
          .gesture(
            // It lags. Probably it waits first to second tap not to happen.
            // And it's observed as a delay on emojis deselection.
            doubleTapToZoom(in: geometry.size)
              .exclusively(before: singleTapToClearSelection())
          )
        if document.backgroundImageFetchStatus == .fetching {
          ProgressView().scaleEffect(2)
        } else {
          ForEach(document.emojis) { emoji in
            Text(emoji.text)
              .selectionBorder(isOn: isSelected(emoji: emoji), lineWidth: 2)
              .animatableSystemFont(fontSize: fontSize(for: emoji))
              .position(position(for: emoji, in: geometry))
              .onTapGesture {
                toggleSelection(for: emoji)
              }
          }
        }
      }
      .clipped()
      .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
        return drop(providers: providers, at: location, in: geometry)
      }
      .gesture(
        panGesture().simultaneously(with: zoomGesture())
      )
    }
  }
  
  private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
    var found = providers.loadObjects(ofType: URL.self) { url in
      document.setBackground(.url(url.imageURL))
    }
    if !found {
      found = providers.loadObjects(ofType: UIImage.self) { image in
        if let data = image.jpegData(compressionQuality: 1.0) {
          document.setBackground(.imageData(data))
        }
      }
    }
    if !found {
      found = providers.loadObjects(ofType: String.self) { string in
        if let emoji = string.first, emoji.isEmoji {
          document.addEmoji(
            String(emoji),
            at: convertToEmojiCoordinates(location, in: geometry),
            size: defaultEmojiFontSize / zoomScale
          )
        }
      }
    }
    return found
  }
  
  private func position(for emoji: Emoji, in geometry: GeometryProxy) -> CGPoint {
    convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry)
  }
  
  private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
    let center = geometry.frame(in: .local).center
    let location = CGPoint(
      x: (location.x - panOffset.width - center.x) / zoomScale,
      y: (location.y - panOffset.height - center.y) / zoomScale
    )
    return (Int(location.x), Int(location.y))
  }
  
  private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
    let center = geometry.frame(in: .local).center
    return CGPoint(
      x: center.x + CGFloat(location.x) * zoomScale + panOffset.width,
      y: center.y + CGFloat(location.y) * zoomScale + panOffset.height
    )
  }
  
  private func fontSize(for emoji: Emoji) -> CGFloat {
    if isSelected(emoji: emoji) {
      return CGFloat(emoji.size) * selectionZoomScale
    } else {
      return CGFloat(emoji.size) * zoomScale
    }
  }
  
  @State private var steadyStatePanOffset: CGSize = .zero
  @GestureState private var gesturePanOffset: CGSize = .zero
  
  private var panOffset: CGSize {
    (steadyStatePanOffset + gesturePanOffset) * zoomScale
  }
  
  private func panGesture() -> some Gesture {
    DragGesture()
      .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, _ in
        gesturePanOffset = latestDragGestureValue.translation / zoomScale
      }
      .onEnded { finalDragGesture in
        steadyStatePanOffset = steadyStatePanOffset + (finalDragGesture.translation / zoomScale)
      }
  }
  
  @State private var steadyStateZoomScale: CGFloat = 1
  @GestureState private var gestureZoomScale: (background: CGFloat, selection: CGFloat) = (1, 1)
  
  private var zoomScale: CGFloat {
    steadyStateZoomScale * gestureZoomScale.background
  }
  
  private var selectionZoomScale: CGFloat {
    steadyStateZoomScale * gestureZoomScale.selection
  }
  
  private func zoomGesture() -> some Gesture {
    MagnificationGesture()
      .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, _ in
        if selection.isEmpty {
          gestureZoomScale.background = latestGestureScale
        } else {
          gestureZoomScale.selection = latestGestureScale
        }
      }
      .onEnded { gestureScaleAtEnd in
        steadyStateZoomScale *= gestureScaleAtEnd
      }
  }
  
  private func singleTapToClearSelection() -> some Gesture {
    TapGesture()
      .onEnded {
          clearSelection()
      }
  }
  
  private func doubleTapToZoom(in size: CGSize) -> some Gesture {
    TapGesture(count: 2)
      .onEnded {
        withAnimation {
          zoomToFit(document.backgroundImage, in: size)
        }
      }
  }
  
  private func zoomToFit(_ image: UIImage?, in size: CGSize) {
    if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0 {
      let hZoom = size.width / image.size.width
      let vZoom = size.height / image.size.height
      steadyStatePanOffset = .zero
      steadyStateZoomScale = min(hZoom, vZoom)
    }
  }
  
  var palette: some View {
    ScrollingEmojisView(emojis: testEmojis)
      .font(.system(size: defaultEmojiFontSize))
  }
  
  let testEmojis = "📟🐮🐞🪃🚀🇨🇿🤓🧅🍟🍔💎😔🥳🥶👺"
}

struct ScrollingEmojisView: View {
  let emojis: String
  
  var body: some View {
    ScrollView(.horizontal) {
      HStack {
        ForEach(emojis.map { String($0) }, id: \.self) { emoji in
          Text(emoji)
            .onDrag { NSItemProvider(object: emoji as NSString) }
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    EmojiArtDocumentView(document: EmojiArtDocument())
  }
}
