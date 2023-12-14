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
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let levels = ["level1", "level2"]
    let playerStarts = [CGPoint(x: 96, y: 672), CGPoint(x: 928, y: 672)]

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

    func buildAWallSection(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "block")
        node.position = position

        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        node.physicsBody?.isDynamic = false

        addChild(node)
    }

    func buildAVortex(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "vortex")
        node.name = "vortex"
        node.position = position
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))

        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0

        addChild(node)
    }

    func buildAStar(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "star")
        node.name = "star"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false

        node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position

        addChild(node)
    }

    func buildAFinish(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "finish")
        node.name = "finish"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false

        node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position

        addChild(node)
    }

    func loadLevel() {
        guard let levelURL = Bundle.main.url(forResource: levels[currentLevel], withExtension: "txt") else {
            fatalError("Could not find level1.txt in app bundle.")
        }
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not load level1.txt from the app bundle.")
        }

        let lines = levelString.components(separatedBy: "\n")

        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)

                switch letter {
                case " ":
                    break
                case "x":
                    buildAWallSection(at: position)
                case "v":
                    buildAVortex(at: position)
                case "s":
                    buildAStar(at: position)
                case "f":
                    buildAFinish(at: position)
                default:
                    fatalError("Unknown level letter: '\(letter)'")
                }
            }
        }
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
            return
        }
        guard let nodeB = contact.bodyB.node else {
            return
        }

        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }

    func playerCollided(with node: SKNode) {
        if node.name == "vortex" {
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1

            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])

            player.run(sequence) { [weak self] in
                self?.createPlayer()
                self?.isGameOver = false
            }
        } else if node.name == "star" {
            node.removeFromParent()
            score += 1
        } else if node.name == "finish" {
            player.physicsBody?.isDynamic = false
            isGameOver = true
            currentLevel += 1
            lastTouchPosition = nil

            if currentLevel < levels.count {
//                player.run(SKAction.removeFromParent())
                removeAllChildren()

                scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
                scoreLabel.text = "Score: \(score)"
                scoreLabel.horizontalAlignmentMode = .left
                scoreLabel.position = CGPoint(x: 12, y: 32)
                scoreLabel.zPosition = 2
                addChild(scoreLabel)

                drawBackground()
                loadLevel()
                createPlayer()
                isGameOver.toggle()
            } else {
                let gameOver = SKLabelNode(fontNamed: "Chalkduster")
                gameOver.horizontalAlignmentMode = .left
                gameOver.fontSize = 80
                gameOver.fontColor = .red
                gameOver.text = "Game Over!\nCongratulations!"
                gameOver.position = CGPoint(x: 200, y: 544)
                gameOver.zPosition = 2
                addChild(gameOver)
            }
        }
    }
}
