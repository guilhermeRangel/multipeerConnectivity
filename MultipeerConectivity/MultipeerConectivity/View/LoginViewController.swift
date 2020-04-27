//
//  LoginViewController.swift
//  MultipeerConectivity
//
//  Created by Matheus Lima Ferreira on 4/26/20.
//  Copyright © 2020 Guilherme Rangel. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
//    var homeVC: HomeViewController?
    var isHosting = false
    
    var mainStoryboard: UIStoryboard?
    
    let multipeerSession = MultipeerSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "LOGIN"

    }
    @IBAction func hostASession(_ sender: Any) {
    }
    @IBAction func joinSession(_ sender: Any) {
    }
}
