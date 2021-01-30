//
//  Typealiases.swift
//  News
//
//  Created by Alina Petrovskaya on 24.01.2021.
//

import UIKit

typealias DataForArticle = (image: UIImage?,
                            title: String?,
                            sourceName: String?,
                            urlString: String?,
                            content: String?,
                            articleDescription: String?)

typealias DataForRealmItem = (urlString: String,
                              image: String,
                              title: String,
                              date: Date,
                              sourceName: String,
                              content: String,
                              articleDescription: String,
                              saveButton: Bool)
