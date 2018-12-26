//
//  OutlineViewController.swift
//  displayAndThumbnailsPDF
//
//  Created by LamHan on 8/21/18.
//  Copyright © 2018 LamHan. All rights reserved.
//

import UIKit
import PDFKit

class OutlineViewController: UITableViewController {
    
    var pdfDocument : PDFDocument?
    var outlineDocument = [PDFOutline]()
    weak var delegate : OutlineViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        
        if let rootOutline = pdfDocument?.outlineRoot {
            var stackOutline = [rootOutline]
            while !stackOutline.isEmpty {
                let currentOutline = stackOutline.removeLast()
                if let titleOutline = currentOutline.label, !titleOutline.isEmpty {
                    outlineDocument.append(currentOutline)
                }
                for i in (0..<currentOutline.numberOfChildren).reversed() {
                    stackOutline.append(currentOutline.child(at: i)!)
                }
            }
        }
        print("outline document count : \(outlineDocument.count)")
        //Register table view cell
        tableView.register(OutlineCell.self, forCellReuseIdentifier: outlineCellId)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return outlineDocument.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: outlineCellId, for: indexPath) as! OutlineCell
        let outline = outlineDocument[indexPath.item]

        cell.titleOutline = outline.label
        cell.pageNumber = outline.destination?.page?.label

        var parent = outline.parent
        var indentation = -1
        while let _ = parent {
            indentation += 1
            parent = parent?.parent
        }

        cell.indentationLevel = indentation
        cell.titleOutlineLabel.numberOfLines = 0
        cell.titleOutlineLabel.lineBreakMode = .byWordWrapping
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let outline = outlineDocument[indexPath.item]
        if let destination = outline.destination {
            delegate?.outlineViewController(self, didselectOutlintAt: destination)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

protocol OutlineViewControllerDelegate : class {
    func outlineViewController(_ outlineViewController: OutlineViewController, didselectOutlintAt destination: PDFDestination)
}

