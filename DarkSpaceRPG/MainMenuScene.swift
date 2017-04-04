//
//  MenuScene.swift
//  spaceGame
//
//  Created by James Tran on 2/27/17.
//  Copyright © 2017 James Tran. All rights reserved.
//

//
//  GameOverUI.swift
//  spaceGame
//
//  Created by James Tran on 2/25/17.
//  Copyright © 2017 James Tran. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit


class MainMenuScene: SKScene {
    let startButton = SKLabelNode(text: "Start")
    let optionButton = SKLabelNode(text: "Option")
    
    func random() -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF)
    }
    
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat(random()) * (max - min) + min
    }
    
    
    func random(mid: Float, range: Float) -> Float {
        let max = mid + range
        let min = mid - range
        return random() * (max - min) + min
    }
    
    
    override func didMove(to view: SKView) {        
        self.backgroundColor = UIColor.black
        startButton.fontSize = 70
        startButton.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        startButton.fontColor = UIColor.white
        startButton.zPosition = 1
        addChild(startButton)
        
        /*optionButton.fontSize = 40
        optionButton.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2 - startButton.frame.size.height)
        optionButton.fontColor = UIColor.white
        optionButton.zPosition = 1
        addChild(optionButton)*/
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        if startButton.contains(touchLocation) {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameScene = GameScene(size: self.size)
            self.view?.presentScene(gameScene, transition: reveal)
        }
        
    }
}
