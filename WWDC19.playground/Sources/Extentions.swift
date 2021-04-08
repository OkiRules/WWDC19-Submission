import Foundation
import AVFoundation

public class Extentions {
    
    // MARK: - Varibles / Constants
    func getUtterance(_ text: String) -> AVSpeechUtterance {
        
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.rate = 0.45
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        return speechUtterance
    }
}
