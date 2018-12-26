//
//  BookmarkViewController.swift
//  displayAndThumbnailsPDF
//
//  Created by LamHan on 8/24/18.
//  Copyright © 2018 LamHan. All rights reserved.
//

import UIKit
import PDFKit

class BookmarkViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var pdfDocument : PDFDocument?
    var bookmarks = [Int]()
    
    weak var delegate : BookmarkViewControllerDelegate?
    
    let dowloadQueue = DispatchQueue(label: "com.lamhan.pdfviewer.thumbnail")
    
    let thumbnailCache = NSCache<NSNumber,UIImage>()
    
    var cellSize : CGSize {
        if let collectionview = collectionView {
            var width = collectionview.frame.width
            var height = collectionview.frame.height
            
            if width > height {
                swap(&width, &height)
            }
            width = (width - 20 * 4) / 3
            height = 1.5 * width
            return CGSize(width: width, height: height)
        }
        return CGSize(width: 100, height: 150)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set background
        let background = UIView()
        background.backgroundColor = .gray
        collectionView?.backgroundView = background
        
        //register cell
        collectionView?.register(ThumbnailGidCell.self, forCellWithReuseIdentifier: cellid)
        
        //Add notification
        NotificationCenter.default.addObserver(self, selector: #selector(userDefaultDidChange(_ :)), name: UserDefaults.didChangeNotification, object: nil)
        
        //refresh data
        refreshData()
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookmarks.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellid, for: indexPath) as! ThumbnailGidCell
        
        let pageNumber = bookmarks[indexPath.item]
        if let page = pdfDocument?.page(at: pageNumber) {
            cell.pageNumber = pageNumber
            
            let key = NSNumber(value: pageNumber)
            if let thumbnail = thumbnailCache.object(forKey: key) {
                cell.image = thumbnail
            }else {
                let cellsize = cellSize
                dowloadQueue.async {
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
        if let page = pdfDocument?.page(at: bookmarks[indexPath.item]) {
            delegate?.bookmarkViewController(self, didSelectedPage: page)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    @objc func userDefaultDidChange(_ notification:Notification) {
        refreshData()
    }
    
    func refreshData() {
        if let documentURL = pdfDocument?.documentURL?.absoluteString,
        let bookmarks = UserDefaults.standard.array(forKey: documentURL) as? [Int] {
            self.bookmarks = bookmarks
            collectionView?.reloadData()
        }
    }
    
}

protocol BookmarkViewControllerDelegate : class {
    func bookmarkViewController(_ bookmarkViewController: BookmarkViewController, didSelectedPage page : PDFPage)
}
