//
//  IndexPath.swift
//  News
//
//  Created by Alina Petrovskaya on 24.01.2021.
//

import Foundation

extension IndexPath {
  static func fromCell(_ row: Int, _ section: Int) -> IndexPath {
    return IndexPath(row: row, section: section)
  }
    
    static func fromRow(_ row: Int) -> IndexPath {
      return IndexPath(row: row, section: 0)
    }
}
