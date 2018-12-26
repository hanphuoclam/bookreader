//
//  thumbnailsGirdViewController.swift
//  displayAndThumbnailsPDF
//
//  Created by LamHan on 8/11/18.
//  Copyright © 2018 LamHan. All rights reserved.
//

import UIKit
import PDFKit

let thumbviewid = "thumbviewid"

class ThumbnailGridViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var pdfDocument : PDFDocument?
    weak var delegate: ThumbnailGridViewControllerDelegate?
    
    private let downloadQueue = DispatchQueue(label: "com.lamhan.pdfview.thumbnail")
    let thumbnailCache = NSCache<NSNumber, UIImage>()
    
    var cellSize : CGSize {
        if let collectionView = collectionView {
            var width = collectionView.frame.width
            var height = collectionView.frame.height
            if width > height {
                swap(&width, &height)
            }
            width = (width - (20*4)) / 3
            height = width*1.5
            return CGSize(width: width, height: height)
        }
        return CGSize(width: 100, height: 150)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .gray
        collectionView?.backgroundView = backgroundView
        collectionView?.register(ThumbnailGidCell.self, forCellWithReuseIdentifier: cellid)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pdfDocument?.pageCount ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellid, for: indexPath) as! ThumbnailGidCell
        
        if let page = pdfDocument?.page(at: indexPath.item) {
            let pageNumber = indexPath.item
            cell.pageNumber = pageNumber
            
            let key = NSNumber(value: pageNumber)
            if let thumbnail = thumbnailCache.object(forKey: key) {
                cell.image = thumbnail
            }else {
                let cellsize = cellSize
                downloadQueue.async {
                    let thumbnail = page.thumbnail(of: cellsize, for: .cropBox)
                    self.thumbnailCache.setObject(thumbnail, forKey: key)
                    if cell.pageNumber == pageNumber {
                        DispatchQueue.main.async {
                            cell.image = thumbnail
                        }
                    }
                }
            }
        }
        
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let page = pdfDocument?.page(at: indexPath.item) {
            delegate?.thumbnailGỉdViewController(self, didSelectPage: page)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
        print("indexPath : \(indexPath.item)")
    }
}

protocol ThumbnailGridViewControllerDelegate : class {
    func thumbnailGỉdViewController(_ thumbnailGridViewController: ThumbnailGridViewController, didSelectPage page: PDFPage)
}
