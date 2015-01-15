//
//  Player.swift
//  CardsAgainst
//
//  Created by JP Simard on 11/2/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import PeerKit

private let myName = UIDevice.currentDevice().name

struct Player: Hashable, Equatable, MPCSerializable {
    let name: String
    let me: Bool

    var displayName: String { return me ? "You" : name }

    var hashValue: Int { return name.hash }

    var mpcSerialized: NSData {
        return name.dataUsingEncoding(NSUTF8StringEncoding)!
    }

    init(name: String) {
        self.name = name
        me = (name == myName)
    }

    init(mpcSerialized: NSData) {
        name = NSString(data: mpcSerialized, encoding: NSUTF8StringEncoding)!
        me = (name == myName)
    }

    init(peer: MCPeerID) {
        name = peer.displayName
        me = (name == myName)
    }

    static func getMe() -> Player {
        return Player(name: myName)
    }
}

func ==(lhs: Player, rhs: Player) -> Bool {
    return lhs.name == rhs.name
}
