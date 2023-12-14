//
//  GameScene.swift
//  Project26
//
//  Created by Cory Steers on 12/12/23.
//

import CoreMotion
import SpriteKit

enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
    case teleport = 32
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let levels = ["level1", "level2"]
    let playerStarts = [CGPoint(x: 96, y: 672), CGPoint(x: 928, y: 672)]
    var teleportPositions = [CGPoint]()
    var justTeleported = false

    var currentLevel = 0

    var player: SKSpriteNode!
    var lastTouchPosition: CGPoint?

    var motionManager: CMMotionManager?
    var isGameOver = false

    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    override func didMove(to view: SKView) {
        drawBackground()

        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 12, y: 32)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)

        loadLevel()
        createPlayer()

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
    }

    func drawBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
    }

    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = playerStarts[currentLevel]
        player.zPosition = 1

        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5

        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask =
        CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue

        addChild(player)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { fatalError("I don't know, some touches.first error in touchesBegan") }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { fatalError("I don't know, some touches.first error in touchesMoved") }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }

    override func update(_ currentTime: TimeInterval) {
        guard isGameOver == false else { return }

        #if targetEnvironment(simulator)
        if let lastTouchPosition = lastTouchPosition {
            let diff = CGPoint(x: lastTouchPosition.x - player.position.x, y: lastTouchPosition.y - player.position.y)
            physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
        }
        #else
        if let accelerometerData = motionManager?.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y
                                    * -50, dy: accelerometerData.acceleration.x * 50)
        }
        #endif
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else {
            justTeleported = false
            return
        }
        guard let nodeB = contact.bodyB.node else {
            justTeleported = false
            return
        }

        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }

}
