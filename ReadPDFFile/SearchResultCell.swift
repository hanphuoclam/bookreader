//
//  SearchResultCell.swift
//  displayAndThumbnailsPDF
//
//  Created by LamHan on 8/27/18.
//  Copyright © 2018 LamHan. All rights reserved.
//

import UIKit
let searchCellId = "searchCellId"


class SearchResultCell : UITableViewCell {
    
    var section : String? = nil {
        didSet{
            self.sectionLabel.text = section
        }
    }
    
    var pageNumber : String? = nil {
        didSet {
            self.pageNumberLabel.text = pageNumber
        }
    }
    
    var resultText : String? = nil
    var searchText : String? = nil
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        sectionLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        pageNumberLabel.textColor = .gray
        pageNumberLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        resultTextLabel.font = UIFont.preferredFont(forTextStyle: .body)
        
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let highlightRange = (resultText! as NSString).range(of: searchText!, options: .caseInsensitive)
        let attributedString = NSMutableAttributedString(string: resultText!)
        attributedString.addAttributes([.font: UIFont.boldSystemFont(ofSize: resultTextLabel.font.pointSize)], range: highlightRange)
        resultTextLabel.attributedText = attributedString
    }
    
    var sectionLabel : UILabel = {
       let section = UILabel()
        section.translatesAutoresizingMaskIntoConstraints = false
        return section
    }()
    
    var pageNumberLabel : UILabel = {
        let pageNumber = UILabel()
        pageNumber.translatesAutoresizingMaskIntoConstraints = false
        return pageNumber
    }()
    
    var resultTextLabel : UILabel = {
        let result = UILabel()
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    func setupLayout(){
        let viewContainer = UIView()
        viewContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(viewContainer)
        addConstraintWithFormat(format: "H:|[v0]|", views: viewContainer)
        addConstraintWithFormat(format: "V:|[v0]|", views: viewContainer)
        viewContainer.addSubview(sectionLabel)
        viewContainer.addSubview(pageNumberLabel)
        viewContainer.addSubview(resultTextLabel)
        
        pageNumberLabel.topAnchor.constraint(equalTo: viewContainer.topAnchor, constant: 8).isActive = true
        viewContainer.addConstraintWithFormat(format: "H:|-15-[v0]-(>=20)-[v1]-15-|", views: sectionLabel, pageNumberLabel)
        viewContainer.addConstraintWithFormat(format: "H:|-15-[v0]-15-|", views: resultTextLabel)
        
        viewContainer.addConstraintWithFormat(format: "V:|-8-[v0]-8-[v1(43)]-8-|", views: sectionLabel, resultTextLabel)
    }
}
