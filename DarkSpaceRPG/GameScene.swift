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
    var directionNodeCoord = CGPoint()
    var angleDifference : Float = 0
    private var activeTouches = [UITouch:String]()
    private var isAccelerated : Bool = false
    
    var score : Int = 0
    
    // Current system time taken from update function
    var currentSystemTime : TimeInterval = 0.0
    
    // Flag indicating whether we've setup the camera system yet.
    var isCreated: Bool = false
    // The root node of your game world. Attach game entities
    // (player, enemies, &c.) to here.
    var world: SKNode?
    // The root node of our UI. Attach control buttons & state
    // indicators here.
    var overlay: SKNode?
    // The camera. Move this node to change what parts of the world are visible.
    var lense: SKCameraNode?
    
    override func didSimulatePhysics() {
        if self.lense != nil {
            self.centerOnNode(node: self.player)
        }
    }
    
    func centerOnNode(node: SKNode) {
        let cameraPositionInScene: CGPoint = node.scene!.convert(node.position, from: node.parent!)
        
        node.parent?.position = CGPoint(x:(node.parent?.position.x)! - cameraPositionInScene.x, y:(node.parent?.position.y)! - cameraPositionInScene.y)
    }
    
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
    
    
    func reverseAngle(angle: Float) -> Float {
        if (angle < 0){
            return 180 + angle
        } else {
            return angle - 180
        }
    }
    
    
    func getPlayerDirection() -> Float {
        return reverseAngle(angle: Float(player.zRotation) / Float.pi * Float(180))
    }
    
    
    func getTouchDirection(coordinate: CGPoint) -> Float {
        if (coordinate.y >= 0){
            return -atan(Float(coordinate.x) / Float(coordinate.y)) * 180 / Float.pi
        } else {
            if (coordinate.x < 0){
                return atan(Float(coordinate.y) / Float(coordinate.x)) * 180 / Float.pi + 90
            } else {
                return atan(Float(coordinate.y) / Float(coordinate.x)) * 180 / Float.pi - 90
            }
        }
    }
    
    func applyAngularForceTo(node: SKSpriteNode, angle: Float){
        let angleSpeed : CGFloat = 3
        if (angle < -180) {
            node.physicsBody?.angularVelocity = -angleSpeed
        } else if (angle < -3) {
            node.physicsBody?.angularVelocity = angleSpeed
        } else if (angle < 3) {
            node.physicsBody?.angularVelocity = 0
        } else if (angle < 180) {
            node.physicsBody?.angularVelocity = -angleSpeed
        } else if (angle < 360) {
            node.physicsBody?.angularVelocity = angleSpeed
        }
    }
    
    // Add force to ship based on the position
    func accelerate(anglePosition: Float){
        let x = sin(-anglePosition * Float.pi / 180)
        let y = cos(-anglePosition * Float.pi / 180)
        let speed : Double = 20
        player.physicsBody?.applyForce(CGVector(dx: speed * Double(x), dy: speed * Double(y)))
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
        
        let touchDirection = getTouchDirection(coordinate: directionNodeCoord)
        let playerDirection = getPlayerDirection()
        if directionNodeCoord.x == 0 && directionNodeCoord.y == 0 {
            angleDifference = 0
        } else {
            angleDifference = playerDirection - touchDirection
        }
        
        applyAngularForceTo(node: player, angle: angleDifference)
        
        if isAccelerated {
            accelerate(anglePosition: getPlayerDirection())
        }
        
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
                    activeTouches[touch] = "direction"
                    directionNodeCoord = touch.location(in: self) - node.position
                }
                
                if node.name == "accelerateNode" {
                    
                    isAccelerated = true
                    print("accelerateNode touch began")
                    activeTouches[touch] = "accelerate"
                }
                if node.name == "shootNode" {
                    print("shootNode touch began")
                    activeTouches[touch] = "shoot"
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
                    directionNodeCoord = touch.location(in: self) - node.position
                    
                    print("player direction: ", getPlayerDirection())

                }
            }
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        for touch in touches {
            let touchLocation = touch.location(in: self)
            
            // End touches tracked
            let button = activeTouches[touch]
            if button == "accelerate" {
                isAccelerated = false
            } else if button == "direction" {
                directionNodeCoord = CGPoint(x: 0, y: 0)
            }
            activeTouches[touch] = nil
            
            
            // Get node without physics body
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
                self.overlay?.childNode(withName: "menuButton")?.removeFromParent()
            } else if node.name == "menuButton" {
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let scene = MainMenuScene(size: self.size)
                self.view?.presentScene(scene, transition: reveal)
            }
            
            
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
        pauseButton.position = CGPoint(x: pauseButton.size.width - self.frame.size.width/2, y: self.frame.height/2 - pauseButton.size.height)
        
        pauseButton.name = "pauseButton"
        pauseButton.zPosition = 10
        self.overlay?.addChild(pauseButton)
    }
    
    
    func addMenuButton() {
        let menuButton = SKLabelNode(text: "Back to main menu")
        menuButton.fontSize = 30
        menuButton.position = CGPoint(x: 0, y: 0 - menuButton.frame.size.height/2)
        menuButton.isHidden = false
        menuButton.name = "menuButton"
        menuButton.zPosition = 10
        
        self.overlay?.addChild(menuButton)
    }
    
    
    func addResumeButton() {
        let resumeButton = SKLabelNode(text: "Resume")
        resumeButton.fontSize = 50
        resumeButton.position = CGPoint(x: 0, y: resumeButton.frame.size.height/2)
        resumeButton.isHidden = false
        resumeButton.name = "resumeButton"
        resumeButton.zPosition = 10
        
        self.overlay?.addChild(resumeButton)
    }
    
    
    func addControlPad(){
        let directionNode = SKSpriteNode(imageNamed: "flatLight05")
        let accelerateNode = SKSpriteNode(imageNamed: "flatLight35")
        let shootNode = SKSpriteNode(imageNamed: "flatLight34")
        
        directionNode.size = CGSize(width: self.frame.size.width/6, height: self.frame.size.width/6)
        directionNode.position = CGPoint(x: self.frame.size.width/7 - self.frame.size.width/2, y: self.frame.size.width/7 - self.frame.size.height/2)
        directionNode.name = "directionNode"
        directionNode.zPosition = 10
        directionNode.physicsBody = SKPhysicsBody(circleOfRadius: directionNode.size.width/2)
        directionNode.physicsBody?.collisionBitMask = 0
        directionNode.physicsBody?.categoryBitMask = 0
        
        self.overlay?.addChild(directionNode)
        
        accelerateNode.size = CGSize(width: self.frame.size.width/10, height: self.frame.size.width/10)
        accelerateNode.position = CGPoint(x: self.frame.size.width/10*8 - self.frame.size.width/2, y: self.frame.size.height/10*1.5 - self.frame.size.height/2)
        accelerateNode.name = "accelerateNode"
        accelerateNode.zPosition = 10
        accelerateNode.physicsBody = SKPhysicsBody(circleOfRadius: accelerateNode.size.width/2)
        accelerateNode.physicsBody?.collisionBitMask = 0
        accelerateNode.physicsBody?.categoryBitMask = 0
        
        self.overlay?.addChild(accelerateNode)
        
        
        shootNode.size = accelerateNode.size
        shootNode.position = CGPoint(x: self.frame.size.width/10*9.2 - self.frame.size.width/2, y: self.frame.size.height/10*2.5 - self.frame.size.height/2)
        shootNode.name = "shootNode"
        shootNode.zPosition = 10
        shootNode.physicsBody = SKPhysicsBody(circleOfRadius: shootNode.size.width/2)
        shootNode.physicsBody?.collisionBitMask = 0
        shootNode.physicsBody?.categoryBitMask = 0
        
        self.overlay?.addChild(shootNode)
    }
    
    
    func createWorld(){
        // Add players
        player.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        player.size = CGSize(width: 50, height: 50)
        
        self.world?.addChild(player)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: CGSize(width: player.size.width, height: player.size.height))
        player.physicsBody?.linearDamping = 0.5
        player.physicsBody?.angularDamping = 0
        player.physicsBody?.collisionBitMask = 0x1
        
        let backgroundNode = SKSpriteNode(imageNamed: "starfield")
        backgroundNode.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        backgroundNode.physicsBody?.collisionBitMask = 0
        backgroundNode.zPosition = -1
        self.world?.addChild(backgroundNode)
        
    }
    
    
    override func didMove(to view: SKView) {
        print("Move to game scene, begin making scene")
        
        // Camera setup
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.world = SKNode()
        self.world?.name = "world"
        addChild(self.world!)
        
        self.lense = SKCameraNode()
        self.lense?.name = "lense"
        self.world?.addChild(self.lense!)
        
        // UI setup
        self.overlay = SKNode()
        self.overlay?.zPosition = 10
        self.overlay?.name = "overlay"
        addChild(self.overlay!)
        
        
        addPauseButton()
        addControlPad()
        createWorld()
    }
}
