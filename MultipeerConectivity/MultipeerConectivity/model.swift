//
//  model.swift
//  MultipeerConectivity
//
//  Created by Guilherme Rangel on 29/04/20.
//  Copyright © 2020 Guilherme Rangel. All rights reserved.
//

import Foundation
struct PeerOnline {
    var peerOnline: [String:Int] = [:]
}

struct ArrayPeersOnlineServer {
    var allPeersOn:[PeerOnline] = []
}
