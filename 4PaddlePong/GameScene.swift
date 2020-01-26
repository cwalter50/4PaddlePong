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
let BottomCategory: UInt32 = 0x1 << 3
let LeftCategory: UInt32 = 0x1 << 4
let RightCategory: UInt32 = 0x1 << 5
let PaddleCategory: UInt32 = 0x1 << 6


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ball = SKSpriteNode()
    
    var topPaddle = SKSpriteNode()
    var bottomPaddle = SKSpriteNode()
    var leftPaddle = SKSpriteNode()
    var rightPaddle = SKSpriteNode()
    
    var scoreLabel = SKLabelNode()
    
    var score = 0 // used as a counter to keep track of # of paddle hits
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        ball = childNode(withName: "ball") as! SKSpriteNode
        topPaddle = childNode(withName: "topPaddle") as! SKSpriteNode
        bottomPaddle = childNode(withName: "bottomPaddle") as! SKSpriteNode
        leftPaddle = childNode(withName: "leftPaddle") as! SKSpriteNode
        rightPaddle = childNode(withName: "rightPaddle") as! SKSpriteNode
    
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
        
        scoreLabel.text = "\(score)"
       
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = border
        
        addBordersAndPhysics()
    }
    
    func addBordersAndPhysics()
    {
        // create individual borders around world to figure out which wall was hit.
        let topRight = CGPoint(x: -frame.origin.x, y: -frame.origin.y)
        let topLeft = CGPoint(x: frame.origin.x, y: -frame.origin.y)
        let bottomLeft = CGPoint(x: frame.origin.x, y: frame.origin.y)
        let bottomRight = CGPoint(x: -frame.origin.x, y: frame.origin.y)
        
        let top = SKNode()
        top.name = "top"
        top.physicsBody = SKPhysicsBody(edgeFrom: topRight, to: topLeft)
         
        addChild(top)
         
        let bottom = SKNode()
        bottom.name = "bottom"
        bottom.physicsBody = SKPhysicsBody(edgeFrom: bottomRight, to: bottomLeft)
         
        addChild(bottom)
        
        let left = SKNode()
        left.name = "left"
        left.physicsBody = SKPhysicsBody(edgeFrom: topLeft, to: bottomLeft)
         
        addChild(left)
        
        let right = SKNode()
        right.name = "right"
        right.physicsBody = SKPhysicsBody(edgeFrom: topRight, to: bottomRight)
         
        addChild(right)
        
        topPaddle.physicsBody?.categoryBitMask = PaddleCategory
        bottomPaddle.physicsBody?.categoryBitMask = PaddleCategory
        leftPaddle.physicsBody?.categoryBitMask = PaddleCategory
        rightPaddle.physicsBody?.categoryBitMask = PaddleCategory
         
        top.physicsBody?.categoryBitMask = TopCategory
        bottom.physicsBody?.categoryBitMask = BottomCategory
        left.physicsBody?.categoryBitMask = LeftCategory
        right.physicsBody?.categoryBitMask = RightCategory
        ball.physicsBody?.categoryBitMask = BallCategory
        
        ball.physicsBody?.contactTestBitMask = TopCategory | LeftCategory | RightCategory | BottomCategory | PaddleCategory
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
//        print(contact.bodyA)
//        print(contact.bodyB)
        
        if contact.bodyA.categoryBitMask == TopCategory && topPaddle.physicsBody != nil {
            updatePaddleColor(paddle: topPaddle)
            resetBall()
        }
        
        if contact.bodyA.categoryBitMask == BottomCategory && bottomPaddle.physicsBody != nil {
            updatePaddleColor(paddle: bottomPaddle)
            resetBall()
        }
        
        if contact.bodyA.categoryBitMask == LeftCategory && leftPaddle.physicsBody != nil {
            updatePaddleColor(paddle: leftPaddle)
            resetBall()
        }
        
        if contact.bodyA.categoryBitMask == RightCategory && rightPaddle.physicsBody != nil {
            updatePaddleColor(paddle: rightPaddle)
            resetBall()
        }
        
        if contact.bodyA.categoryBitMask == PaddleCategory
        {
            score += 1
            scoreLabel.text = "\(score)"
        }
    }
    
    func resetBall()
    {
        // wait for 1 second, move to center, wait 1 second, push again
        ball.physicsBody?.velocity = CGVector.zero
        let wait = SKAction.wait(forDuration: 1.0)
        let repositionBall = SKAction.run {
            self.ball.run(SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0.25))
        }
//        let pushBall = SKAction.run(applyImpulseToBall)
        let sequence = SKAction.sequence([wait, repositionBall, wait])
        run(sequence)

    }
    

    func applyImpulseToBall() {
        let impulseArray = [20, -20]
        let randx = Int.random(in: 0...1)
        let randy = Int.random(in: 0...1)
        ball.physicsBody?.applyImpulse(CGVector(dx: impulseArray[randx], dy: impulseArray[randy]))
    }
    
    func updatePaddleColor(paddle: SKSpriteNode)
    {
        // colors should change from red to yellow to white to disappear.
        
        if paddle.color == UIColor.red
        {
            paddle.color = UIColor.yellow
        }
        else if paddle.color == UIColor.yellow
        {
            paddle.color = UIColor.green
        }
        else if paddle.color == UIColor.green
        {
            print("should remove paddle")
            // remove paddle
//            paddle.physicsBody = nil
            paddle.physicsBody = nil
            paddle.removeFromParent()
            
        }
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // wait to push the ball until we touch the remote. Push ball by 20, 20, but use randomness to decide if it is -20 or +20
        applyImpulseToBall()
        
        let location = touches.first!.location(in: self)
        movePaddles(location: location)
        
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        movePaddles(location: location)
        
    }
    
    func movePaddles(location: CGPoint)
    {
        topPaddle.run(SKAction.moveTo(x: location.x, duration: 0.2))
        bottomPaddle.run(SKAction.moveTo(x: -location.x, duration: 0.2))
        rightPaddle.run(SKAction.moveTo(y: -location.x, duration: 0.2))
        leftPaddle.run(SKAction.moveTo(y: location.x, duration: 0.2))
    }
    
   
}
