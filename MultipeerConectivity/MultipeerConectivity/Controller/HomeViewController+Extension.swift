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
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            DispatchQueue.main.async {
                self.navigationItem.leftBarButtonItem?.image = UIImage(systemName: "circle.fill")
                
                self.connectionsLabel.text = "Conectados(\(session.connectedPeers.count)):\(session.connectedPeers.map{$0.displayName} )"
                self.picker.reloadAllComponents()
                self.tableView.reloadData()
                
            }
            
            print("Connected: \(peerID.displayName) ")
        case .connecting:
            print("Connecting...: \(peerID.displayName) ")
        case .notConnected:
            print("Not connected: \(peerID.displayName) ")
            DispatchQueue.main.async {
                self.navigationItem.leftBarButtonItem?.image = UIImage(systemName: "circle")
            }
        @unknown default:
            print("Unknow state received: \(peerID.displayName) ")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let str = String(data: data, encoding: .utf8)!
        
        if arquivosEnviadosInit == true {
            listOfFiles.append(str)
            self.tableView.reloadData()
        }
        OperationQueue.main.addOperation {
        self.txtAreaChat.insertText("\(peerID.displayName) > \(str)\n")
        }
       
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
}

extension HomeViewController: MCNearbyServiceAdvertiserDelegate  {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        //        guard let mcSession = mcSession else { return }
        
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
        browser.invitePeer(peerID, to: self.mcSession, withContext: nil, timeout: 10)    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lostPeer: \(peerID.displayName)")
    }
}

extension HomeViewController: MCBrowserViewControllerDelegate {
    
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
}
