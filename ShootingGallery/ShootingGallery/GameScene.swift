//
//  GameScene.swift
//  ShootingGallery
//
//  Created by Cory Steers on 12/19/22.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var scoreLabel: SKLabelNode!
    var roundsLabel: SKLabelNode!
    var roundsIcon: SKSpriteNode!
    
    var possibleTargets = [ "target0", "target1", "target2", "target3", "Denied" ]
    var possibleHeights = [ 1, 2, 3 ]
    var targetTimer: Timer?
    var gameTimer: Timer?
    var finishTimer: Timer?
    var numRounds = 6 {
        didSet {
            roundsLabel.text = "Rounds: \(numRounds)"
        }
    }

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "wood-background")
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.size = CGSize(width: self.size.width, height: self.size.height)
        background.blendMode = .replace
        background.zPosition = -2
        background.name = "background"
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: 130, y: 50)
        scoreLabel.fontSize = 48
        scoreLabel.zPosition = -1
        addChild(scoreLabel)
        
        roundsLabel = SKLabelNode(fontNamed: "Chalkduster")
        roundsLabel.text = "Rounds: 6"
        roundsLabel.position = CGPoint(x: 830, y: 60)
        roundsLabel.fontSize = 32
        roundsLabel.zPosition = -1
        addChild(roundsLabel)
        
        roundsIcon = SKSpriteNode(imageNamed: "shots3")
        roundsIcon.position = CGPoint(x: 480, y: 80)
        roundsIcon.name = "rounds"
        addChild(roundsIcon)

        score = 0
        numRounds = 6
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(finishTargets), userInfo: nil, repeats: false)
        targetTimer = Timer.scheduledTimer(timeInterval: Double.random(in: 0.5...2), target: self, selector: #selector(createTarget), userInfo: nil, repeats: true)
    }
         
    @objc func finishTargets() {
        targetTimer?.invalidate()
        finishTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(gameOver), userInfo: nil, repeats: true)
    }
    
    @objc func gameOver()  {
        let count =  (children.filter { $0.name == "target" || $0.name == "decoy" }).count
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
            yStart = 210
        case 2:
            yStart = 420
        default:
            yStart = 630
        }
        
        let sprite = SKSpriteNode(imageNamed: target)
        sprite.position = CGPoint(x: xStart, y: yStart)
        addChild(sprite)
        
        sprite.name = (target == "Denied") ? "decoy" : "target"
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        guard tappedNodes.count > 0 else { return }
        let node = tappedNodes[0]
        
        if node.name == "target" {
            if numRounds > 0 {
                score += 1
                numRounds -= 1
                run(SKAction.playSoundFileNamed("gunFire.wav", waitForCompletion: false))
                if let smoke = SKEmitterNode(fileNamed: "SmokeParticles") {
                    smoke.position = node.position
                    addChild(smoke)
                    let removeSmoke = SKAction.removeFromParent()
                    let smokeDuration = SKAction.wait(forDuration: 1)
                    smoke.run(SKAction.sequence([ smokeDuration, removeSmoke ]))
                    node.removeFromParent()
                }
            } else {
                run(SKAction.playSoundFileNamed("emptyFire.wav", waitForCompletion: false))
            }
        } else if node.name == "decoy" {
            if numRounds > 0 {
                score -= 2
                numRounds -= 1
                run(SKAction.playSoundFileNamed("gunFire.wav", waitForCompletion: false))
                node.removeFromParent()
            } else {
                run(SKAction.playSoundFileNamed("emptyFire.wav", waitForCompletion: false))
            }
        } else if node.name == "rounds" {
            run(SKAction.playSoundFileNamed("reload.wav", waitForCompletion: false))
            numRounds = 6
        } else {
            if numRounds > 0 {
                numRounds -= 1
                run(SKAction.playSoundFileNamed("gunFire.wav", waitForCompletion: false))
            } else {
                run(SKAction.playSoundFileNamed("emptyFire.wav", waitForCompletion: false))
            }
        }
    }
}
