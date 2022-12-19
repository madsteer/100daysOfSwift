//
//  GameScene.swift
//  ShootingGallery
//
//  Created by Cory Steers on 12/19/22.
//

import SpriteKit

class GameScene: SKScene {
    var scoreLabel: SKLabelNode!
    
    var possibleTargets = [ "target0", "target1", "target2", "target3" ]
    var gameTimer: Timer?
    
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
    }
    

}
