//
//  GameScene.swift
//  Avoid Spikes
//
//  Created by Andy Wu on 2/6/17.
//  Copyright © 2017 Andy Wu. All rights reserved.
//

import SpriteKit
import GameplayKit

var player = SKSpriteNode()
var spike = SKSpriteNode()
var ground = SKSpriteNode()

var lblMain = SKLabelNode()
var lblScore = SKLabelNode()

var spikeSpeed = 2.0

var isAlive = true

var score = 0

var spikeTimeSpawnNumber = 0.4

var offWhiteColor = UIColor(colorLiteralRed: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)

var offBlackColor = UIColor(colorLiteralRed: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)

var touchLocation = CGPoint()


struct physicsCategory {
    static let player:UInt32 = 1
    static let spike:UInt32 = 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        self.backgroundColor = .orange
        
        spawnPlayer()
        spawnGround()
        spawnLblMain()
        spawnLblScore()
        spikeSpawnTimer()
        hideLable()
        resetVarsOnStart()
        addToScore()
    }
    
    func resetVarsOnStart() {
        score = 0
        spikeSpeed = 2.0
        isAlive = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchLocation = touch.location(in: self)
            
            if isAlive == true {
                player.position.x = touchLocation.x
            }
            else if isAlive == false {
                player.position.x = -500
            }
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if isAlive == false {
            player.position.x = -500
        }
    }
    
    func spawnPlayer() {
        player = SKSpriteNode(imageNamed: "Player")
        //player = SKSpriteNode(color: offWhiteColor, size: CGSize(width: 50, height: 50))
        player.position = CGPoint(x: self.frame.midX, y: (self.frame.size.height) * -0.5 + 130 )
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.isDynamic = false
        player.physicsBody?.categoryBitMask = physicsCategory.player
        player.physicsBody?.contactTestBitMask = physicsCategory.spike
        
        self.addChild(player)
    }
    
    func spawnSpike() {
        spike = SKSpriteNode(imageNamed: "Spike")
        //spike = SKSpriteNode(color: offBlackColor, size: CGSize(width: 10, height: 125))
        
        let ranNegXPos:Int = (Int(arc4random_uniform(UInt32(self.frame.width))) * -1 )
        let ranPositXPos:Int = Int(arc4random_uniform(UInt32(self.frame.width)))
        
        
        spike.position.x = CGFloat(ranNegXPos + ranPositXPos)
        spike.position.y = 900
        
        spike.physicsBody = SKPhysicsBody(rectangleOf: spike.size)
        spike.physicsBody?.affectedByGravity = false
        spike.physicsBody?.allowsRotation = false
        spike.physicsBody?.categoryBitMask = physicsCategory.spike
        spike.physicsBody?.contactTestBitMask = physicsCategory.player
        spike.physicsBody?.isDynamic = true
        
        var moveDown = SKAction.moveTo(y: -500, duration: spikeSpeed)
        
        if isAlive == true {
            moveDown = SKAction.moveTo(y: -500, duration: spikeSpeed)
        }
        else if isAlive == false {
            moveDown = SKAction.moveTo(y: 2000, duration: spikeSpeed)
        }
        
        
        spike.run(moveDown)
        
        self.addChild(spike)
        
    }
    
    func spawnGround() {
        ground = SKSpriteNode(color: offBlackColor, size: CGSize(width: self.frame.width, height: 200))
        ground.position = CGPoint(x: self.frame.midX, y: self.frame.minY)
        
        self.addChild(ground)
    }
    
    func spawnLblMain (){
        lblMain = SKLabelNode(fontNamed: "Futura")
        lblMain.fontSize = 100
        lblMain.fontColor = offWhiteColor
        lblMain.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 150)
        
        lblMain.text = "Start!"
        
        self.addChild(lblMain)
    }
    
    func spawnLblScore () {
        lblScore = SKLabelNode(fontNamed: "Futura")
        lblScore.fontSize = 40
        lblScore.fontColor = offWhiteColor
        lblScore.position = CGPoint(x: self.frame.midX, y: (self.frame.size.height) * -0.5 + 20 )
        
        lblScore.text = "Score: 0"
        
        self.addChild(lblScore)
        
    }
    
    func spikeSpawnTimer() {
        let spikeTimer = SKAction.wait(forDuration: spikeTimeSpawnNumber)
        
        let spawn = SKAction.run {
            self.spawnSpike()
        }
        
        let sequence = SKAction.sequence([spikeTimer, spawn])
        
        self.run(SKAction.repeatForever(sequence))
    }
    
    func hideLable() {
        let wait = SKAction.wait(forDuration: 3.0)
        let hideLabel = SKAction.run {
            lblMain.alpha = 0.0
        }
        
        let sequence = SKAction.sequence([wait, hideLabel])
        
        self.run(SKAction.repeat(sequence, count: 1))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody:SKPhysicsBody = contact.bodyA
        let secondBody:SKPhysicsBody = contact.bodyB
        
        if(((firstBody.categoryBitMask == physicsCategory.player) && (secondBody.categoryBitMask == physicsCategory.spike)) || ((firstBody.categoryBitMask == physicsCategory.spike) && (secondBody.categoryBitMask == physicsCategory.player))) {
            spikeCollision(playerTemp: firstBody.node as! SKSpriteNode, spikeTemp: secondBody.node as! SKSpriteNode)
            
        }
    }
    
    func spikeCollision(playerTemp:SKSpriteNode, spikeTemp: SKSpriteNode) {
        spikeTemp.removeFromParent()
        
        lblMain.alpha = 1.0
        lblMain.fontSize = 50
        lblMain.text = "GAME OVER"
        
        isAlive = false
        
        updateScore()
        waitThenMoveToTitleScene()
    }
    
    func updateScore() {
        lblScore.text = "Score: \(score)"
        
        if((score % 10 == 0) && (spikeSpeed > 0)) {
            spikeSpeed = spikeSpeed - 0.2
        }
        
        if(spikeSpeed <= 0) {
            spikeSpeed = 0.1
        }
        
    }
    
    func waitThenMoveToTitleScene() {
        let wait = SKAction.wait(forDuration: 1.0)
        
        let transition = SKAction.run {
            self.view?.presentScene(TitleScene(), transition: SKTransition.crossFade(withDuration: 1.0))
            
        }
        
        let sequence = SKAction.sequence([wait, transition])
        
        self.run(SKAction.repeat(sequence, count: 1))
    }
    
    func addToScore() {
        let timeInterval = SKAction.wait(forDuration: 1.0)
        let addAndUpdateScore = SKAction.run {
            score += 1
            self.updateScore()
        }
        
        let sequence = SKAction.sequence([timeInterval, addAndUpdateScore])
        
        self.run(SKAction.repeatForever(sequence))
    }
}
