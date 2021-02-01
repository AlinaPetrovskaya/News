//
//  Constants.swift
//  News
//
//  Created by Alina Petrovskaya on 24.12.2020.
//

import Foundation

struct Constants {
    static let homeVC                            = "HomeScreenViewController"
    static let reusableArticleCell               = "ReusableArticleTableViewCell"
    static let reusableSliderTableViewCell       = "SliderTableViewCell"
    static let sliderButtonCollectionView        = "SliderButtonCollectionViewCell"
    static let reusableArticleCollectionViewCell = "ReusableArticleCollectionViewCell"
    
    static let searchVC              = "SearchViewController"
    static let prepareDateFilterCell = "PrepareDateFilterTableViewCell"
    static let readyDateFilterCell   = "ReadyDateFilterTableViewCell"
    static let calendarVC            = "CalendarViewController"
    
    static let bookmarkVC      = "BookmarkViewController"
    
    static let articleDetailVC = "ArticleDetailController"
    
    //Segues
    static let fromHomeToAtricle = "From Home To Atricle"
    static let fromBookmarksToArticle = "From Bookmarks To Article"
    static let fromSearchToArticle = "From Search To Article"
}
