//
//  OutlineCell.swift
//  displayAndThumbnailsPDF
//
//  Created by LamHan on 8/21/18.
//  Copyright © 2018 LamHan. All rights reserved.
//

import UIKit

let outlineCellId = "outlineCellId"

class OutlineCell : UITableViewCell {
    
    var titleOutline : String? = nil {
        didSet {
            titleOutlineLabel.text = titleOutline
        }
    }
    
    var pageNumber : String? = nil {
        didSet {
            pageNumberLabel.text = pageNumber
        }
    }
    
    let titleOutlineLabel : UILabel = {
       let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    let pageNumberLabel : UILabel = {
       let pageNumber = UILabel()
        pageNumber.translatesAutoresizingMaskIntoConstraints = false
        return pageNumber
    }()
    
    let viewContainer : UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        titleOutlineLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CGFloat(15 + 10 * indentationLevel)).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        if indentationLevel == 0 {
            titleOutlineLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        }else {
            titleOutlineLabel.font = UIFont.preferredFont(forTextStyle: .body)
        }
        
        separatorInset = UIEdgeInsets(top: 0, left: safeAreaInsets.right + 15, bottom: 0, right: 0)
    }
    
    func setupLayout() {
        self.addSubview(viewContainer)
        viewContainer.topAnchor.constraint(equalTo: topAnchor).isActive = true
        viewContainer.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        viewContainer.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        viewContainer.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        viewContainer.addSubview(titleOutlineLabel)
        viewContainer.addSubview(pageNumberLabel)
        
        titleOutlineLabel.topAnchor.constraint(equalTo: viewContainer.topAnchor, constant: 8).isActive = true
        titleOutlineLabel.bottomAnchor.constraint(equalTo: viewContainer.bottomAnchor, constant: -8).isActive = true
//        titleOutlineLabel.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor, constant: 25).isActive = true
//        titleOutlineLabel.trailingAnchor.constraint(greaterThanOrEqualTo: pageNumberLabel.leadingAnchor, constant: 20).isActive = true
        pageNumberLabel.centerYAnchor.constraint(equalTo: viewContainer.centerYAnchor).isActive = true
        pageNumberLabel.trailingAnchor.constraint(equalTo: viewContainer.trailingAnchor, constant: -15).isActive = true
//        pageNumberLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleOutlineLabel.trailingAnchor, constant: 20).isActive = true
        viewContainer.addConstraintWithFormat(format: "H:|-25-[v0]-(>=20)-[v1]-15-|", views: titleOutlineLabel, pageNumberLabel)
    }
}
