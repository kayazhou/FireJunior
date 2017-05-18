//
//  LaunchScreen.swift
//  FireJunior
//
//  Created by He Zhou on 17/05/2017.
//  Copyright © 2017 HMK. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class LaunchScreen: SKScene {

    override func didMove(to view: SKView) {

        physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        physicsBody?.restitution = 0.5
        var letter1 = SKLabelNode()
        var letter2 = SKLabelNode()
        var letter3 = SKLabelNode()
        
        letter1.text = "H."
        letter1.fontSize = 24
        letter1.fontName = "System"
        letter1.fontColor = UIColor.white
        letter1.physicsBody?.restitution = 0.3
        
        
        letter2.text = "M."
        letter2.fontSize = 24
        letter2.fontName = "System"
        letter2.fontColor = UIColor.white
        letter2.physicsBody?.restitution = 0.3

        letter3.text = "K"
        letter3.fontSize = 24
        letter3.fontName = "System"
        letter3.fontColor = UIColor.white
        letter3.physicsBody?.restitution = 0.3
        
        letter1.position = CGPoint(x: 184, y: self.frame.size.height-100)
        letter2.position = CGPoint(x: letter1.position.x+letter1.frame.size.width, y: self.frame.size.height-100)
        letter3.position = CGPoint(x: letter2.position.x+letter2.frame.size.width, y: self.frame.size.height-100)
        
        letter1.physicsBody = SKPhysicsBody(rectangleOf: letter1.frame.size)
        letter2.physicsBody = SKPhysicsBody(rectangleOf: letter2.frame.size)
        letter3.physicsBody = SKPhysicsBody(rectangleOf: letter3.frame.size)
        
        self.addChild(letter1)
        self.run(SKAction.wait(forDuration: 0.1)){
            self.addChild(letter2)
            self.run(SKAction.wait(forDuration: 0.1)){
                self.addChild(letter3)
                self.run(SKAction.wait(forDuration: 3)){
                    if let scene = SKScene(fileNamed: "GameScene") {
                        // Set the scale mode to scale to fit the window
                        scene.scaleMode = .aspectFill
                        
                        // Present the scene
                        view.presentScene(scene)
                    }
                }
            }
        }
        
    }
}
