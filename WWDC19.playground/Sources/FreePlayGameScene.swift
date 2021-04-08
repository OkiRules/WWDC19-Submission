import PlaygroundSupport
import AVFoundation
import SpriteKit

public class FreePlayGameScene: SKScene, SKPhysicsContactDelegate, AVSpeechSynthesizerDelegate {
    
    // MARK: - Varibles / Constants
    private var amountOfPollutionRemoved: Int = 0
    private var waitDuration: Double = 2.15
    private var speedOfEnemy: Double = 3.00
    private var originalWaitDuration: Double = 2.15
    private var originalSpeedOfEnemy: Double = 3.00
    private var highScore: Int = 0
    private var newScore: Int = 2
    private var didBeginFuctionRan: Bool = false
    private var usesParticles: Bool = false
    private var planet: SKSpriteNode!
    private var scoreLabel: SKLabelNode!
    private var smokeParticle: SKEmitterNode!
    private var fireParticle: SKEmitterNode!
    private var gasParticle: SKEmitterNode!
    private var explosionParticle: SKEmitterNode!
    private var fireworkParticle: SKEmitterNode!
    private var pollutionImageNames = [String]()
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var audioPlayer = AVAudioPlayer()
    
    // MARK: - Functions
    public override func didMove(to view: SKView) {
        
        setupScene()
    }
    
    func setupScene() {
        
        playBackgroundMusic()
        JSONExtentions().retrieveFromJSONFile { (userData, error) in
            
            if error != nil {
                
                print(error!)
            } else {
                
                guard
                    let usesParticles = userData?.usesParticles,
                    let waitDuration = userData?.waitDuration,
                    let speedOfEnemy = userData?.speedOfEnemy,
                    let highScore = userData?.highScore
                    else { return }
                
                self.usesParticles = usesParticles
                self.waitDuration = waitDuration
                self.speedOfEnemy = speedOfEnemy
                self.originalWaitDuration = waitDuration
                self.originalSpeedOfEnemy = speedOfEnemy
                self.highScore = highScore
                
                physicsWorld.contactDelegate = self
                speechSynthesizer.delegate = self
                
                pollutionImageNames = ["orange-car", "yellow-car", "blue-car", "pig", "chicken", "cow", "coal", "coal", "coal", "factory", "factory", "factory"]
                
                createPlanet()
                createScoreLabel()
                
                amountOfPollutionRemoved = 0
                
                let utterance = Extentions().getUtterance("Welcome to Free Play mode, here you try to remove as much pollution as you can. Good luck!")
                speechSynthesizer.speak(utterance)
            }
        }
    }
    
    func playBackgroundMusic() {
        
        let soundURL = URL(fileURLWithPath: Bundle.main.path(forResource: "backgroundMusic", ofType: "mp3")!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer.numberOfLoops = -1
            audioPlayer.play()
        } catch {
            print(error)
        }
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        
        if utterance.speechString == "Welcome to Free Play mode, here you try to remove as much pollution as you can. Good luck!" {
            createEnemy()
            createEnemyLoop()
        }
    }
    
    func createEnemyLoop() {
        
        self.removeAction(forKey: "spawning")
        let waitAction = SKAction.wait(forDuration: TimeInterval(waitDuration))
        let createEnemy = SKAction.run {
            self.createEnemy()
        }
        let sequence = SKAction.sequence([waitAction, createEnemy])
        self.run(SKAction.repeatForever(sequence), withKey: "spawning")
    }
    
    func endGame() {
        
        var savingScore = highScore
        if amountOfPollutionRemoved > highScore {
            savingScore = amountOfPollutionRemoved
        }
        let userData = UserData(highScore: savingScore, hasUnlockedFreePlay: true, usesParticles: usesParticles, waitDuration: originalWaitDuration, speedOfEnemy: originalSpeedOfEnemy)
        JSONExtentions().saveToJsonFile(userData: userData) { (error) in
            
            if error != nil {
                print(error!)
            } else {
                if let homeScreen = HomeScreen(fileNamed: "HomeScreen") {
                    homeScreen.scaleMode = .aspectFill
                    let transition = SKTransition.fade(with: .black, duration: 2.75)
                    self.view?.presentScene(homeScreen, transition: transition)
                }
            }
        }
    }
    
    func createPlanet() {
        
        planet = childNode(withName: "planet") as? SKSpriteNode
        
        planet.texture = SKTexture(imageNamed: "earth")
        planet.size = CGSize(width: 80, height: 80)
        planet.physicsBody = SKPhysicsBody(texture: planet.texture!, size: CGSize(width: planet.size.width, height: planet.size.height))
        planet.physicsBody?.affectedByGravity = false
        planet.physicsBody?.isDynamic = true
        planet.physicsBody?.collisionBitMask = 0
        planet.physicsBody?.contactTestBitMask = 1
        planet.zPosition = 2
    }
    
    func createScoreLabel() {
        
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        
        scoreLabel.text = String(amountOfPollutionRemoved)
        scoreLabel.fontSize = 70
        scoreLabel.zPosition = 2
    }
    
    func createEnemy() {
        
        let random = Int.random(in: 1..<4)
        var position = CGPoint()
        let moveTo = CGPoint(x: self.planet.position.x, y: self.planet.position.y)
        
        switch random {
            
        // Top
        case 1:
            
            let randomNumber = Int.random(in: Int(-self.frame.maxX)...Int(self.frame.maxX))
            position = CGPoint(x: randomNumber, y: 250)
            break
            
        // Bottom
        case 2:
            
            let randomNumber = Int.random(in: Int(-self.frame.maxX)...Int(self.frame.maxX))
            position = CGPoint(x: randomNumber, y: -250)
            break
            
        // Right
        case 3:
            
            let randomNumber = Int.random(in: Int(-self.frame.maxY)...Int(self.frame.maxY))
            position = CGPoint(x: 370, y: randomNumber)
            break
            
        // Left
        case 4:
            let randomNumber = Int.random(in: Int(-self.frame.maxY)...Int(self.frame.maxY))
            position = CGPoint(x: -370, y: randomNumber)
            break
            
        default:
            break
        }
        
        self.spawnPollutionAtPosition(position: position, moveTo: moveTo)
    }
    
    func randomPollutionNode() -> SKSpriteNode {
        
        if let pollutionName = pollutionImageNames.randomElement() {
            let pollutionImage = SKSpriteNode(imageNamed: pollutionName)
            if pollutionName == "pig" || pollutionName == "chicken" || pollutionName == "cow" || pollutionName == "factory" {
                if usesParticles {
                    gasParticle = SKEmitterNode(fileNamed: "Gas")
                    gasParticle.position = CGPoint(x: 15, y: -15.0)
                    gasParticle.name = "gasParticle"
                    gasParticle.zPosition = 22.0
                    gasParticle.targetNode = self.scene
                    pollutionImage.addChild(gasParticle)
                }
                pollutionImage.size = CGSize(width: 80, height: 85)
            } else if pollutionName.contains("car") {
                if usesParticles {
                    smokeParticle = SKEmitterNode(fileNamed: "Smoke")
                    smokeParticle.position = CGPoint(x: 15, y: -15.0)
                    smokeParticle.name = "smokeParticle"
                    smokeParticle.zPosition = 22.0
                    smokeParticle.targetNode = self.scene
                    pollutionImage.addChild(smokeParticle)
                }
                pollutionImage.size = CGSize(width: 80, height: 80)
            } else if pollutionName == "coal" {
                if usesParticles {
                    fireParticle = SKEmitterNode(fileNamed: "Fire")
                    fireParticle.position = CGPoint(x: 15, y: -15.0)
                    fireParticle.name = "someParticle"
                    fireParticle.zPosition = 22.0
                    fireParticle.targetNode = self.scene
                    pollutionImage.addChild(fireParticle)
                }
                pollutionImage.size = CGSize(width: 80, height: 80)
            }
            
            return pollutionImage
        } else {
            return SKSpriteNode()
        }
    }
    
    func spawnPollutionAtPosition(position: CGPoint, moveTo: CGPoint) {
        
        let pollutionImage = randomPollutionNode()
        pollutionImage.position = position
        pollutionImage.physicsBody = SKPhysicsBody(texture: pollutionImage.texture!, size: CGSize(width: pollutionImage.size.width, height: pollutionImage.size.height))
        pollutionImage.physicsBody?.affectedByGravity = false
        pollutionImage.physicsBody?.isDynamic = true
        pollutionImage.physicsBody?.collisionBitMask = 1
        pollutionImage.physicsBody?.contactTestBitMask = 1
        pollutionImage.zPosition = 2
        pollutionImage.name = "pollutionImage"
        
        let rotateAction = SKAction.rotate(byAngle: 2.0 * CGFloat.pi, duration: 10.0)
        let move = SKAction.move(to: moveTo, duration: speedOfEnemy)
        pollutionImage.run(move, withKey: "moveAction")
        pollutionImage.run(rotateAction, withKey: "rotateAction")
        self.addChild(pollutionImage)
    }
    
    public func didBegin(_ contact: SKPhysicsContact) {
        
        let firstBody = contact.bodyA.node as! SKSpriteNode
        let secondBody = contact.bodyB.node as! SKSpriteNode
        if firstBody.name == "planet" && secondBody.name == "pollutionImage" {
            if didBeginFuctionRan == false {
                didBeginFuctionRan = true
                removeEnemyOrParticle()
                
                scoreLabel.isHidden = true
                endGame()
            }
        }
    }
    
    public override func update(_ currentTime: TimeInterval) {
        if newScore == amountOfPollutionRemoved {
            newScore += 2
            waitDuration -= 0.13
            speedOfEnemy -= 0.13
            createEnemyLoop()
        }
    }
    
    func removeEnemyOrParticle() {
        for child in children {
            if child.name == "pollutionImage" || child.name == "explosionParticle" {
                child.removeFromParent()
            }
        }
    }
    
    // MARK: - Touches
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let positionInScene = touch.location(in: self)
        let touchedNode = self.atPoint(positionInScene)
        
        if let name = touchedNode.name {
            if name == "pollutionImage" {
                amountOfPollutionRemoved += 1
                scoreLabel.text = String(amountOfPollutionRemoved)
                touchedNode.removeAllActions()
                
                explosionParticle = SKEmitterNode(fileNamed: "ExplosionParticle")
                explosionParticle.position = touchedNode.position
                explosionParticle.name = "explosionParticle"
                explosionParticle.zPosition = 22.0
                explosionParticle.targetNode = self.scene
                touchedNode.removeFromParent()
                
                let addEmitterAction = SKAction.run({
                    self.explosionParticle.name = "explosionParticle"
                    self.addChild(self.explosionParticle)
                })
                let playExplosionSound = SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false)
                let wait = SKAction.wait(forDuration: TimeInterval(0.5))
                let remove = SKAction.run({
                    self.explosionParticle.removeFromParent()
                })
                let sequence = SKAction.sequence([addEmitterAction, playExplosionSound, wait, remove])
                
                self.run(sequence)
            } else if name == "backButton" {
                removeEnemyOrParticle()
                speechSynthesizer.stopSpeaking(at: .immediate)
                
                var savingScore = highScore
                if amountOfPollutionRemoved > highScore {
                    savingScore = amountOfPollutionRemoved
                }
                let userData = UserData(highScore: savingScore, hasUnlockedFreePlay: true, usesParticles: usesParticles, waitDuration: originalWaitDuration, speedOfEnemy: originalSpeedOfEnemy)
                JSONExtentions().saveToJsonFile(userData: userData) { (error) in
                    if error != nil {
                        print(error!)
                    } else {
                        if let homeScreen = HomeScreen(fileNamed: "HomeScreen") {
                            homeScreen.scaleMode = .aspectFill
                            let transition = SKTransition.fade(with: .black, duration: 2.75)
                            self.view?.presentScene(homeScreen, transition: transition)
                        }
                    }
                }
            }
        }
    }
}

