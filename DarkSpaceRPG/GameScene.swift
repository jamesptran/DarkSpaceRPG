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


protocol backGround {
    func addMoreBackgroundNode()
}

extension backGround {
    func addMoreBackgroundNode(){
        print("Add background")
    }
}

class enemyShip: SKSpriteNode, backGround {
    var hp = 4
    var laserSpawnTime : TimeInterval = 0
}

class playerShip: SKSpriteNode {
    var hp : Double = 0.0
    var shield : Double = 0.0
    var armor : Double = 0.0
    var willDie : Bool = false
    var laserSpawnTime : TimeInterval = 0
    
    
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
    private let player = playerShip(imageNamed: "spaceShips_001")
    private let score1 = SKSpriteNode(imageNamed: "numeral0")
    private let score2 = SKSpriteNode(imageNamed: "numeral0")
    private let score3 = SKSpriteNode(imageNamed: "numeral0")
    private let playerLifeNum = SKSpriteNode(imageNamed: "numeral0")
    private var directionNodeCoord = CGPoint()
    private var angleDifference : Float = 0
    private var activeTouches = [UITouch:String]()
    private var isAccelerated : Bool = false
    private var isShooting : Bool = false
    private var map : SKTileMapNode = SKTileMapNode()
    private var coordinateColumn : Int = 0
    private var coordinateRow : Int = 0
    
    
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
    
    
    func reversezRotation(zRotation: CGFloat) -> CGFloat {
        if (zRotation < 0){
            return CGFloat.pi + zRotation
        } else {
            return zRotation - CGFloat.pi
        }
    }
    
    
    func getDirection(zRotation: CGFloat) -> Float {
        return reverseAngle(angle: Float(zRotation) / Float.pi * Float(180))
    }
    
    
    func getDirection(coordinate: CGPoint) -> Float {
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
        let angleSpeed : CGFloat = 4
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
    func accelerate(anglePosition: Float, maxSpeed: CGVector, accelerateForce: Double){
        let x = sin(-anglePosition * Float.pi / 180)
        let y = cos(-anglePosition * Float.pi / 180)
        
        if (player.physicsBody?.velocity ?? CGVector(dx: 0, dy: 0)) < maxSpeed {
            player.physicsBody?.applyForce(CGVector(dx: accelerateForce * Double(x), dy: accelerateForce * Double(y)))
        }
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
    
    
    func startShooting(){
        isShooting = true
    }
    
    
    func endShooting(){
        isShooting = false
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        coordinateColumn = map.tileColumnIndex(fromPosition: player.position)
        coordinateRow = map.tileRowIndex(fromPosition: position)
        
        
        currentSystemTime = currentTime
        
        let touchDirection = getDirection(coordinate: directionNodeCoord)
        let playerDirection = getDirection(zRotation: player.zRotation)
        if directionNodeCoord.x == 0 && directionNodeCoord.y == 0 {
            angleDifference = 0
        } else {
            angleDifference = playerDirection - touchDirection
        }
        
        applyAngularForceTo(node: player, angle: angleDifference)
        
        if isAccelerated {
            let maxSpeed : CGVector = CGVector(dx: 250, dy: 250)
            let accelerateForce : Double = 200000
            accelerate(anglePosition: getDirection(zRotation: player.zRotation), maxSpeed: maxSpeed, accelerateForce: accelerateForce)
        }
        if isShooting {
            if ((currentTime - player.laserSpawnTime) > 0.3){
                player.laserSpawnTime = currentTime
                self.addPlayerLaser()
            }
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
            self.physicsWorld.enumerateBodies(at: touchLocation, using: {body,stop in
                if let node : SKNode = body.node {
                    if node.name == "directionNode" {
                        print("directionNode touch began")
                        self.activeTouches[touch] = "direction"
                        self.directionNodeCoord = touch.location(in: self) - node.position
                    }
                    
                    if node.name == "accelerateNode" {
                        
                        self.isAccelerated = true
                        print("accelerateNode touch began")
                        self.activeTouches[touch] = "accelerate"
                    }
                    if node.name == "shootNode" {
                        self.startShooting()
                        self.activeTouches[touch] = "shoot"
                    }
                }
                
            })
            
            
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        for touch in touches {
            let touchLocation = touch.location(in: self)
            self.physicsWorld.enumerateBodies(at: touchLocation, using: {body,stop in
                if let node : SKNode = body.node {
                    if node.name == "directionNode" {
                        print("directionNode touch began")
                        self.directionNodeCoord = touch.location(in: self) - node.position
                        
                        print("player direction: ", self.getDirection(zRotation: self.player.zRotation))
                        
                    }
                }
            })
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
            } else if button == "shoot" {
                if (touch.tapCount == 2){
                    print("Double tapped")
                    startShooting()
                } else {
                    endShooting()
                }
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
    
    
    func addProjectile(direction: Float, position: CGPoint, imageName: String, speed: Double) -> SKSpriteNode{
        let projectile = SKSpriteNode(imageNamed: imageName)
        
        projectile.zRotation = reversezRotation(zRotation: player.zRotation)
        projectile.position = position
        projectile.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: projectile.size.width,
                                                                   height: projectile.size.height))
        self.world?.addChild(projectile)
        
        let anglePosition = getDirection(zRotation: player.zRotation)
        let x = sin(-anglePosition * Float.pi / 180)
        let y = cos(-anglePosition * Float.pi / 180)
        projectile.physicsBody?.applyImpulse(CGVector(dx: speed * Double(x), dy: speed * Double(y)))
        return projectile
    }
    
    
    func addPlayerLaser(){
        let laser = addProjectile(direction: getDirection(zRotation: player.zRotation), position: player.position, imageName: "laserRed05", speed: 20)
        
        laser.physicsBody?.categoryBitMask = playerLaserCategory
        laser.physicsBody?.contactTestBitMask = enemyShipCategory
        laser.physicsBody?.collisionBitMask = 0
        laser.physicsBody?.linearDamping = 0
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
    
    
    func addAsteroid(position: CGPoint){
        let asteroidName = "asteroid"
        let asteroid = SKSpriteNode(imageNamed: asteroidName)
        asteroid.position = position
        asteroid.size = CGSize(width: 90, height: 90)
        asteroid.zPosition = -1
        asteroid.physicsBody = SKPhysicsBody(circleOfRadius: asteroid.size.width/2)
        asteroid.physicsBody?.angularDamping = 0
        asteroid.physicsBody?.angularVelocity = 0.2
        asteroid.physicsBody?.collisionBitMask = 0x1
        asteroid.physicsBody?.categoryBitMask = 0x1
        asteroid.physicsBody?.mass = 10000
        
        world?.addChild(asteroid)
    }
    
    func createWorld(){
        let starGroups = SKTileSet(named: "Background")!.tileGroups[0]
        map = SKTileMapNode(tileSet: SKTileSet(named: "Background")!, columns: 200, rows: 200, tileSize: CGSize(width: 150, height: 150), fillWith: starGroups)
        
        self.world?.addChild(map)
        
        map.position = CGPoint(x: 0, y: 0)
        map.physicsBody?.collisionBitMask = 0
        map.zPosition = -1
        map.setScale(2)
        
        let newPlanet = Planet(planetName.Buenov)
        map.setTileGroup(newPlanet.planetTileGroup, forColumn: 100, row: 100)
        
        
        
        
        // Add players
        player.position = CGPoint(x: 0, y: 0)
        player.setScale(0.5)
        player.name = "player"
        
        self.world?.addChild(player)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: CGSize(width: player.size.width, height: player.size.height))
        player.physicsBody?.linearDamping = 0.2
        player.physicsBody?.angularDamping = 0
        player.physicsBody?.collisionBitMask = 0x1
        player.physicsBody?.categoryBitMask = 0x1
        player.physicsBody?.mass = 1000
        
        addAsteroid(position: CGPoint(x: -100, y: 100))
        addAsteroid(position: CGPoint(x: -500, y: -200))
        addAsteroid(position: CGPoint(x: -800, y: -20))
        
    }
    
    
    override func didMove(to view: SKView) {
        print("Move to game scene, begin making scene")
        self.backgroundColor = UIColor.black
        
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
