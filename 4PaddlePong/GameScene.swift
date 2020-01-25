//
//  GameScene.swift
//  4PaddlePong
//
//  Created by Christopher Walter on 1/25/20.
//  Copyright © 2020 AssistStat. All rights reserved.
//

import SpriteKit
import GameplayKit

let BallCategory: UInt32 = 0x1 << 0
let TopCategory: UInt32 = 0x1 << 2
let PaddleCategory: UInt32 = 0x1 << 5


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ball = SKSpriteNode()
    var topPaddle = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        ball = childNode(withName: "ball") as! SKSpriteNode
        topPaddle = childNode(withName: "topPaddle") as! SKSpriteNode
        
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = border
        
        let topRight = CGPoint(x: -frame.origin.x, y: -frame.origin.y)
        let topLeft = CGPoint(x: frame.origin.x, y: -frame.origin.y)
        
        let top = SKNode()
        top.name = "top"
        top.physicsBody = SKPhysicsBody(edgeFrom: topRight, to: topLeft)
        
        addChild(top)
        
        topPaddle.physicsBody?.categoryBitMask = PaddleCategory
        top.physicsBody?.categoryBitMask = TopCategory
        ball.physicsBody?.categoryBitMask = BallCategory
       
        ball.physicsBody?.contactTestBitMask = TopCategory | PaddleCategory
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        print(contact.bodyA)
        print(contact.bodyB)
        
        if contact.bodyA.categoryBitMask == TopCategory {
            ball.removeAllActions()
            ball.removeFromParent()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        topPaddle.run(SKAction.moveTo(x: location.x, duration: 0.2))
        
        ball.physicsBody?.applyImpulse(CGVector(dx: 20, dy: 20))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        topPaddle.run(SKAction.moveTo(x: location.x, duration: 0.2))
    }
    
    
   
}
