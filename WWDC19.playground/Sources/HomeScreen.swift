import SpriteKit
import PlaygroundSupport
import Foundation
import AVFoundation

public class HomeScreen: SKScene {
    
    // MARK: - Varibles / Constants
    private var freePlayGameLabel: SKLabelNode!
    private var highScoreLabel: SKLabelNode!
    private var hasUnlockedFreePlay = false
    public var waitDuration = 2.15
    public var speedOfEnemy = 3.00
    private let speechSynthesizer = AVSpeechSynthesizer()
    public var usesParticles = false
    private var audioPlayer = AVAudioPlayer()
    
    // MARK: - Functions
    public override func didMove(to view: SKView) {
        
        setupScene()
    }
    
    func setupScene() {
        
        playBackgroundMusic()
        
        freePlayGameLabel = childNode(withName: "freePlayGameLabel") as? SKLabelNode
        highScoreLabel = childNode(withName: "highScoreLabel") as? SKLabelNode
        
        let fontURL = Bundle.main.url(forResource: "Herculanum", withExtension: "ttf")
        CTFontManagerRegisterFontsForURL(fontURL! as CFURL, CTFontManagerScope.process, nil)
        
        setupUserData()
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
    
    func setupUserData() {
        
        JSONExtentions().retrieveFromJSONFile { (userData, error) in
            
            if error != nil {
                let userData = UserData(
                    highScore: 0,
                    hasUnlockedFreePlay: false,
                    usesParticles: usesParticles,
                    waitDuration: waitDuration,
                    speedOfEnemy: speedOfEnemy
                )
                JSONExtentions().saveToJsonFile(userData: userData) { (error) in
                    if error != nil {
                        print(error!)
                    } else {
                        self.hasUnlockedFreePlay = userData.hasUnlockedFreePlay
                        if userData.highScore != 0 {
                            highScoreLabel.text = "High Score: \(userData.highScore)"
                        } else {
                            highScoreLabel.text = "Play a game to get a high score"
                        }
                    }
                }
            } else if error != nil {
                print(error!)
            } else {
                guard
                    let highScore = userData?.highScore,
                    let hasUnlockedFreePlay = userData?.hasUnlockedFreePlay
                    else { return }
                let userData = UserData(
                    highScore: highScore,
                    hasUnlockedFreePlay: hasUnlockedFreePlay,
                    usesParticles: usesParticles,
                    waitDuration: waitDuration,
                    speedOfEnemy: speedOfEnemy
                )
                JSONExtentions().saveToJsonFile(userData: userData) { (error) in
                    if error != nil {
                        print(error!)
                    } else {
                        self.hasUnlockedFreePlay = userData.hasUnlockedFreePlay
                        if userData.highScore != 0 {
                            
                            highScoreLabel.text = "High Score: \(userData.highScore)"
                        }
                    }
                }
            }
        }
        
        if !hasUnlockedFreePlay {
            freePlayGameLabel.fontColor = .red
        } else {
            freePlayGameLabel.fontColor = .white
        }
    }
    
    // MARK: - Touches
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let locationTouched = touch.location(in: self)
        let nodesAtLocation = nodes(at: locationTouched)
        if nodesAtLocation.isEmpty == false {
            
            if nodesAtLocation[0].name == "startGameLabel" {
                if let storyGameScene = StoryGameScene(fileNamed: "GameScene") {
                    storyGameScene.scaleMode = .aspectFill
                    let transition = SKTransition.fade(with: .black, duration: 2.75)
                    self.view?.presentScene(storyGameScene, transition: transition)
                }
            } else if nodesAtLocation[0].name == "aboutGameLabel" {
                if let aboutScreen = AboutScreen(fileNamed: "AboutScreen") {
                    aboutScreen.scaleMode = .aspectFill
                    let transition = SKTransition.fade(with: .black, duration: 2.75)
                    self.view?.presentScene(aboutScreen, transition: transition)
                }
            } else if nodesAtLocation[0].name == "freePlayGameLabel" {
                if !hasUnlockedFreePlay {
                    let speechUtterance = AVSpeechUtterance(string: "You don't have free play mode unlocked yet, beat story mode to unlock it!")
                    speechUtterance.rate = 0.45
                    speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                    speechSynthesizer.speak(speechUtterance)
                } else {
                    if let freePlayGameScene = FreePlayGameScene(fileNamed: "GameScene") {
                        freePlayGameScene.scaleMode = .aspectFill
                        let transition = SKTransition.fade(with: .black, duration: 2.75)
                        self.view?.presentScene(freePlayGameScene, transition: transition)
                    }
                }
            }
        }
    }
}
