//
//  GameScene.swift
//  JETiOS
//
//  Created by MACBOOK on 6/22/19.
//  Copyright © 2019 Alexander. All rights reserved.
//

import SpriteKit
import CoreMotion

func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

class GameScene: SKScene {
    
    struct PhysicsCategory {
        static let none      : UInt32 = 0
        static let all       : UInt32 = UInt32.max
        static let asteroid   : UInt32 = 0b1       // 1
        static let projectile: UInt32 = 0b10      // 2
    }
    var asteroidsDestroyed : Int = 0
    let asteroidName = "Asteroid"
    let projectileName = "Projectile"
    let scoreLabelName = "scoreLabel"
    
    var score = NSInteger()
    
    let player = SKSpriteNode(imageNamed: "F22Raptor")
    
    let playerName = "F22Raptor"
    
    let motionManager = CMMotionManager()
    
    let playerSize = CGSize(width: 30, height: 16)
    
    override func didMove(to view: SKView) {
        
        motionManager.startAccelerometerUpdates()
        
        backgroundColor = SKColor.black
        
        player.position = CGPoint(x: size.width * 0.5, y: size.height * 0.1)
        
        addChild(player)
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addAsteroid),
                SKAction.wait(forDuration: 1.0)
                ])
        ))
        let backgroundMusic = SKAudioNode(fileNamed: "backgroundMusic.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
        score = 0
        scoreLabel = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        scoreLabel.position = CGPoint( x: self.frame.midX, y: 3 * self.frame.size.height / 4 )
        scoreLabel.zPosition = 100
        scoreLabel.text = String(score)
        self.addChild(scoreLabel)
        
    }
    

        
    
    func processUserMotion(forUpdate currentTime: CFTimeInterval) {
        // 1
        if let ship = childNode(withName: playerName) as? SKSpriteNode {
            // 2
            if let data = motionManager.accelerometerData {
                // 3
                if fabs(data.acceleration.x) > 0.2 {
                    // 4 How do you move the ship?
                    print("Acceleration: \(data.acceleration.x)")
                    ship.physicsBody!.applyForce(CGVector(dx: 40 * CGFloat(data.acceleration.x), dy: 0))
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        processUserMotion(forUpdate: currentTime)
    }
    
    func setupPlayer() {
        // 1
        let player = makePlayer()
        
        // 2
        player.position = CGPoint(x: size.width / 2.0, y: playerSize.height / 2.0)
        addChild(player)
    }
    
    func makePlayer() -> SKNode {
        
        let player = SKSpriteNode(imageNamed: "F22Raptor")
        
        let playerName = "F22Raptor"
        
        player.name = playerName
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.frame.size)
        
        player.physicsBody!.isDynamic = true
        
        player.physicsBody!.affectedByGravity = false
        
        player.physicsBody!.mass = 0.02
        
        return player
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    
    func addAsteroid() {
        // Create sprite
        let asteroid = SKSpriteNode(imageNamed: "Asteroid")
        asteroid.name = "Asteroid"
        
        asteroid.physicsBody = SKPhysicsBody(rectangleOf: asteroid.size) // 1
        asteroid.physicsBody?.isDynamic = true // 2
        asteroid.physicsBody?.categoryBitMask = PhysicsCategory.asteroid // 3
        asteroid.physicsBody?.contactTestBitMask = PhysicsCategory.projectile // 4
        asteroid.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
        
        // Determine where to spawn the asteroid along the Y axis
        let actualY = random(min: asteroid.size.width/2, max: size.width - asteroid.size.width/2)
        
        // Position the asteroid slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        asteroid.position = CGPoint(x: actualY, y: size.height + asteroid.size.height/2)
        
        // Add the asterid to the scene
        addChild(asteroid)
        
        // Determine speed of the asteroid
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: actualY, y: -asteroid.size.width/2), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.run() { [weak self] in
            guard let `self` = self else { return }
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene()
            gameOverScene.backgroundColor = UIColor.blue
            gameOverScene.scaleMode = SKSceneScaleMode.resizeFill
            
            
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        asteroid.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        run(SKAction.playSoundFileNamed("ShootingSound.caf", waitForCompletion: false))
        
        let touchLocation = touch.location(in: self)
        
        // 2 - Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "Projectile")
        projectile.position = player.position
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.asteroid
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        // 3 - Determine offset of location to projectile
        let offset = touchLocation - projectile.position
        
        // 4 - Bail out if you are shooting down or backwards
        if offset.y < 0 { return }
        
        // 5 - OK to add now - you've double checked position
        addChild(projectile)
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
        
        // 9 - Create the actions
        let actionMove = SKAction.move(to: realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    func adjustScore(by points : Int) {
        asteroidsDestroyed += points
        
        if let scoreLabel = childNode(withName: scoreLabelName) as? SKLabelNode {
            scoreLabel.text = String(format: "Score: %04u", self.asteroidsDestroyed)
            scoreLabel.position = CGPoint(
                x: frame.size.width / 2,
                y: size.height - (40 + scoreLabel.frame.size.height/2)
            )
            scoreLabel.horizontalAlignmentMode = .center
        }
    }
    
    func projectileDidCollideWithAsteroid(projectile: SKSpriteNode, asteroid: SKSpriteNode) {
        print("Hit")
        projectile.removeFromParent()
        asteroid.removeFromParent()
        
        
        let scoreLabel = SKLabelNode(fontNamed: "Courier")
        scoreLabel.text = "\(adjustScore(by: 1))"
        scoreLabel.name = scoreLabelName
        scoreLabel.horizontalAlignmentMode = .right
        
        addChild(scoreLabel)
        
        
        if asteroidsDestroyed > 30 {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene()
            view?.presentScene(gameOverScene, transition: reveal)
            
        }
    }
    var scoreLabel: SKLabelNode!
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.asteroid != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.projectile != 0)) {
            if let asteroid = firstBody.node as? SKSpriteNode,
                let projectile = secondBody.node as? SKSpriteNode {
                projectileDidCollideWithAsteroid(projectile: projectile, asteroid: asteroid)
            }
        }
    }
}
