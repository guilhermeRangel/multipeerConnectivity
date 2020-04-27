//
//  ViewController.swift
//  MultipeerConectivity
//
//  Created by Guilherme Rangel on 19/04/20.
//  Copyright © 2020 Guilherme Rangel. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    var isHosting = false
    
    let multipeerSession = MultipeerSession()
    
    var listOfFiles = [String]()

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.multipeerSession.delegate = self
        
        view.backgroundColor = .systemBackground
        title = "P2P - \(UIDevice.current.name)"
        self.navigationController?.navigationBar.prefersLargeTitles = true

        checkSessionHost()
        configureButtons()
        
        multipeerSession.getViewController(view: self)
    }
    
    func checkSessionHost() {
        if multipeerSession.session.connectedPeers.count == 0 {
            print("sou host")
            isHosting = true
        }
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
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func joinSession(action: UIAlertAction)  {
        multipeerSession.isHosting = false
        let mcBrowser = multipeerSession.joinSession()
        present(mcBrowser, animated: true)
    }
    
    func startHosting(action: UIAlertAction)  {
        multipeerSession.isHosting = true
        multipeerSession.startHosting()
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        
        cell.selectionStyle = .default
        
        cell.textLabel?.text = listOfFiles[indexPath.row]
        
        return cell
    }
    
    
}

extension HomeViewController: MultipeerServiceDelegate {
    func connectedDevicesChanged(manager: MultipeerSession, connectedDevices: [String]) {
        
    }
    
    func colorChanged(manager: MultipeerSession, object: String, msgsTxtArea: String) {
        
    }
    
    
}

