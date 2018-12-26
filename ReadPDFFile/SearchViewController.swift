//
//  SearchViewController.swift
//  displayAndThumbnailsPDF
//
//  Created by LamHan on 8/27/18.
//  Copyright © 2018 LamHan. All rights reserved.
//

import UIKit
import PDFKit

class SearchViewController: UITableViewController,  UISearchBarDelegate, PDFDocumentDelegate {
    var pdfDocument : PDFDocument?
    weak var delegate : SearchViewControllerDelegate?
    
    var searchBar = UISearchBar()
    var searchResults = [PDFSelection]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.searchBarStyle = .minimal
        navigationItem.titleView = searchBar
        
        tableView.rowHeight = 88
        //register cell
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: searchCellId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        pdfDocument?.delegate = nil
        pdfDocument?.cancelFindString()
        
        let searchText = searchBar.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        if searchText.count >= 3 {
            searchResults.removeAll()
            tableView.reloadData()
            pdfDocument?.delegate = self
            pdfDocument?.beginFindString(searchText, withOptions: .caseInsensitive)
        }
    }
    
    func didMatchString(_ instance: PDFSelection) {
        searchResults.append(instance)
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Results : "
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: searchCellId, for: indexPath) as! SearchResultCell
        
        let selection = searchResults[indexPath.row]
        
        let extendSelection = selection.copy() as! PDFSelection
        extendSelection.extendForLineBoundaries()
        
        let outline = pdfDocument?.outlineItem(for: selection)
        cell.section = outline?.label
        
        let pageNumber = selection.pages[0]
        cell.pageNumber = pageNumber.label
        
        cell.searchText = selection.string
        cell.resultText = extendSelection.string
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selection = searchResults[indexPath.row]
        searchBar.resignFirstResponder()
        delegate?.searchViewController(self, didSelectSearchResult: selection)
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true, completion: nil)
    }
}

protocol SearchViewControllerDelegate : class {
    func searchViewController(_ searchViewController: SearchViewController, didSelectSearchResult page: PDFSelection)
}
