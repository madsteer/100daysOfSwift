//
//  GameScene+loadLevel.swift
//  Project26
//
//  Created by Cory Steers on 12/13/23.
//

import CoreMotion
import SpriteKit

extension GameScene {
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

    func buildATeleport(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "vortex")
        node.color = .blue
        node.colorBlendFactor = 0.9
        node.name = "teleport"
        node.position = position
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: -(.pi), duration: 1)))

        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionTypes.teleport.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0

        addChild(node)
        teleportPositions.append(position)
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

    // swiftlint:disable cyclomatic_complexity
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
                case "t":
                    buildATeleport(at: position)
                case "f":
                    buildAFinish(at: position)
                default:
                    fatalError("Unknown level letter: '\(letter)'")
                }
            }
        }
    }
    // swiftlint:enable cyclomatic_complexity
}
