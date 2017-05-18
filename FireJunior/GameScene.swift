//
//  GameScene.swift
//  FireJunior
//
//  Created by He Zhou on 17/05/2017.
//  Copyright © 2017 HMK. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    let photonTorpedoCategory:UInt32 = 0x1 << 0
    let alienCategory:UInt32 = 0x1 << 1
    let disableAlienCategory:UInt32 = 0x1 << 2
    let playerCategory:UInt32 = 0x1 << 3
    let rainCategory:UInt32 = 0x1 << 4

    var starfield:SKEmitterNode!
    var player:SKSpriteNode!
    
    var scoreLabel:SKLabelNode!

    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var isPlayerExsit = true
    
    var gameTimer:Timer!
    var possibleAliens = ["alien","alien2","alien3"]
    
    let motionManager = CMMotionManager()
    var xAcceleration:CGFloat = 0
    
    var disabledAliens = [SKSpriteNode]()
    
    override func didMove(to view: SKView) {
        
        starfield = SKEmitterNode(fileNamed:"SnowBackground")
        starfield.position = CGPoint(x:0,y:1472)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
        starfield.zPosition = -1
        
        addPlayer()
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 50, y: self.frame.size.height - 40)
        scoreLabel.fontName = "AmericanTypewriter"
        scoreLabel.fontSize = 20
        self.addChild(scoreLabel)
        score = 0
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.50, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) {(data:CMAccelerometerData?, error:Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
            }
        }
    }
    
    func addPlayer() {
        player = SKSpriteNode(imageNamed: "shuttle")
        player.position = CGPoint(x: self.frame.size.width/2, y: position.y+40)

        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = false
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = alienCategory
        
        self.addChild(player)
        isPlayerExsit = true
    }
    
    func addAlien() {
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as![String]
        let alien = SKSpriteNode(imageNamed: possibleAliens[0])
        
        let randomAlienPosition = GKRandomDistribution(lowestValue: 0, highestValue: 414)
        let position = CGFloat(randomAlienPosition.nextInt())
        
        alien.position = CGPoint(x: position, y: self.frame.size.height + alien.size.height)
        
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = photonTorpedoCategory | playerCategory | rainCategory
        alien.physicsBody?.collisionBitMask = 0
        
        self.addChild(alien)
        
        let animationDuration:TimeInterval = 5
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x:position,y:-alien.size.height), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actionArray))
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch touches.count {
        case 1:
            fireTorpedo()
        case 2:
            fireRain()
        default:
            fireTorpedo()
        }
    }
    
    func fireTorpedo(){
        if isPlayerExsit{
            self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
            
            let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
            torpedoNode.position = player.position
            torpedoNode.position.y+=5
            
            torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
            torpedoNode.physicsBody?.isDynamic = true
            torpedoNode.physicsBody?.categoryBitMask = photonTorpedoCategory
            torpedoNode.physicsBody?.contactTestBitMask = alienCategory
            torpedoNode.physicsBody?.collisionBitMask = 0
            torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
            
            self.addChild(torpedoNode)
            
            let animationDuration:TimeInterval = 1.3
            
            var actionArray = [SKAction]()
            
            actionArray.append(SKAction.move(to: CGPoint(x:player.position.x ,y:self.frame.size.height + 10), duration: animationDuration))
            actionArray.append(SKAction.removeFromParent())
            
            torpedoNode.run(SKAction.sequence(actionArray))
        }

    }
    
    func fireRain(){
        let rainNode = SKEmitterNode(fileNamed: "Spark")!
        rainNode.position = player.position
        rainNode.position.y+=5
        
        rainNode.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width * 2)
        rainNode.physicsBody?.isDynamic = true
        rainNode.physicsBody?.categoryBitMask = rainCategory
        rainNode.physicsBody?.contactTestBitMask = alienCategory
        rainNode.physicsBody?.collisionBitMask = 0
        rainNode.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(rainNode)
        
        let animationDuration:TimeInterval = 1.3
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x:player.position.x ,y:self.frame.size.height + 10), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        rainNode.run(SKAction.sequence(actionArray))
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            secondBody = contact.bodyA
            firstBody = contact.bodyB
        }
        print(firstBody)
//        print(secondBody)
        
        if ((firstBody.categoryBitMask & photonTorpedoCategory) != 0) && ((secondBody.categoryBitMask & alienCategory) != 0) {
            torpedoDidCollideWithAlien(torpedoNode: firstBody.node as! SKSpriteNode, alienNode: secondBody.node as! SKSpriteNode)
        }
        
        if ((firstBody.categoryBitMask & alienCategory) != 0) && ((secondBody.categoryBitMask & playerCategory) != 0) {
            playerDistoryWithAlien(playerNode: firstBody.node as! SKSpriteNode, alienNode: secondBody.node as! SKSpriteNode)
        }
        
        if ((firstBody.categoryBitMask & alienCategory) != 0) && ((secondBody.categoryBitMask & rainCategory) != 0) {
            rainDidCollideWithAlien(rainNode:secondBody.node as! SKEmitterNode, alienNode: firstBody.node as! SKSpriteNode)
        }
    }
    
    func rainDidCollideWithAlien(rainNode:SKEmitterNode, alienNode:SKSpriteNode)  {
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = alienNode.position
        self.addChild(explosion)
        self.run((SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false)))
        
        
        alienNode.physicsBody?.categoryBitMask = disableAlienCategory
        disabledAliens.append(alienNode)
        alienNode.isHidden = true
        
        self.run(SKAction.wait(forDuration: 2)){
            explosion.removeFromParent()
        }
        
        score += 5
    }
    
    func playerDistoryWithAlien(playerNode:SKSpriteNode,alienNode:SKSpriteNode){
        isPlayerExsit = false
        self.run((SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false)))
        let explosion = SKEmitterNode(fileNamed: "BlueFire")!
        explosion.position = alienNode.position
        self.addChild(explosion)
        player.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 3)){
            explosion.removeFromParent()
            self.addPlayer()
        }
    }
    
    func torpedoDidCollideWithAlien(torpedoNode:SKSpriteNode, alienNode:SKSpriteNode)  {
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = alienNode.position
        self.addChild(explosion)
        self.run((SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false)))
        
        
        torpedoNode.removeFromParent()
        alienNode.physicsBody?.categoryBitMask = disableAlienCategory
        disabledAliens.append(alienNode)
        alienNode.isHidden = true
        
        self.run(SKAction.wait(forDuration: 2)){
            explosion.removeFromParent()
        }
        
        score += 5
    }
    
    override func didSimulatePhysics() {
        if (player.position.x > 20) && (player.position.x < (self.size.width-20)) {
            player.position.x += xAcceleration * 50
        }
        if (player.position.x < 20) && xAcceleration > 0{
            player.position.x += xAcceleration * 50
        }
        if (player.position.x > (self.size.width-20)) && xAcceleration < 0 {
            player.position.x += xAcceleration * 50
        }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        for var disAlien in disabledAliens{
            disAlien.removeFromParent()
        }
    }
    
    
}
