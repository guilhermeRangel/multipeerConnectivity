//
//  Parse.swift
//  ConnectedColors
//
//  Created by Guilherme Rangel on 23/04/20.
//  Copyright © 2020 Example. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol MultipeerServiceDelegate {
    
    func connectedDevicesChanged(manager : MultipeerSession, connectedDevices: [String])
    func colorChanged(manager : MultipeerSession, object: String, msgsTxtArea: String)
    
    
}

class MultipeerSession: NSObject, MCAdvertiserAssistantDelegate {
    
   
    
    private let ServerName = "ChatRoom"
    
    var isHosting = false
    
    var homeVC: UIViewController?
    
    //exibe o nome da conexao do dispositivo
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    
//    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private var serviceAdvertiserAssistant: MCAdvertiserAssistant?
    private var serviceBrowser: MCNearbyServiceBrowser?
    
    var delegate: MultipeerServiceDelegate?
    
    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    override init() {
        super.init()
        
//        self.serviceAdvertiserAssistant = MCAdvertiserAssistant(serviceType: ServerName, discoveryInfo: nil, session: self.session)
        self.serviceBrowser  = MCNearbyServiceBrowser(peer: myPeerId, serviceType: ServerName)
        
        
        self.serviceAdvertiserAssistant?.delegate = self
        self.serviceBrowser?.delegate = self
    }
    
    deinit {
        self.serviceAdvertiserAssistant?.stop()
        self.serviceBrowser?.stopBrowsingForPeers()
    }
    
    func sendMsg(message : String) {
        if session.connectedPeers.count > 0 {
            do {
                
                try self.session.send(message.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
                
                
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
        
    }
    func sendMsgPrivate(message: String, peer: Int) {
        
        if peer == 99 {
            sendMsg(message: message)
        }else {
            var peers:[MCPeerID] = []
            
            peers.append(session.connectedPeers[peer])
            if session.connectedPeers.count > 0 {
                do {
                    
                    try self.session.send(message.data(using: .utf8)!, toPeers: peers, with: .reliable)
                    
                }
                catch let error {
                    NSLog("%@", "Error for sending: \(error)")
                }
            }
        }
    }
    
    func startHosting() {
//        guard let mcSession = session  else { return }
//               mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "teste", discoveryInfo: nil, session: mcSession)
       self.serviceAdvertiserAssistant = MCAdvertiserAssistant(serviceType: ServerName, discoveryInfo: nil, session: self.session)
               serviceAdvertiserAssistant?.start()
    }
    
    func joinSession() -> MCBrowserViewController{
      
        self.serviceBrowser  = MCNearbyServiceBrowser(peer: myPeerId, serviceType: ServerName)
        serviceBrowser?.startBrowsingForPeers()
        let mcBrowser = MCBrowserViewController(serviceType: ServerName, session: session)
        return mcBrowser
    }
    
    func getViewController(view: UIViewController) {
        homeVC = view
    }
    
}

extension MultipeerSession: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        //NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        //NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
    
}

extension MultipeerSession : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        //NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        //NSLog("%@", "foundPeer: \(peerID)")
        //NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        //NSLog("%@", "lostPeer: \(peerID)")
    }
    
}

extension MultipeerSession: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        }
        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices:
            session.connectedPeers.map{$0.displayName})
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // NSLog("%@", "didReceiveData: \(data)")
        let str = String(data: data, encoding: .utf8)!
        
        self.delegate?.colorChanged(manager: self, object: str, msgsTxtArea: "\(peerID.displayName) > \(str)")
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        //NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
}

extension MultipeerSession: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
//        browserViewController.dismiss(animated: true, completion: nil)
        
        homeVC?.dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
//        browserViewController.dismiss(animated: true, completion: nil)
        homeVC?.dismiss(animated: true)
    }
    
     
}
