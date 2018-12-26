//
//  AppearanceViewController.swift
//  ReedPDFFile
//
//  Created by LamHan on 8/31/18.
//  Copyright © 2018 LamHan. All rights reserved.
//

import UIKit

class AppearanceViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        brightnessSlider.value = Float(UIScreen.main.brightness)
        brightnessSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        setupLayout()
    }
    
    let brightnessSlider : UISlider = {
       let brightness = UISlider()
        brightness.translatesAutoresizingMaskIntoConstraints = false
        return brightness
    }()
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        UIScreen.main.brightness = CGFloat(brightnessSlider.value)
    }
    
    func setupLayout() {
        let viewContainer = UIView()
        viewContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewContainer)
        view.addConstraintWithFormat(format: "H:|[v0]|", views: viewContainer)
        view.addConstraintWithFormat(format: "V:|[v0]|", views: viewContainer)
        
        viewContainer.addSubview(brightnessSlider)
        brightnessSlider.centerYAnchor.constraint(equalTo: viewContainer.centerYAnchor).isActive = true
        brightnessSlider.leadingAnchor.constraint(equalTo: viewContainer.leadingAnchor, constant: 16).isActive = true
        brightnessSlider.trailingAnchor.constraint(equalTo: viewContainer.trailingAnchor, constant: -16).isActive = true
    }
}
