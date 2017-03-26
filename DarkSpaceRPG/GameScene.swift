//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by James Tran on 11/26/16.
//  Copyright © 2016 James Tran. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

let playerLaserCategory:UInt32 =  0x1 << 1
let enemyShipCategory:UInt32 =  0x1 << 2
let floorCategory:UInt32 = 0x1 << 3
let roofCategory:UInt32 = 0x1 << 4
let playerCategory:UInt32 = 0x1 << 5
let playerShieldCategory:UInt32 = 0x1 << 6
let enemyLaserCategory:UInt32 = 0x1 << 7

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}


extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}


class enemyShip: SKSpriteNode {
    var hp = 4
    var laserSpawnTime : TimeInterval = 0
}

class playerShip: SKSpriteNode {
    var hp : Double = 0.0
    var shield : Double = 0.0
    var armor : Double = 0.0
    var willDie : Bool = false
    
    func gotHit(damage: Double){
        if shield > damage {
            shield -= damage
            
        } else {
            shield = 0
            hp -= (damage - shield)
            
            if hp <= 0 {
                willDie = true
            }
        }
    }
    
    func addPlayersItem() {
        /*let engine = SKSpriteNode(imageNamed: "spaceParts_043")
        let gunRight = SKSpriteNode(imageNamed: "spaceParts_094")
        let gunLeft = SKSpriteNode(imageNamed: "spaceParts_094")
        
        gunRight.name = "playerGun"
        gunLeft.name = "playerGun"
        
        engine.setScale(0.5)
        engine.position = CGPoint(x: 0, y: -self.size.height - engine.size.height/2)
        
        gunRight.position = CGPoint(x: self.size.width, y: 0)
        gunLeft.position = CGPoint(x: -self.size.width, y: 0 )
        
        gunRight.zPosition = -1
        gunLeft.zPosition = -1
        
        
        
        addChild(engine)
        addChild(gunRight)
        addChild(gunLeft)*/
    }
    
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    let player = playerShip(imageNamed: "spaceShips_007")
    let score1 = SKSpriteNode(imageNamed: "numeral0")
    let score2 = SKSpriteNode(imageNamed: "numeral0")
    let score3 = SKSpriteNode(imageNamed: "numeral0")
    let playerLifeNum = SKSpriteNode(imageNamed: "numeral0")
    let direction = CGPoint()
    
    var score : Int = 0
    
    // Current system time taken from update function
    var currentSystemTime : TimeInterval = 0.0
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
    }
    
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
    
    
    func showGameOverScene(){
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let gameOverScene = GameOverScene(size: self.size)
        gameOverScene.score = self.score
        self.view?.presentScene(gameOverScene, transition: reveal)
    }
    
    func screenFlashesRed(){
        let redScreen = SKSpriteNode(color: UIColor.red, size: self.frame.size)
        redScreen.alpha = 0.2
        redScreen.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        addChild(redScreen)
        redScreen.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.2), SKAction.removeFromParent()]))
    }
    

    
    override func update(_ currentTime: TimeInterval) {
        currentSystemTime = currentTime
        
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody,secondBody : SKSpriteNode
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
            firstBody = contact.bodyA.node != nil ? contact.bodyA.node as! SKSpriteNode : SKSpriteNode()
            secondBody = contact.bodyB.node != nil ? contact.bodyB.node as! SKSpriteNode : SKSpriteNode()
        }
        else {
            firstBody = contact.bodyB.node != nil ? contact.bodyB.node as! SKSpriteNode : SKSpriteNode()
            secondBody = contact.bodyA.node != nil ? contact.bodyA.node as! SKSpriteNode : SKSpriteNode()
        }
        
        if (firstBody.physicsBody == nil || secondBody.physicsBody == nil) {
            return
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        for touch in touches {
            let touchLocation = touch.location(in: self)
            if let node : SKNode = self.physicsWorld.body(at: touchLocation)?.node {
                if node.name == "directionNode" {
                    print("directionNode touch began")
                    let direction : CGPoint = touch.location(in: self) - node.position
                    print("Direction of the movement is " + String(Float(direction.x)) + " for x and " + String(Float(direction.y)) + " for y")
                    
                }
                if node.name == "accelerateNode" {
                    print("accelerateNode touch began")
                }
                if node.name == "shootNode" {
                    print("shootNode touch began")
                }
            }
            
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        for touch in touches {
            let touchLocation = touch.location(in: self)
            if let node : SKNode = self.physicsWorld.body(at: touchLocation)?.node {
                if node.name == "directionNode" {
                    print("directionNode touch began")
                    let direction : CGPoint = touch.location(in: self) - node.position
                    print("Direction of the movement is " + String(Float(direction.x)) + " for x and " + String(Float(direction.y)) + " for y")
                    
                }
                if node.name == "accelerateNode" {
                    print("accelerateNode touch began")
                }
                if node.name == "shootNode" {
                    print("shootNode touch began")
                }
            }
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        
        
        let node : SKNode = self.atPoint(touchLocation)
        if node.name == "pauseButton" {
            if self.isPaused == false {
                addMenuButton()
                addResumeButton()
                self.isPaused = true
            }
        } else if node.name == "resumeButton" {
            self.isPaused = false
            node.removeFromParent()
            childNode(withName: "menuButton")?.removeFromParent()
        } else if node.name == "menuButton" {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let scene = MainMenuScene(size: self.size)
            self.view?.presentScene(scene, transition: reveal)
        }
    }
    
    
    func addPlayerLaser(){
        // Create a laser for each gun the player has
        self.player.enumerateChildNodes(withName: "playerGun", using: {
            (node: SKNode!, stop: UnsafeMutablePointer <ObjCBool>) -> Void in
            let laser = SKSpriteNode(imageNamed: "laserBlue15")
            laser.setScale(0.5)
            let speed: Double = 5
            laser.zPosition = 2
            laser.position = CGPoint(x: self.player.position.x + node.position.x/2, y: self.player.position.y + node.position.y)
            
            laser.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: laser.size.width,
                                                                  height: laser.size.height))
            laser.physicsBody?.categoryBitMask = playerLaserCategory
            laser.physicsBody?.contactTestBitMask = enemyShipCategory
            laser.physicsBody?.collisionBitMask = 0
            laser.physicsBody?.linearDamping = 0
            self.addChild(laser)
            laser.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: speed))
        })
    }
    
    
    func playerLaserExplode(x: CGFloat, y: CGFloat){
        let shot = SKSpriteNode(imageNamed: "laserBlue08")
        shot.setScale(0.5)
        shot.position = CGPoint(x: x, y: y)
        addChild(shot)
        let actionFade = SKAction.fadeOut(withDuration: 0.4)
        let actionDone = SKAction.removeFromParent()
        shot.run(SKAction.sequence([actionFade, actionDone]))
    }
    
    func enemyPlayerExplode(x: CGFloat, y: CGFloat){
        let shot = SKSpriteNode(imageNamed: "laserRed08")
        shot.setScale(0.5)
        shot.position = CGPoint(x: x, y: y)
        addChild(shot)
        let actionFade = SKAction.fadeOut(withDuration: 0.4)
        let actionDone = SKAction.removeFromParent()
        shot.run(SKAction.sequence([actionFade, actionDone]))
    }
    
    func updateScore(){
        let charInt1 : Int = Int(score / 100)
        let charInt2: Int = Int((score - charInt1*100) / 10)
        let charInt3: Int = Int(score - charInt1 * 100 - charInt2 * 10)
        putNumToNode(scoreChar: String(charInt1), charNode: score1)
        putNumToNode(scoreChar: String(charInt2), charNode: score2)
        putNumToNode(scoreChar: String(charInt3), charNode: score3)
    }
    
    //scoreChar needs to be less than 10
    func putNumToNode(scoreChar: String, charNode: SKSpriteNode){
        let fileName = "numeral" + scoreChar
        charNode.texture = SKTexture(imageNamed: fileName)
    }
    
    
    func addScoreBoard(){
        let charSizeWidth = score3.size.width
        let charSizeHeight = score3.size.height
        score3.position = CGPoint(x: self.frame.width - charSizeWidth, y: self.frame.height - charSizeHeight)
        score2.position = CGPoint(x: self.frame.width - charSizeWidth*2.1, y: self.frame.height - charSizeHeight)
        score1.position = CGPoint(x: self.frame.width - charSizeWidth*3.2, y: self.frame.height - charSizeHeight)
        score1.zPosition = 10
        score2.zPosition = 10
        score3.zPosition = 10
        addChild(score1)
        addChild(score2)
        addChild(score3)
    }
    
    func addPauseButton(){
        let pauseButton = SKSpriteNode(imageNamed: "flatLight12")
        pauseButton.position = CGPoint(x: pauseButton.size.width, y: self.frame.height - pauseButton.size.height)
        
        pauseButton.name = "pauseButton"
        pauseButton.zPosition = 10
        addChild(pauseButton)
    }
    
    
    func addMenuButton() {
        let menuButton = SKLabelNode(text: "Back to main menu")
        menuButton.fontSize = 30
        menuButton.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 - menuButton.frame.size.height)
        menuButton.isHidden = false
        menuButton.name = "menuButton"
        menuButton.zPosition = 10
        
        addChild(menuButton)
    }
    
    
    func addControlPad(){
        let directionNode = SKSpriteNode(imageNamed: "flatLight05")
        let accelerateNode = SKSpriteNode(imageNamed: "flatLight35")
        let shootNode = SKSpriteNode(imageNamed: "flatLight34")
        
        directionNode.size = CGSize(width: self.frame.size.width/6, height: self.frame.size.width/6)
        directionNode.position = CGPoint(x: self.frame.size.width/7, y: self.frame.size.width/7)
        directionNode.name = "directionNode"
        directionNode.zPosition = 10
        directionNode.physicsBody = SKPhysicsBody(circleOfRadius: directionNode.size.width/2)
        
        addChild(directionNode)
        
        accelerateNode.size = CGSize(width: self.frame.size.width/10, height: self.frame.size.width/10)
        accelerateNode.position = CGPoint(x: self.frame.size.width/10*8, y: self.frame.size.height/10*1.5)
        accelerateNode.name = "accelerateNode"
        accelerateNode.zPosition = 10
        accelerateNode.physicsBody = SKPhysicsBody(circleOfRadius: accelerateNode.size.width/2)
        
        addChild(accelerateNode)
        
        
        shootNode.size = accelerateNode.size
        shootNode.position = CGPoint(x: self.frame.size.width/10*9.2, y: self.frame.size.height/10*2.5)
        shootNode.name = "shootNode"
        shootNode.zPosition = 10
        shootNode.physicsBody = SKPhysicsBody(circleOfRadius: shootNode.size.width/2)
        
        addChild(shootNode)
    }
    
    
    func addResumeButton() {
        let resumeButton = SKLabelNode(text: "Resume")
        resumeButton.fontSize = 50
        resumeButton.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 + resumeButton.frame.size.height/2)
        resumeButton.isHidden = false
        resumeButton.name = "resumeButton"
        resumeButton.zPosition = 10
        
        addChild(resumeButton)
    }
    
    
    override func didMove(to view: SKView) {
        print("Move to game scene, begin making scene")
        addPauseButton()
        addControlPad()
        
        player.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        player.setScale(0.5)
        addChild(player)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: CGSize(width: player.size.width, height: player.size.height))
        player.physicsBody?.linearDamping = 0
        player.physicsBody?.mass = 0.02
        
    }
}
