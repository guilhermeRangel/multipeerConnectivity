//
//  ViewController.swift
//  MultipeerConectivity
//
//  Created by Guilherme Rangel on 19/04/20.
//  Copyright © 2020 Guilherme Rangel. All rights reserved.
//

import MultipeerConnectivity
import UIKit

class HomeViewController: UIViewController {
    
    
    @IBOutlet weak var hostOrGuest: UILabel!
    @IBOutlet weak var connectionsLabel: UILabel!
    @IBOutlet weak var txtAreaChat: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var txtFiled: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    
    
    var peerNumberInPicker = 0
    var msgWrited: String = ""
    var isHosting = false
    var listOfFiles = [String]()
    var arquivosEnviadosInit = false
    var myPeerID = MCPeerID(displayName: UIDevice.current.name)
    var mcAdvertiserAssistant: MCAdvertiserAssistant?
    var mcNearbyServiceAdvertiser: MCNearbyServiceAdvertiser?
    var serviceNearbyBrowser: MCNearbyServiceBrowser?
    lazy var mcSession: MCSession = {
        let session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        txtFiled.delegate = self
        txtAreaChat.delegate = self
        txtAreaChat.isEditable = false
        txtAreaChat.isScrollEnabled = true
        
        self.hideKeyboardWhenTappedAround()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                              action: #selector(HomeViewController.dismissKeyboard)))
        view.addSubview(picker)
        
        self.mcNearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: "teste")
        self.mcNearbyServiceAdvertiser?.delegate = self
        
        self.serviceNearbyBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: "teste")
        self.serviceNearbyBrowser?.delegate = self
        
        self.mcSession = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        
        configureButtons()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        title = "P2P - \(UIDevice.current.name)"
        view.backgroundColor = .systemGray6
    }
    
    //MARK: - Botao para enviar mensagens
    @IBAction func btnSend(_ sender: UIButton) {
        txtAreaChat.insertText("\(UIDevice.current.name) :> \(msgWrited)\n")
        
        if peerNumberInPicker == 0{
            sendMsg(message: msgWrited)
        }else{
            sendMsgPrivate(message: msgWrited, peer: 0)
        }
        
        txtFiled.text = ""
        peerNumberInPicker = 0
  
    }
    
   
    //MARK: - Envia mensagem para todos os peers
    func sendMsg(message : String) {
        
        do {
            try mcSession.send(message.data(using: .utf8)!, toPeers: mcSession.connectedPeers, with: .reliable)
            
        }
        catch let error {
            NSLog("%@", "Error for sending: \(error)")
        }
        
        
    }
    

    
    //MARK: - envia mensagem para o peer selecionado no piker
    func sendMsgPrivate(message: String, peer: Int) {
        if self.mcSession.connectedPeers.count > 0 {
            if peer == 0 {
                sendMsg(message: message)
            }else {
                var peers:[MCPeerID] = []
                peers.append(mcSession.connectedPeers[peer])
                do {
                    try mcSession.send(message.data(using: .utf8)!, toPeers: peers, with: .reliable)
                    
                }
                catch let error {
                    NSLog("%@", "Error for sending: \(error)")
                }
            }
        }
        
    }
    
    
  
    
    func joinSession(action: UIAlertAction)  {
        isHosting = false
        self.hostOrGuest.text = "Guest"
        self.serviceNearbyBrowser?.delegate = self
        self.serviceNearbyBrowser?.startBrowsingForPeers()
        let mcBrowser = MCBrowserViewController(serviceType: "teste", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
        arquivosEnviadosInit = true
        sendMsgPrivate(message: listOfFiles.description, peer: 0)
        print(listOfFiles.description)
    }
    
    func startHosting(action: UIAlertAction)  {
        isHosting = true
        self.hostOrGuest.text = "Sou o Host"
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "teste", discoveryInfo: nil, session: mcSession)
        self.mcNearbyServiceAdvertiser?.startAdvertisingPeer()
        mcAdvertiserAssistant?.start()
        getLocalFilesName()
        self.tableView.reloadData()
        
    }

}

//MARK: - UIPickerView
extension HomeViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        reloadInputViews()
        return mcSession.connectedPeers.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return "\(mcSession.connectedPeers[row].displayName)"
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        peerNumberInPicker = row
    }
    
}

 //MARK: - Funcoes
extension HomeViewController{
    
    func getLocalFilesName() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
//        let subdir = Bundle.main.url(forResource: "Teste", withExtension: "txt", subdirectory: "Files/")
        
        
        do {
            let items = try fm.contentsOfDirectory(atPath: path)
            print("peguei os arquivos e adicionei na lista")
            
            for item in items {
                if item.hasSuffix("txt") || item.hasSuffix("png"){
    
                    listOfFiles.append(item)
                }
            }
        } catch  {
            let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func configureButtons() {
          _ = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showMyFilesAction))
          
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
}

//MARK: - UITextViewDelegate
extension HomeViewController: UITextViewDelegate{
    func hideKeyboardWhenTappedAround() {
        let tapView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.dismissKeyboard))
        tapView.cancelsTouchesInView = false
        view.addGestureRecognizer(tapView)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
}


//MARK: - TextField Delegate Extension
extension HomeViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        btnSend.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    //captura a mensagem digitada
       @IBAction func txtField(_ sender: UITextField) {
           msgWrited = sender.text ?? "enviado"
           
           
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

