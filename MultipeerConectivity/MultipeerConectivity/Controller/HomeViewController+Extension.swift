//
//  HomeViewController+Extension.swift
//  MultipeerConectivity
//
//  Created by Matheus Lima Ferreira on 4/27/20.
//  Copyright © 2020 Guilherme Rangel. All rights reserved.
//

import MultipeerConnectivity
import UIKit



extension HomeViewController: MCSessionDelegate {
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            DispatchQueue.main.async {
                self.navigationItem.leftBarButtonItem?.image = UIImage(systemName: "circle.fill")
                //modelo [[Nome:Posicao],..]
                if self.isHosting{
                    
                    self.tableView.reloadData()
                    
                }
                
                self.connectionsLabel.text = "Conectados(\(session.connectedPeers.count)):\(session.connectedPeers.map{$0.displayName} )"
                self.picker.reloadAllComponents()
                
            }
            
            print("Connected: \(peerID.displayName) ")
        case .connecting:
            print("Connecting...: \(peerID.displayName) ")
        case .notConnected:
            print("Not connected: \(peerID.displayName) ")
            DispatchQueue.main.async {
                self.navigationItem.leftBarButtonItem?.image = UIImage(systemName: "circle.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
            }
        @unknown default:
            print("Unknow state received: \(peerID.displayName) ")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let str = String(data: data, encoding: .utf8)!
        
        if str.contains("hash") {
            var _: [String] = []
            //MARK: - Tratar melhor, cansei aqui
            let arquivo = str.split(separator: ";")
            
            for arq in arquivo {
                let hash = MD5(string: String(arq))
                let stringWithHash = "\(arq)-\(peerID.displayName)-Hash:\(hash)"
                
                listOfFiles.append(String(stringWithHash))
            }
            
            OperationQueue.main.addOperation {
                
                self.tableView.reloadData()
            }
            
            
            
        }else if str.contains("overlay"){
            
            
            self.peerOnline.peerOnline.append(peerID.displayName)
            self.arrayPeers.allPeersOn.append(self.peerOnline)
            
            
        }else if str.contains("request"){
            
            //            var arquivos: [String] = []
            
            
            sendMsgPrivate(message: "\(listOfFiles)", peer: .sendToPeer, peerIDRequest: peerID)
            //            print(arquivos)
        }
            
            ///servidor está buscando peer dono do arquivo
        else if str.contains("PeerRequest") {
            
            let message = str.split(separator: "-")
            
            let fileName = message.first!
            
            let owner = message[1]
            
            let msg = "\(fileName)-\(owner)"
            let msgStr = String(msg)
            
            print("procurando peer: \(owner)")
            
            dump(mcSession.connectedPeers)
            
            //            let ownerPeerID = mcSession.connectedPeers.filter { $0.displayName.elementsEqual(owner) || $0.displayName.contains(owner)}
            
            var ownerPeerID: MCPeerID?
            
            mcSession.connectedPeers.forEach { peer in
                if peer.displayName.elementsEqual(owner) || peer.displayName.contains(owner) {
                    ownerPeerID = peer
                }
            }
            
            dump("encontrado: \(ownerPeerID)" )
            
            
            sendMsgPrivate(message: "\(msgStr)-P2P-\(peerID.displayName)", peer: .sendToPeer, peerIDRequest: ownerPeerID)
            
            
        }
            // dono do arquivo deve enviar o arquivo solicitado
        else if str.contains("P2P") {
            // "[\"Teste.txt\"-iPhone SE (2nd generation))-P2P-iPhone de Matheus
            
            // "[\"Teste.txt\"
            
            //enviando posicao a cada 5s
            
            //iPhone de Matheus
            
            let message = str.split(separator: "-")
            
            let fileName = message.first!
            
            let destination = message.last!
            
            print(str)
            
            print(fileName)
            print(destination)
            print("recebi a solicitacao para enviar para o peer que pediu")
            
            
            let fileNameSplitted = fileName.split(separator: ".")
            let name = String(fileNameSplitted.first!)
            let fileType = String(fileNameSplitted.last!)
            
            let fm = FileManager.default
            guard let path = Bundle.main.path(forResource: name, ofType: fileType) else { return }
            
            // procura o MCPeerID do destino
            let peerToSend = mcSession.connectedPeers.filter {$0.displayName == destination}
            
            
             let url = URL(fileURLWithPath: path)
                do {
                    mcSession.sendResource(at: url, withName: url.lastPathComponent, toPeer: peerToSend.first!) { (error) in
                        if error != nil {
                            print("Erro ao enviar o arquiv: \(error)")
                        }
                    }
                    
                }
                catch let error {
                    NSLog("%@", "Error for sending: \(error)")
                }
                
            
            
            
//            mcSession.sendResource(at: URL(string: path!)!, withName: String(fileName), toPeer: peerToSend.first!) { (error) in
//                if error != nil {
//                    print("Error ao enviar arquivo: \(error)")
//                }
//            }
            
        }
        
        OperationQueue.main.addOperation {
            self.txtAreaChat.insertText("\(peerID.displayName) > \(str)\n")
        }
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("nao é esse")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("Recebendo arquivo: \(resourceName)")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
        print("Nome do arquivo: \(localURL?.absoluteString)")
        
        /// pega o path da pasta download

        let path = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Download")
        
        print("Teste path \(path?.first?.absoluteString)")
        
        let path2 = Bundle.main.bundleURL
        
        
        let complete = path2.appendingPathComponent("Download", isDirectory: true)
        
        print("Teste complete path with name \(complete.absoluteString)")
            do {
                let destinationURL =  complete
                try FileManager.default.moveItem(at: localURL!, to: destinationURL)
                print("Recebeu")
            } catch  {
                print("Error: \(error)")
            }
        
        
        
        if error != nil {
            print("Erro ao receber o arquivo: \(resourceName)")
        }
        
        
        
//        if let data = try? Data(contentsOf: localURL!) {
//            print(data)
//        }
        
        
        print("Recebeu arquivo: \(resourceName)")
    }
}

extension HomeViewController: MCNearbyServiceAdvertiserDelegate  {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        print("didReceiveInvitationFromPeer: \(peerID.displayName)")
        invitationHandler(true, self.mcSession)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("didNotStartAdvertisingPeer: \(error)")
    }
    
}

extension HomeViewController: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("found peer: \(peerID.displayName)")
        //        guard let mcSession = mcSession else { return }
        browser.invitePeer(peerID, to: mcSession, withContext: nil, timeout: 20)    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lostPeer: \(peerID.displayName)")
    }
}

extension HomeViewController: MCBrowserViewControllerDelegate {
    
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        print("browserViewControllerDidFinish")
        dismiss(animated: true)
        
        if !isHosting {
            var message = ""
            
            self.myListOfFiles.forEach {message += "\($0);"}
            self.sendMsgPrivate(message: "\(message);hash", peer: .sendToHost, peerIDRequest: nil)
            
            print(message)
            Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: {_ in
                print("enviando posicao a cada 5s")
                self.sendOverlay(myPeer: "\(self.myPeerID.displayName)-overlay")
            })
        }
        
//                self.serviceNearbyBrowser?.stopBrowsingForPeers()
        
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
}
