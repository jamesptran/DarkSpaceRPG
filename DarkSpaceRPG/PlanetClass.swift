//
//  PlanetClass.swift
//  DarkSpaceRPG
//
//  Created by James Tran on 5/17/17.
//  Copyright © 2017 James Tran. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import CoreMotion

enum planetName {
    case Tespadus
    case Oetania
    case Otriunope
    case Ciyrilia
    case Fublenerth
    case Eproinia
    case Skoevis
    case Duchielara
    case Buenov
    case Jetrone
}


class Planet {
    private var enumName : planetName
    var name : String
    private var station : SKSpriteNode
    private var stationPosition : CGPoint
    var planetTileGroup : SKTileGroup
    
    init(_ initName : planetName) {
        self.enumName = initName
        switch enumName {
        case .Tespadus:
            self.name = "Testpadus"
            self.planetTileGroup = SKTileSet(named: "Background")!.tileGroups[1]
        case .Oetania:
            self.name = "Oetania"
            self.planetTileGroup = SKTileSet(named: "Background")!.tileGroups[2]
        case .Otriunope:
            self.name = "Otriunope"
            self.planetTileGroup = SKTileSet(named: "Background")!.tileGroups[3]
        case .Ciyrilia:
            self.name = "Ciyrilia"
            self.planetTileGroup = SKTileSet(named: "Background")!.tileGroups[4]
        case .Fublenerth:
            self.name = "Fublenerth"
            self.planetTileGroup = SKTileSet(named: "Background")!.tileGroups[5]
        case .Eproinia:
            self.name = "Eproinia"
            self.planetTileGroup = SKTileSet(named: "Background")!.tileGroups[6]
        case .Skoevis:
            self.name = "Skoevis"
            self.planetTileGroup = SKTileSet(named: "Background")!.tileGroups[7]
        case .Duchielara:
            self.name = "Duchielara"
            self.planetTileGroup = SKTileSet(named: "Background")!.tileGroups[8]
        case .Buenov:
            self.name = "Buenov"
            self.planetTileGroup = SKTileSet(named: "Background")!.tileGroups[9]
        case .Jetrone:
            self.name = "Jetrone"
            self.planetTileGroup = SKTileSet(named: "Background")!.tileGroups[10]
        }
        
        self.station = SKSpriteNode()
        self.stationPosition = CGPoint()
    }
    
    
    
}
