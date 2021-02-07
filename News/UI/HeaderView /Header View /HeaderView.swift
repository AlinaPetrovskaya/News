//
//  ButtonSliderUIView.swift
//  News
//
//  Created by Alina Petrovskaya on 02.02.2021.
//

import UIKit

class HeaderView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    enum TypeOfSection {
        case headerForSliderNews, headerForHomeListNews, headerForSearchListNews
    }
    
    private let arrayOfTitlesForButton = ["Politics", "Sport", "Business", "Army", "Nature", "Art"]
    var tapActionOnSearchButton: ((String) -> ())?
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        collectionview.translatesAutoresizingMaskIntoConstraints = false
        return collectionview
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

    }
    
    convenience init(for section: TypeOfSection, labelText: String) {
        self.init(frame: .zero)
        
        switch section {
        case .headerForSliderNews:
            updateLabel(labelText: labelText, font: FontBook.PlayFairMedium.of(size: 24), upperPadding: 0)
            
        case .headerForHomeListNews :
            updateLabel(labelText: labelText, font: FontBook.PlayFairMedium.of(size: 24), upperPadding: 0)
            updateCollectionView()
        
        case .headerForSearchListNews:
            updateLabel(labelText: labelText, font: FontBook.PoppinsMedium.of(size: 18), upperPadding: 24)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateLabel(labelText: String, font: UIFont?, upperPadding: CGFloat) {
        self.addSubview(label)
        label.text = labelText
        label.font = font
        
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: upperPadding),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
    }
    
   private func updateCollectionView() {
        self.addSubview(collectionView)
        
        collectionView.dataSource = self
        collectionView.delegate   = self
        
        collectionView.register(UINib(nibName: Constants.sliderButtonCollectionView, bundle: .main), forCellWithReuseIdentifier: Constants.sliderButtonCollectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15),
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfTitlesForButton.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.sliderButtonCollectionView, for: indexPath) as? SliderButtonCollectionViewCell
        
        cell?.updateUI(title: arrayOfTitlesForButton[indexPath.row])
        
        cell?.tapAction = { [weak self] button in //catch tap at searchButton slider
            self?.tapActionOnSearchButton?(button)
        }
        
        return cell ?? UICollectionViewCell()
    }
}

extension HeaderView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
            return CGSize(width: 130, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}



