import Foundation

struct UserData: Codable {
    
    // MARK: - Varibles / Constants
    let highScore: Int
    let hasUnlockedFreePlay: Bool
    let usesParticles: Bool
    let waitDuration: Double
    let speedOfEnemy: Double
    
    // MARK: - Initialisers
    init(highScore: Int, hasUnlockedFreePlay: Bool, usesParticles: Bool, waitDuration: Double, speedOfEnemy: Double) {
        self.highScore = highScore
        self.hasUnlockedFreePlay = hasUnlockedFreePlay
        self.usesParticles = usesParticles
        self.waitDuration = waitDuration
        self.speedOfEnemy = speedOfEnemy
    }
}

