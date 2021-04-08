import SpriteKit
import PlaygroundSupport
import Foundation
import AVFoundation

public class AboutScreen: SKScene {
    
    // MARK: - Varibles / Constants
    private var audioPlayer = AVAudioPlayer()
    
    // MARK: - Functions
    public override func didMove(to view: SKView) {
        
        playBackgroundMusic()
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
    
    // MARK: - Touches
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let locationTouched = touch.location(in: self)
        let nodesAtLocation = nodes(at: locationTouched)
        if nodesAtLocation.isEmpty == false {
            
            if nodesAtLocation[0].name == "backLabel" {
                if let homeScreen = HomeScreen(fileNamed: "HomeScreen") {
                    
                    homeScreen.scaleMode = .aspectFill
                    let transition = SKTransition.fade(with: .black, duration: 2.75)
                    self.view?.presentScene(homeScreen, transition: transition)
                }
            }
        }
    }
}
