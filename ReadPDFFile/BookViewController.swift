//
//  ViewController.swift
//  displayAndThumbnailsPDF
//
//  Created by LamHan on 7/16/18.
//  Copyright © 2018 LamHan. All rights reserved.
//

import UIKit
import PDFKit

class BookViewController: UIViewController, PDFViewDelegate, ThumbnailGridViewControllerDelegate, OutlineViewControllerDelegate, BookmarkViewControllerDelegate, SearchViewControllerDelegate{

    var bookmarkButton : UIBarButtonItem!
    var currentThumbnailViewcontroller : UIViewController?
    var currentOutlineViewcontroller : UIViewController?
    var currentBookmarkViewcontroller : UIViewController?
    
    var pdfView: PDFView = {
       let pdf = PDFView()
        pdf.translatesAutoresizingMaskIntoConstraints = false
        return pdf
    }()
    var pdfDocument: PDFDocument?
    let barHideOnTapGestureRecognizer = UITapGestureRecognizer()
    let tableContentsToggleSegmentedControl = UISegmentedControl(items: [#imageLiteral(resourceName: "Grid"),#imageLiteral(resourceName: "List"),#imageLiteral(resourceName: "Bookmark-N")])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(pdfViewPageChanged(_:)), name: .PDFViewPageChanged, object: nil)
        
        barHideOnTapGestureRecognizer.addTarget(self, action: #selector(gestureRecognizerdToggleVisibility(_:)))
        view.addGestureRecognizer(barHideOnTapGestureRecognizer)
        
        tableContentsToggleSegmentedControl.selectedSegmentIndex = 0
        tableContentsToggleSegmentedControl.addTarget(self, action: #selector(tonggleTableOfContentView(_:)), for: .valueChanged)
        
        setupLayout()
        //pdfView = PDFView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        guard let path = Bundle.main.url(forResource: "Sample", withExtension: "pdf") else { return }
        pdfDocument = PDFDocument(url: path)
        
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .horizontal
        pdfView.usePageViewController(true, withViewOptions: [UIPageViewControllerOptionInterPageSpacingKey: 20])
        
//        pdfView.addGestureRecognizer(pdfViewGestureRecognizer)
        
        pdfView.document = pdfDocument
        
        pdfThumbnailView.layoutMode = .horizontal
        pdfThumbnailView.pdfView = pdfView
        
        titleLabel.text = pdfDocument?.documentAttributes?["Title"] as? String
        
        updatePageNumberLabel()
        resume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.pdfView.autoScales = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustThumnailViewHeight()
    }
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (context) in
            self.adjustThumnailViewHeight()
        }, completion: nil)
    }

    func adjustThumnailViewHeight(){
        pdfThumbnailView.heightAnchor.constraint(equalToConstant: 44 + self.view.safeAreaInsets.bottom).isActive = true
    }
    
    @objc func pdfViewPageChanged(_ notification: Notification) {
//        if pdfViewGestureRecognizer.isTracking {
//            hideBars()
//        }
//        updateBookmarkStatus()
        updatePageNumberLabel()
        updateBookmarkStatus()
    }
    
    @objc func gestureRecognizerdToggleVisibility(_ gestureRecognizer: UITapGestureRecognizer) {
        if let navigationController = navigationController {
            if navigationController.navigationBar.alpha > 0 {
                hideBars()
            }else {
                showBars()
            }
        }
    }
    
    func resume() {
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Chevron"), style: .plain, target: self, action: #selector(back(_:)))
        let tableContentsTonggleBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "List"), style: .plain, target: self, action: #selector(showTableOfContents(_:)))
        let actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showActionMenu(_:)))
        navigationItem.leftBarButtonItems = [backButton,tableContentsTonggleBarButton,actionButton]
        
        let brightnessButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Brightness"), style: .plain, target: self, action: #selector(showAppearenceMenu(_:)))
        let searchButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Search"), style: .plain, target: self, action: #selector(showSearchView(_:)))
        bookmarkButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Bookmark-N"), style: .plain, target: self, action: #selector(addOrRemoveBookmark(_:)))
        navigationItem.rightBarButtonItems = [bookmarkButton,searchButton,brightnessButton]
        
        bottomView.alpha = 1
        pdfView.isHidden = false
        titleViewContainer.alpha = 1
        pageNumberViewContainer.alpha = 1
        thumbnailsGridViewContainer.isHidden = true
        outlineViewContainer.isHidden = true
        bookmarkViewContainer.isHidden = true
        
        barHideOnTapGestureRecognizer.isEnabled = true
        
        updatePageNumberLabel()
        updateBookmarkStatus()
        
        removeAllChildView()
    }
    
    @objc func back(_ sender: UIBarButtonItem){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func showTableOfContents(_ sender:UIBarButtonItem){
        showTableOfContents()
    }
    
    func showTableOfContents(){
        view.exchangeSubview(at: 0, withSubviewAt: 1)
        view.exchangeSubview(at: 0, withSubviewAt: 2)
        
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "Chevron"), style: .plain, target: self, action: #selector(back(_:)))
        let tableOfContentsToggleBarButton = UIBarButtonItem(customView: tableContentsToggleSegmentedControl)
        let resumeButton = UIBarButtonItem(title: NSLocalizedString("Resume", comment: ""), style: .plain, target: self, action: #selector(resume(_:)))
        navigationItem.leftBarButtonItems = [backButton,tableOfContentsToggleBarButton]
        navigationItem.rightBarButtonItems = [resumeButton]
        
        bottomView.alpha = 0
        
        tonggleTableOfContentView(tableContentsToggleSegmentedControl)
        
        barHideOnTapGestureRecognizer.isEnabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewcontroller = segue.destination as? ThumbnailGridViewController {
            viewcontroller.pdfDocument = pdfDocument
            viewcontroller.delegate = self
        }
    }
    
    func thumbnailGỉdViewController(_ thumbnailGridViewController: ThumbnailGridViewController, didSelectPage page: PDFPage) {
        print("get in here")
        resume()
        pdfView.go(to: page)
    }
    
    func outlineViewController(_ outlineViewController: OutlineViewController, didselectOutlintAt destination: PDFDestination) {
        resume()
        pdfView.go(to: destination)
    }
    
    func bookmarkViewController(_ bookmarkViewController: BookmarkViewController, didSelectedPage page: PDFPage) {
        resume()
        pdfView.go(to: page)
    }
    
    func searchViewController(_ searchViewController: SearchViewController, didSelectSearchResult page: PDFSelection) {
        page.color = .yellow
        pdfView.currentSelection = page
        pdfView.go(to: page)
        showBars()
    }
    
    func viewControllerForSelectedSegmentIndex(_ index:Int) -> UIViewController? {
        switch index {
        case 0:
            let thumbview = ThumbnailGridViewController(collectionViewLayout: UICollectionViewFlowLayout())
            thumbview.pdfDocument = pdfDocument
            thumbview.delegate = self
            print("Assign vc = thumbnail view")
            return thumbview
        case 1:
            let outline = OutlineViewController()
            outline.pdfDocument = pdfDocument
            outline.delegate = self
            print("Assign vc = outline view")
            return outline
        case 2:
            let bookmark = BookmarkViewController(collectionViewLayout: UICollectionViewFlowLayout())
            bookmark.pdfDocument = pdfDocument
            bookmark.delegate = self
            print("Assign vc = bookmark view")
            return bookmark
        default:
            return nil
        }
    }
    
    func removeViewChildFromParent(_ viewcontroller: UIViewController){
        guard parent != nil else {
            return
        }
        viewcontroller.willMove(toParentViewController: nil)
        viewcontroller.view.removeFromSuperview()
        viewcontroller.removeFromParentViewController()
    }
    
    func removeAllChildView() {
        if let _ = self.currentThumbnailViewcontroller {
            removeViewChildFromParent(currentThumbnailViewcontroller!)
        }
        if let _ = self.currentOutlineViewcontroller {
            removeViewChildFromParent(currentOutlineViewcontroller!)
        }
        if let _ = self.currentBookmarkViewcontroller {
            removeViewChildFromParent(currentBookmarkViewcontroller!)
        }
    }
    
    func addChildView(_ viewcontroller:UIViewController){
        addChildViewController(viewcontroller)
        view.addSubview(viewcontroller.view)
        viewcontroller.didMove(toParentViewController: self)
    }
    
    @objc func tonggleTableOfContentView(_ sender:UISegmentedControl){
        pdfView.isHidden = true
        titleViewContainer.alpha = 0
        pageNumberViewContainer.alpha = 0
        let selectedSegment = tableContentsToggleSegmentedControl.selectedSegmentIndex
        let child = viewControllerForSelectedSegmentIndex(selectedSegment)
        if selectedSegment == 0 {
            removeAllChildView()
            addChildView(child!)
            currentThumbnailViewcontroller = child
        }else if selectedSegment == 1 {
            removeAllChildView()
            addChildView(child!)
            currentOutlineViewcontroller = child
        }else {
            removeAllChildView()
            addChildView(child!)
            currentBookmarkViewcontroller = child
        }
    }
    
    @objc func resume(_ sender:UIBarButtonItem){
        resume()
    }
    
    @objc func showActionMenu(_ sender:UIBarButtonItem){
        
    }
    
    @objc func showAppearenceMenu(_ sender:UIBarButtonItem){
//        let appearanceViewController = AppearanceViewController()
//        appearanceViewController.modalPresentationStyle = .overCurrentContext
//        appearanceViewController.preferredContentSize = CGSize(width: 300, height: 44)
//        appearanceViewController.popoverPresentationController?.barButtonItem = sender
//        appearanceViewController.popoverPresentationController?.permittedArrowDirections = .up
//        appearanceViewController.popoverPresentationController?.delegate = self as? UIPopoverPresentationControllerDelegate
        let appearanceViewController = UIViewController()
        appearanceViewController.view.backgroundColor = .blue
        appearanceViewController.modalPresentationStyle = .overCurrentContext
        appearanceViewController.modalTransitionStyle = .crossDissolve
        present(appearanceViewController, animated: true, completion: nil)
    }
    
    @objc func showSearchView(_ sender:UIBarButtonItem){
        let searchViewController = SearchViewController()
        searchViewController.delegate = self
        searchViewController.pdfDocument = pdfDocument
        let navigationController = UINavigationController(rootViewController: searchViewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    @objc func addOrRemoveBookmark(_ sender:UIBarButtonItem){
        if let documentURL = pdfDocument?.documentURL?.absoluteString {
            var bookmarks = UserDefaults.standard.array(forKey: documentURL) as? [Int] ?? [Int]()
            if let currentPage = pdfView.currentPage,let pageIndex = pdfDocument?.index(for: currentPage) {
                if let index = bookmarks.index(of: pageIndex) {
                    bookmarks.remove(at: index)
                    UserDefaults.standard.set(bookmarks, forKey: documentURL)
                    bookmarkButton.image = #imageLiteral(resourceName: "Bookmark-N")
                }else {
                    UserDefaults.standard.set((bookmarks+[pageIndex]).sorted(), forKey: documentURL)
                    bookmarkButton.image = #imageLiteral(resourceName: "Bookmark-P")
                }
            }
        }
    }
    
    func hideBars(){
        if let navigationController = navigationController {
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                navigationController.navigationBar.alpha = 0
                self.titleViewContainer.alpha = 0
                self.pageNumberViewContainer.alpha = 0
                self.bottomView.alpha = 0
            }
        }
    }
    
    func showBars(){
        if let navigationController = navigationController {
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                navigationController.navigationBar.alpha = 1
                self.titleViewContainer.alpha = 1
                self.pageNumberViewContainer.alpha = 1
                self.bottomView.alpha = 1
            }
        }
    }
    
    private func updateBookmarkStatus(){
        if let documentURL = pdfDocument?.documentURL?.absoluteString,
        let bookmarks = UserDefaults.standard.array(forKey: documentURL) as? [Int],
            let currentPage = pdfView.currentPage, let pageIndex = pdfDocument?.index(for: currentPage) {
            bookmarkButton.image = bookmarks.contains(pageIndex) ? #imageLiteral(resourceName: "Bookmark-P") : #imageLiteral(resourceName: "Bookmark-N")
        }
    }
    
    private func updatePageNumberLabel() {
        if let currentPage = pdfView.currentPage, let index = pdfDocument?.index(for: currentPage), let pageCount = pdfDocument?.pageCount {
            pageNumberLabel.text = String(format: "%d/%d", index+1, pageCount)
        }else{
            pageNumberLabel.text = nil
        }
    }
    
    let thumbnailsGridViewContainer : UIView = {
       let grid = UIView()
        grid.translatesAutoresizingMaskIntoConstraints = false
        //grid.backgroundColor = .green
        return grid
    }()
    
    let outlineViewContainer : UIView = {
        let outline = UIView()
        outline.translatesAutoresizingMaskIntoConstraints = false
        outline.backgroundColor = .yellow
        return outline
    }()
    
    let bookmarkViewContainer : UIView = {
        let bookmark = UIView()
        bookmark.translatesAutoresizingMaskIntoConstraints = false
        bookmark.backgroundColor = .blue
        return bookmark
    }()
    
    let bottomView: UIView = {
        let bottom = UIView()
        bottom.translatesAutoresizingMaskIntoConstraints = false
        //bottom.backgroundColor = .blue
        return bottom
    }()
    
    let pdfThumbnailView : PDFThumbnailView =  {
       let pdf = PDFThumbnailView()
        pdf.translatesAutoresizingMaskIntoConstraints = false
        return pdf
    }()
    
    let pageNumberViewContainer : UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .black
        container.alpha = 0.5
        container.layer.cornerRadius = 4
        return container
    }()
    
    var pageNumberLabel : UILabel = {
       let pageNumber = UILabel()//frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        pageNumber.textAlignment = .center
        pageNumber.textColor = .white
        pageNumber.text = "13/234"
        pageNumber.font = .systemFont(ofSize: 20)
        pageNumber.contentMode = .scaleAspectFit
        pageNumber.numberOfLines = 0
        pageNumber.lineBreakMode = .byWordWrapping
        //pageNumber.adjustsFontSizeToFitWidth = true
        pageNumber.sizeToFit()
        return pageNumber
    }()
    
    let titleViewContainer : UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .red
        container.alpha = 0.5
        container.layer.cornerRadius = 4
        return container
    }()
    
    var titleLabel : UILabel = {
        let title = UILabel()//frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        title.textAlignment = .center
        title.textColor = .white
        title.text = "This is title"
        title.font = .systemFont(ofSize: 20)
        title.contentMode = .scaleAspectFit
        //pageNumber.adjustsFontSizeToFitWidth = true
        title.sizeToFit()
        return title
    }()
    
    func setupLayout() {
        
        self.view.addSubview(thumbnailsGridViewContainer)
        thumbnailsGridViewContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        thumbnailsGridViewContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        thumbnailsGridViewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        thumbnailsGridViewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        self.view.addSubview(outlineViewContainer)
        outlineViewContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        outlineViewContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        outlineViewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        outlineViewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        self.view.addSubview(bookmarkViewContainer)
        bookmarkViewContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        bookmarkViewContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        bookmarkViewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bookmarkViewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        
        self.view.addSubview(pdfView)
        pdfView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        self.view.addSubview(bottomView)
        bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(toolbar)
        toolbar.topAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
        toolbar.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor).isActive = true
        toolbar.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor).isActive = true
        toolbar.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor).isActive = true
        
        bottomView.addSubview(pdfThumbnailView)
        pdfThumbnailView.topAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
        pdfThumbnailView.leadingAnchor.constraint(equalTo: bottomView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfThumbnailView.trailingAnchor.constraint(equalTo: bottomView.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pdfThumbnailView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        self.view.addSubview(pageNumberViewContainer)
        pageNumberViewContainer.bottomAnchor.constraint(equalTo: bottomView.topAnchor, constant: -15).isActive = true
        pageNumberViewContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageNumberViewContainer.addSubview(pageNumberLabel)
//        pageNumberLabel.rightAnchor.constraint(equalTo: pageNumberViewContainer.rightAnchor, constant: -8).isActive = true
//        pageNumberLabel.bottomAnchor.constraint(equalTo: pageNumberViewContainer.bottomAnchor, constant: -4).isActive = true
//        pageNumberLabel.leftAnchor.constraint(equalTo: pageNumberViewContainer.leftAnchor, constant: 8).isActive = true
//        pageNumberLabel.topAnchor.constraint(equalTo: pageNumberViewContainer.topAnchor, constant: 4).isActive = true
        pageNumberViewContainer.addConstraintWithFormat(format: "H:|-8-[v0]-8-|", views: pageNumberLabel)
        pageNumberViewContainer.addConstraintWithFormat(format: "V:|-4-[v0]-4-|", views: pageNumberLabel)
        
        self.view.addSubview(titleViewContainer)
        titleViewContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        titleViewContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleViewContainer.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 15).isActive = true
        titleViewContainer.trailingAnchor.constraint(greaterThanOrEqualTo: view.trailingAnchor, constant: 15).isActive = true
        titleViewContainer.addSubview(titleLabel)
//        titleLabel.rightAnchor.constraint(equalTo: titleViewContainer.rightAnchor, constant: -8).isActive = true
//        titleLabel.bottomAnchor.constraint(equalTo: titleViewContainer.bottomAnchor, constant: -4).isActive = true
//        titleLabel.leftAnchor.constraint(equalTo: titleViewContainer.leftAnchor, constant: 8).isActive = true
//        titleLabel.topAnchor.constraint(equalTo: titleViewContainer.topAnchor, constant: 4).isActive = true
        titleViewContainer.addConstraintWithFormat(format: "H:|-8-[v0]-8-|", views: titleLabel)
        titleViewContainer.addConstraintWithFormat(format: "V:|-4-[v0]-4-|", views: titleLabel)
    }
    
}

extension UIView {
    func addConstraintWithFormat(format: String, views: UIView...){
        var viewDictionary = [String:UIView]()
        for (index,view) in views.enumerated() {
            let key = "v\(index)"
            viewDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewDictionary))
    }
}

//@nonobjc extension UIViewController {
//    func add(_ child: UIViewController, frame: CGRect? = nil){
//        addChildViewController(child)
//
//        if let frame = frame {
//            child.view.frame = frame
//        }
//        view.addSubview(child.view)
//        didMove(toParentViewController: self)
//    }
//
//    func remove(){
//        willMove(toParentViewController: nil)
//        view.removeFromSuperview()
//        removeFromParentViewController()
//    }
//}

