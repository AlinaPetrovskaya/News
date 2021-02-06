//
//  Realm+CollectionView.swift
//  News
//
//  Created by Alina Petrovskaya on 28.01.2021.
//

import UIKit

extension UICollectionView {

    func updateItemAtRealm(data: DataForRealmItem?, needSave: Bool, item: RealmItem?) {

        if needSave {
            guard let safeData = data else { return }
            RealmItem.addItem(dataArticle: safeData)

        } else {
            item?.deleteItem()
        }
    }
}


