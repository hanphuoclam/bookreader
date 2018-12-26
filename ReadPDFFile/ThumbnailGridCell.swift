//
//  thumbnailGridCell.swift
//  displayAndThumbnailsPDF
//
//  Created by LamHan on 8/14/18.
//  Copyright © 2018 LamHan. All rights reserved.
//

import UIKit

let cellid = "cellid"

class ThumbnailGidCell : UICollectionViewCell {
    
    var image : UIImage? = nil {
        didSet {
            pageImageView.image = image
        }
    }
    
    var pageNumber = 0 {
        didSet {
            pageNumberLabel.text = String(pageNumber)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    var pageImageView : UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    var pageNumberLabel : UILabel = {
       let pagenumber = UILabel()
        pagenumber.translatesAutoresizingMaskIntoConstraints = false
        return pagenumber
    }()
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        backgroundColor = .white
        self.addSubview(pageImageView)
        pageImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        pageImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        pageImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        pageImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    }
}
