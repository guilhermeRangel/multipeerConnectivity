//
//  ViewController.swift
//  MultipeerConectivity
//
//  Created by Guilherme Rangel on 19/04/20.
//  Copyright © 2020 Guilherme Rangel. All rights reserved.
//

import MultipeerConnectivity
import UIKit
import CryptoKit
import Foundation
class HomeViewController: UIViewController {
    
    enum Codigo: Int {
        case sendToAll = 0
        case sendToHost = -1
        case sendToPeer = -2
    }
    
    @IBOutlet weak var hostOrGuest: UILabel!
    @IBOutlet weak var connectionsLabel: UILabel!
    @IBOutlet weak var txtAreaChat: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var picker: UIPickerView!
   
    @IBOutlet weak var btnSend: UIButton!
    
    @IBOutlet weak var txtFiled: UITextField!
    
    
    var peerNumberInPicker = 0
    var msgWrited: String = ""
    var isHosting = false
    
    var listOfFiles = [String]()
    var myListOfFiles = [String]()
    
    var peerOnline = PeerOnline()
    var arrayPeers = ArrayPeersOnlineServer()
    
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
        
        
        
        txtAreaChat.delegate = self
        txtAreaChat.isEditable = false
        txtAreaChat.isScrollEnabled = true
        txtFiled.delegate = self
        
//                self.hideKeyboardWhenTappedAround()
//                self.view.addGestureRecognizer(UITapGestureRecognizer(target: self,                                                              action: #selector(HomeViewController.dismissKeyboard)))
        view.addSubview(picker)
        
        self.mcNearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: "teste")
        self.mcNearbyServiceAdvertiser?.delegate = self
        
        self.serviceNearbyBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: "teste")
        self.serviceNearbyBrowser?.delegate = self
        
        
        self.mcSession = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        
        configureButtons()
        
    }
    
    deinit {
        self.mcNearbyServiceAdvertiser?.stopAdvertisingPeer()
        self.serviceNearbyBrowser?.stopBrowsingForPeers()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        title = "P2P - \(UIDevice.current.name)"
        view.backgroundColor = .systemGray6
    }
    
    @IBAction func btnMeusArquivos(_ sender: UIButton) {
        //        if !isHosting{
        //            listOfFiles.removeAll()
        //            listOfFiles = myListOfFiles.map({$0})
        //            tableView.reloadData()
        //        }
    }
    
    
    
    @IBAction func btnRecursosDiponiveis(_ sender: UIButton) {
        //implementar logica para mandar uma mensagem para o host e o host enviar a lista de com todos, alimentar o listOfFiles recebido o host
        sendMsgPrivate(message: "request", peer: Codigo.sendToHost, peerIDRequest: myPeerID)
        
    }
    
    @IBAction func btnSolicitarRecurso(_ sender: UIButton) {
        //aqui eu seleciono o arquivo na table view e aperto esse botao  dai o host diz qm tem o arquivo e te devolve a posicao do array, dai manda outra mensagem automatica para ele e solicita o recurso e ele te envia automatico.
    }
    
    //MARK: - Botao para enviar mensagens
    @IBAction func btnSend(_ sender: UIButton) {
        txtAreaChat.insertText("\(UIDevice.current.name) :> \(msgWrited)\n")
        
        if peerNumberInPicker == 0{
            sendMsg(message: msgWrited)
        }else{
            sendMsgByPicker(message: msgWrited, peer: peerNumberInPicker)
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
    
    func sendOverlay(myPeer: String){
        if !isHosting {
            var peers:[MCPeerID] = []
            
            peers.append(mcSession.connectedPeers[0])
            do {
                try mcSession.send(myPeer.data(using: .utf8)!, toPeers: peers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
    }
    
    
    /// solicitar recurso para o servidor
    func peerToPeerRequest(message: String) {
        let str = message.split(separator: "-")
        
        
        let msg = "\(message)PeerRequest"
        
        var peers:[MCPeerID] = []
        
        peers.append(mcSession.connectedPeers[0])
        
        do {
            try mcSession.send(msg.data(using: .utf8)!, toPeers: peers, with: .reliable)
        }
        catch let error {
            NSLog("%@", "Error for sending: \(error)")
        }
        
    }
    
    func sendMsgByPicker(message: String, peer: Int) {
        //manda para o peer escolhido no picker
        var peers:[MCPeerID] = []
        
        // alterei aqui para compilar, mudar para funcionar o picker
        peers.append(mcSession.connectedPeers[peer])
        do {
            try mcSession.send(message.data(using: .utf8)!, toPeers: peers, with: .reliable)
        }
        catch let error {
            NSLog("%@", "Error for sending: \(error)")
        }
    }
    
    func sendMsgPrivate(message: String, peer: Codigo, peerIDRequest: MCPeerID?) {
        if self.mcSession.connectedPeers.count > 0 {
            if peer.rawValue == 0 {
                sendMsg(message: message)
                
                
                //envia msg com os arquivos para o host quando ele loga no sistema
            }else if peer.rawValue == -1{
                if !isHosting{
                    var peers:[MCPeerID] = []
                    
                    peers.append(mcSession.connectedPeers[0])
                    do {
                        try mcSession.send(message.data(using: .utf8)!, toPeers: peers, with: .reliable)
                    }
                    catch let error {
                        NSLog("%@", "Error for sending: \(error)")
                    }
                }
                
                ///envia mensagem para um peer especifico
            }else if peer.rawValue == -2 {
                var peers:[MCPeerID] = []
                peers.append(peerIDRequest!)
                
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
        self.mcNearbyServiceAdvertiser?.startAdvertisingPeer()
        self.serviceNearbyBrowser?.startBrowsingForPeers()
        let mcBrowser = MCBrowserViewController(serviceType: "teste", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
        getLocalFilesName()
        //        self.serviceNearbyBrowser?.stopBrowsingForPeers()
        
        
    }
    
    func startHosting(action: UIAlertAction)  {
        isHosting = true
        self.hostOrGuest.text = "Sou o Host"
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "teste", discoveryInfo: nil, session: mcSession)
        self.mcNearbyServiceAdvertiser?.startAdvertisingPeer()
        self.serviceNearbyBrowser?.startBrowsingForPeers()
        mcAdvertiserAssistant?.start()
        getLocalFilesName()
        
        self.tableView.reloadData()
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: {_ in
            
            if self.mcSession.connectedPeers.count == self.arrayPeers.allPeersOn.count {
                
                self.arrayPeers.allPeersOn.removeAll()
                
                print("Server - Removi todos do array.. esperando que eles se adicionem de novo")
                
            }else {
                print("alguem nao enviou ou saiu... Removendo ele da lista e desconectando")
                
                for p1 in self.mcSession.connectedPeers{
                    for p2 in self.arrayPeers.allPeersOn {
                        //se ele nao contem o p2 é pq ele ja foi removido ou saiu ou nao mandou a msg
                        if !p2.peerOnline.contains(p1.displayName){
                            let peerID: MCPeerID = MCPeerID(displayName: p2.peerOnline.first!)
                            self.mcSession.cancelConnectPeer(peerID)
                        }
                    }
                }
            }
        })
        
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

//MARK: - TextField Delegate Extension
extension HomeViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        btnSend.resignFirstResponder()
         msgWrited = textField.text ?? "enviado"
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
           btnSend.resignFirstResponder()
        msgWrited = textField.text ?? "enviado"
        
    }
    
    //captura a mensagem digitada
    @IBAction func txtField(_ sender: UITextField) {
        msgWrited = sender.text ?? "enviado"
    }
}


//MARK: - Funcoes
extension HomeViewController{
    
    
    func MD5(string: String) -> String {
        let digest = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())
        
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
    
    func sha256(name: String, type: String) -> String{
        let path = Bundle.main.path(forResource: name, ofType: type)!
        let data = FileManager.default.contents(atPath: path)!
        let digest = SHA256.hash(data: data)
        return digest.description
    }
    
    
    
    func getLocalFilesName() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        
        do {
            /// pega todos arquivos do diretorio do projeto
            let items = try fm.contentsOfDirectory(atPath: path)
            
            /// filtra os item que sao do tipo .txt ou .png
            let itensFiltered = items.filter { $0.hasSuffix("txt") || $0.hasSuffix("png")}
            
            /// pega dois item aleatorios para ser os seus arquivos base, deixando mais claro na hora da execucao
            guard let item1 = itensFiltered.randomElement() else { return }
            guard let item2 = itensFiltered.randomElement() else { return }
            
            let name = item1.split(separator: ".")
            let hasCalculated1 = sha256(name: name.first!.description, type: name.last!.description)
            
            
            let name2 = item2.split(separator: ".")
            let hasCalculated2 = sha256(name: name2.first!.description, type: name2.last!.description)
            //so o host deve ter essa lista de arquivos alimentado com os arquivos de todos
            if isHosting {
                
                listOfFiles.append("\(String(describing: item1))-\(myPeerID.displayName)-Hash:\(hasCalculated1)")
                print(hasCalculated1)
                myListOfFiles.append(item1)
                
                listOfFiles.append("\(String(describing: item2))-\(myPeerID.displayName)-Hash:\(hasCalculated2)")
                print(hasCalculated2)
                myListOfFiles.append(item2)
            }else {
                myListOfFiles.append(item1)
                myListOfFiles.append(item2)
            }
            
            
            
            self.tableView.reloadData()
            
        } catch  {
            let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func configureButtons() {
        _ = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showMyFilesAction))
        
        let status = UIBarButtonItem(image: UIImage(systemName: "circle.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal), landscapeImagePhone: nil, style: .plain, target: self, action: nil)
        
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


extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func setTableView(){
        tableView.allowsMultipleSelection = true
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return myListOfFiles.count
        } else if section == 1 {
            return listOfFiles.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        
        cell.selectionStyle = .default
        
        if indexPath.section == 0 {
            cell.textLabel?.text = myListOfFiles[indexPath.row]
        } else if indexPath.section == 1 {
            cell.textLabel?.text = listOfFiles[indexPath.row]
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "My Files"
        } else if section == 1 {
            return "Shared Files"
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            if !isHosting{
                showResquestFileAlert(with: listOfFiles[indexPath.row])
            }
        }
    }
    
    
    @objc func showResquestFileAlert(with name: String) {
        let ac = UIAlertController(title: "Voce solicitou o arquivo: \(name)", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            self.peerToPeerRequest(message: name)
            
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
}

