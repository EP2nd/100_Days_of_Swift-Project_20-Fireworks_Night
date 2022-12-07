//
//  GameScene.swift
//  Project20
//
//  Created by Edwin Przeźwiecki Jr. on 11/10/2022.
//

import GameplayKit
import SpriteKit

var fireworks = [SKNode]()
/// Challenge 1:
var scoreLabel: SKLabelNode!
var explodeLabel: SKLabelNode!
var gameOverLabel: SKLabelNode!
var restartLabel: SKLabelNode!

var gameTimer: Timer?

let leftEdge = -22
let bottomEdge = -22
let rightEdge = 1024 + 22

var numberOfLaunches = 0
/// Challenge 1:
var score = 0 {
    didSet {
        scoreLabel.text = "Score: \(score)"
    }
}

var isGameOver = false

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        background.zPosition = -1
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        addChild(background)
        
        /// Challenge 1:
        scoreLabel = SKLabelNode(fontNamed: "Zapfino")
        scoreLabel.zPosition = 0
        scoreLabel.position = CGPoint(x: 1024, y: 718)
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
        
        explodeLabel = SKLabelNode(fontNamed: "PartyLetPlain")
        explodeLabel.zPosition = 0
        explodeLabel.position = CGPoint(x: 512, y: 18)
        explodeLabel.horizontalAlignmentMode = .center
        explodeLabel.text = "*kaboom*!"
        explodeLabel.fontSize = 56
        addChild(explodeLabel)
        
        startGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        checkTouches(touches)
    }
    
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                /// This uses a position high above so that rockets can explode off screen:
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    func createFirework(xMovement: CGFloat, x: Int, y: Int) {
        /// 1. Create an SKNode that will act as the firework container, and place it at the position that was specified:
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        /// 2. Create a rocket sprite node, give it the name "firework" so we know that it's the important thing, adjust its colorBlendFactor property so that we can color it, then add it to the container node:
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)
        
        /// 3. Give the firework sprite node one of three random colors: cyan, green or red. I've chosen cyan because pure blue isn't particularly visible on a starry sky background picture:
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .cyan
            
        case 1:
            firework.color = .green
            
        case 2:
            firework.color = .red
            
        default:
            break
        }
        
        /// 4. Create a UIBezierPath that will represent the movement of the firework:
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        /// 5. Tell the container node to follow that path, turning itself as needed:
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(move)
        
        /// 6. Create particles behind the rocket to make it look like the fireworks are lit:
        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: 0, y: -22)
            node.addChild(emitter)
        }
        
        /// 7. Add the firework to our fireworks array and also to the scene:
        fireworks.append(node)
        addChild(node)
    }
    
    @objc func launchFireworks() {
        
        let movementAmount: CGFloat = 1800
        /// Challenge 2:
        numberOfLaunches += 1
        if numberOfLaunches == 11 {
            gameOver()
            return
        }
        
        switch Int.random(in: 0...3) {
        case 0:
            /// Fire five, straight up:
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)
        case 1:
            /// Fire five, in a fan:
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)
        case 2:
            /// Fire five, from the left to the right:
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)
        case 3:
            /// Fire five, from the right to the left:
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)
        default:
            break
        }
    }
    
    func checkTouches(_ touches: Set<UITouch>) {
        
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint {
            
            guard node.name == "firework" else { continue }
            
            for parent in fireworks {
                
                guard let firework = parent.children.first as? SKSpriteNode else { continue }
                
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            node.name = "selected"
            node.colorBlendFactor = 0
        }
        
        if isGameOver {
            if nodesAtPoint.contains(restartLabel) {
                startGame()
            }
        }
        
        if nodesAtPoint.contains(explodeLabel) {
            explodeFireworks()
        }
    }
    
    func explode(firework: SKNode) {
        
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            emitter.position = firework.position
            addChild(emitter)
            /// Challenge 3:
            let delay = SKAction.wait(forDuration: 2)
            let remove = SKAction.removeFromParent()
            
            emitter.run(SKAction.sequence([delay, remove]))
        }
        firework.removeFromParent()
    }
    
    func explodeFireworks() {
        
        var numExploded = 0
        
        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }
            
            if firework.name == "selected" {
                /// Destroy this firework:
                explode(firework: fireworkContainer)
                fireworks.remove(at: index)
                
                numExploded += 1
            }
        }
        
        switch numExploded {
        case 0:
            /// Nothing:
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
    }
    
    /// Challenge 2:
    func gameOver() {
        
        gameTimer?.invalidate()
        
        for node in fireworks {
            node.removeFromParent()
        }
        
        isGameOver = true
        
        gameOverLabel = SKLabelNode(fontNamed: "PartyLetPlain")
        gameOverLabel.zPosition = 0
        gameOverLabel.position = CGPoint(x: 512, y: 334)
        gameOverLabel.horizontalAlignmentMode = .center
        gameOverLabel.text = "Game over!"
        gameOverLabel.fontSize = 76
        addChild(gameOverLabel)
        
        restartLabel = SKLabelNode(fontNamed: "Zapfino")
        restartLabel.zPosition = 0
        restartLabel.position = CGPoint(x: 512, y: 264)
        restartLabel.horizontalAlignmentMode = .center
        restartLabel.text = "Restart"
        addChild(restartLabel)
    }
    
    func startGame() {
        
        numberOfLaunches = 0
        score = 0
        
        if let gameOverLabel = gameOverLabel {
            gameOverLabel.removeFromParent()
        }
        
        if let restartLabel = restartLabel {
            restartLabel.removeFromParent()
        }
        
        isGameOver = false
        
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }
}
