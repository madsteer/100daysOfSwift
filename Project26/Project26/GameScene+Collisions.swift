//
//  GameScene+Collisions.swift
//  Project26
//
//  Created by Cory Steers on 12/13/23.
//

import CoreMotion
import SpriteKit

extension GameScene {
    func doATeleportCollision(with node: SKNode) {
        if justTeleported == false {
            justTeleported = true
            player.physicsBody?.isDynamic = false
            isGameOver = true
            lastTouchPosition = nil

            let move1 = SKAction.move(to: node.position, duration: 0.25)
            let scale1 = SKAction.scale(to: 0.0001, duration: 0.25)
            let move2 = SKAction.move(to: (player.position == teleportPositions[0])
                                      ? teleportPositions[1] : teleportPositions[0],
                        duration: 0.25)
            let scale2 = SKAction.scale(to: 1.0, duration: 0.25)
            let sequence = SKAction.sequence([move1, scale1, move2, scale2])
            player.run(sequence) { [weak self] in
                self?.player.physicsBody?.isDynamic = true
                self?.isGameOver = false
            }
        }
    }

    func doAFinishCollision(with node: SKNode) {
        justTeleported = false
        player.physicsBody?.isDynamic = false
        isGameOver = true
        currentLevel += 1
        lastTouchPosition = nil

        if currentLevel < levels.count {
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

    func playerCollided(with node: SKNode) {
        if node.name == "vortex" {
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1
            justTeleported = false

            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])

            player.run(sequence) { [weak self] in
                self?.createPlayer()
                self?.isGameOver = false
            }
        } else if node.name == "star" {
            justTeleported = false
            node.removeFromParent()
            score += 1
        } else if node.name == "teleport" {
            doATeleportCollision(with: node)
        } else if node.name == "finish" {
            doAFinishCollision(with: node)
        }
    }
}
