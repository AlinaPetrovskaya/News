//
//  ArticleDetailController.swift
//  News
//
//  Created by Alina Petrovskaya on 29.12.2020.
//

import UIKit

class ArticleDetailController: UIViewController {
    
    let articleData = RequestDataWrapper()
    
    @IBOutlet private weak var articleImage: UIImageView!
    @IBOutlet private weak var articleHeaderTitle: UILabel!
    @IBOutlet private weak var articleTextView: UITextView!
    @IBOutlet private weak var lincOfArticle: UIButton!
    
    var dataForDetailArticle: DataForArticle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            prepareUI()
    }
    
    private func prepareUI() {
        
        guard let safeContent = dataForDetailArticle else { return }
        
        articleImage.image        = safeContent.image ?? #imageLiteral(resourceName: "default")
        articleHeaderTitle.text   = safeContent.sourceName
       
        constructTextView(title: safeContent.title, articleDescription: safeContent.articleDescription, content: safeContent.content)
    }
    
    
    private func constructTextView(title: String?, articleDescription: String?, content: String?) {
        let attributedContent = NSMutableAttributedString()
        
        attributedContent.append(prepareTitleText(text: title, size: 20))
        attributedContent.append(prepareTitleText(text: articleDescription, size: 16))
        attributedContent.append(prepareContent(text: content))
        articleTextView.attributedText = attributedContent
        
    }
    
    private func prepareTitleText(text: String?, size: CGFloat) -> NSAttributedString {
        
        let font = UIFont(name: "SF Pro Text Semibold", size: size)
        
        guard let safeFont = font, let safeText = text else { return NSAttributedString() }
        
        let attributes     = [NSAttributedString.Key.font: safeFont]
        let attributedText = NSAttributedString(string: "\(safeText) \n\n", attributes: attributes)
        
        return attributedText
    }
    
    private func prepareContent(text: String?) -> NSAttributedString {
        let font = UIFont(name: "SF Pro Text Regular", size: 16)
        
        guard let safeFont = font, let safeText = text else { return NSAttributedString() }
        
        let updated        = safeText.split(separator: "[")
        let attributes     = [NSAttributedString.Key.font: safeFont]
        let attributedText = NSAttributedString(string: "\(updated.first ?? "")", attributes: attributes)
        
        return attributedText
    }
    
    @IBAction private func swipeAction(_ sender: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func goBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction private func showArticleAtBrowser(_ sender: UIButton) {
        guard let safeURL = dataForDetailArticle?.urlString else { return }
        
        if let url = URL(string: safeURL) {
            UIApplication.shared.open(url)
        }
    }
}
