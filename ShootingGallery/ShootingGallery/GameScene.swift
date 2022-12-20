//
//  GameScene.swift
//  ShootingGallery
//
//  Created by Cory Steers on 12/19/22.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var scoreLabel: SKLabelNode!
    
    var possibleTargets = [ "target0", "target1", "target2", "target3" ]
    var possibleHeights = [ 1, 2, 3 ]
    var targetTimer: Timer?
    var gameTimer: Timer?
    var finishTimer: Timer?

    var score = 0 {
        didSet {
            scoreLabel.text = "Score \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "wood-background")
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.size = CGSize(width: self.size.width, height: self.size.height)
        background.blendMode = .replace
        background.zPosition = -2
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: 130, y: 50)
        scoreLabel.fontSize = 48
        scoreLabel.zPosition = -1
        addChild(scoreLabel)
        
        score = 0
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(finishTargets), userInfo: nil, repeats: false)
        targetTimer = Timer.scheduledTimer(timeInterval: Double.random(in: 1...3), target: self, selector: #selector(createTarget), userInfo: nil, repeats: true)
    }
         
    @objc func finishTargets() {
        targetTimer?.invalidate()
        finishTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(gameOver), userInfo: nil, repeats: true)
    }
    
    @objc func gameOver()  {
        let count =  (children.filter { $0.name == "target" }).count
        if count == 0 {
            finishTimer?.invalidate()
            
            let sprite = SKSpriteNode(imageNamed: "game-over")
            sprite.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
            sprite.size = CGSize(width: self.size.width / 3, height: self.size.height / 3)
            addChild(sprite)
        }
    }
    
    @objc func createTarget() {
        guard let target = possibleTargets.randomElement() else { return }
        guard let height = possibleHeights.randomElement() else { return }
        let xStart = (height == 2) ? 1200 : -200
        let xVector = (height == 2) ? -500 : 500
        
        let yStart: Int
        switch height {
        case 1:
            yStart = 200
        case 2:
            yStart = 400
        default:
            yStart = 600
        }
        
        let sprite = SKSpriteNode(imageNamed: target)
        sprite.position = CGPoint(x: xStart, y: yStart)
        addChild(sprite)
        
        sprite.name = "target"
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: xVector, dy: 0)
        sprite.physicsBody?.linearDamping = 0 // don't slow down
        sprite.physicsBody?.angularDamping = 0 // don't stop spinning
        
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 || node.position.x > 1300 {
                node.removeFromParent()
            }
        }
    }
}
