//
//  Set+Extension.swift
//  EmojiArt
//
//  Created by Igor Blinnikov on 18.01.2022.
//

import Foundation

extension Set {
  mutating func toggleMatching<T>(_ item: T) where T: Identifiable, Set.Element == T.ID {
    if self.contains(item.id) {
      self.remove(item.id)
    } else {
      self.insert(item.id)
    }
  }
}
