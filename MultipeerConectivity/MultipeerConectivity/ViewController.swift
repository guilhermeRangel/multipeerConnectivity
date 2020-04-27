//
//  ViewController.swift
//  MultipeerConectivity
//
//  Created by Guilherme Rangel on 19/04/20.
//  Copyright © 2020 Guilherme Rangel. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        title = "P2P - \(UIDevice.current.name)"
        self.navigationController?.navigationBar.prefersLargeTitles = true

        configureButtons()
    }


    func configureButtons() {
        let myFilesButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showMyFilesAction))
        let showDocumentsButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showConnectionPrompt))
        navigationItem.rightBarButtonItem = showDocumentsButton
        navigationItem.leftBarButtonItem = myFilesButton
    }
    
    @objc func showMyFilesAction() {
        
    }
    
    @objc func showConnectionPrompt() {
        
    }
}

