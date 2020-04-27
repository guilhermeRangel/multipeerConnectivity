//
//  ViewController.swift
//  MultipeerConectivity
//
//  Created by Guilherme Rangel on 19/04/20.
//  Copyright © 2020 Guilherme Rangel. All rights reserved.
//

import MultipeerConnectivity
import UIKit

class HomeViewController: UIViewController{
    
    var isHosting = false
    
    var listOfFiles = [String]()
    
    var peerID = MCPeerID(displayName: UIDevice.current.name)
    
    lazy var mcSession: MCSession = {
        let session = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
//    var mcSession: MCSession?
    var mcAdvertiserAssistant: MCAdvertiserAssistant?
    
    var mcNearbyServiceAdvertiser: MCNearbyServiceAdvertiser?
    var serviceNearbyBrowser: MCNearbyServiceBrowser?

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "P2P - \(UIDevice.current.name)"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.mcNearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "teste")
        self.mcNearbyServiceAdvertiser?.delegate = self
        
        self.serviceNearbyBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: "teste")
        self.serviceNearbyBrowser?.delegate = self
        
        self.mcSession = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        

        checkSessionHost()
        configureButtons()
        
        getLocalFilesName()
    }
    
    func checkSessionHost() {
//        if multipeerSession.session.connectedPeers.count == 0 {
//            print("sou host")
//            isHosting = true
//        }
    }
    

    func configureButtons() {
        let myFilesButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showMyFilesAction))
        
        let status = UIBarButtonItem(image: UIImage(systemName: "circle")?.withTintColor(.systemRed), landscapeImagePhone: nil, style: .plain, target: self, action: nil)
        
        let showDocumentsButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showConnectionPrompt))
        navigationItem.rightBarButtonItem = showDocumentsButton
        navigationItem.leftBarButtonItem = status
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
//        guard let mcSession = mcSession  else { return }
               
               self.serviceNearbyBrowser?.delegate = self
               self.serviceNearbyBrowser?.startBrowsingForPeers()
               let mcBrowser = MCBrowserViewController(serviceType: "teste", session: mcSession)
               mcBrowser.delegate = self
               present(mcBrowser, animated: true)
    }
    
    func startHosting(action: UIAlertAction)  {
//        guard let mcSession = mcSession  else { return }
               mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "teste", discoveryInfo: nil, session: mcSession)
               self.mcNearbyServiceAdvertiser?.startAdvertisingPeer()
               mcAdvertiserAssistant?.start()
    }

    func getLocalFilesName() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        
       
        
//        let subdir = Bundle.main.url(forResource: "Teste", withExtension: "txt", subdirectory: "Files/")

        
        do {
            let items = try fm.contentsOfDirectory(atPath: path)
             
            print("peguei os arquivos")
            
            for item in items {
                if item.hasSuffix("txt") {
                    
                    listOfFiles.append(item)
                }
            }
        } catch  {
            let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
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

