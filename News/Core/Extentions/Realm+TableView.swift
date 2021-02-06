//
//  Realm+TableView.swift
//  News
//
//  Created by Alina Petrovskaya on 24.01.2021.
//

import UIKit

extension UITableView {
    func applyChanges(deletions: [Int], insertions: [Int], updates: [Int]) {
      
      beginUpdates()
      deleteRows(at: deletions.map(IndexPath.fromRow), with: .automatic)
      insertRows(at: insertions.map(IndexPath.fromRow), with: .automatic)
      reloadRows(at: updates.map(IndexPath.fromRow), with: .automatic)
      endUpdates()
    }
    
    func reloadRows(cell: [(Int, Int)]) {
        beginUpdates()
        reloadRows(at: cell.map(IndexPath.fromCell), with: .automatic)
        endUpdates()
    }
    
//    func prepareForReload(for: Int) {
//        deleteRows(at: [IndexPath.fromCell(1, 1)], with: .none)
//    }
    
    func updateItemAtRealm(data: DataForRealmItem?, needSave: Bool, item: RealmItem?) {
        if needSave {
            guard let safeData = data else { return }
            
            RealmItem.addItem(dataArticle: safeData)
            
        } else {
            item?.deleteItem()
        }
    }
}
