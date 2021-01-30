//
//  RealmItem.swift
//  News
//
//  Created by Alina Petrovskaya on 21.01.2021.
//

import Foundation
import RealmSwift

@objcMembers class RealmItem: Object  {
    
    enum Property: String {
      case urlString, date
    }

    dynamic var urlString          = ""
    dynamic var imageURL           = ""
    dynamic var title              = ""
    dynamic var date               = Date()
    dynamic var sourceName         = ""
    dynamic var content            = ""
    dynamic var articleDescription = ""
    dynamic var saveButton         = true
    
    override static func primaryKey() -> String? {
        return RealmItem.Property.urlString.rawValue
    }

    convenience init(_ urlString: String,
                     _ image: String,
                     _ title: String,
                     _ date: Date,
                     _ sourceName: String,
                     _ content: String,
                     _ articleDescription: String) {
        self.init()

        self.urlString          = urlString
        self.imageURL           = image
        self.title              = title
        self.date               = date
        self.sourceName         = sourceName
        self.content            = content
        self.articleDescription = articleDescription
    }
}

extension RealmItem {
    static func getAllItems(in realm: Realm = try! Realm()) -> Results<RealmItem> {
        return realm.objects(RealmItem.self)
            .sorted(byKeyPath: RealmItem.Property.date.rawValue)
    }

    @discardableResult
    static func addItem(dataArticle: DataForRealmItem , in realm: Realm = try! Realm())
    -> RealmItem {
        let item = RealmItem(dataArticle.urlString,
                             dataArticle.image,
                             dataArticle.title,
                             dataArticle.date,
                             dataArticle.sourceName,
                             dataArticle.content,
                             dataArticle.articleDescription)
      
        try! realm.write {
            realm.add(item)
      }
      return item
    }


    func deleteItem() {
      guard let realm = realm else { return }

        try! realm.write {
          realm.delete(self)
      }
    }
}
