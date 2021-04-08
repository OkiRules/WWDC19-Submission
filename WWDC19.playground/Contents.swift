import PlaygroundSupport
import SpriteKit
/*:
 
 # Saving Earth
 
My name is Oscar and I live in Melbourne Australia. Saving Earth is a game I designed with my four year old sister in mind, to try to help children understand the basic concepts of climate change and global warming. As young children can’t read, I used voice annotation so they can understand the concepts in the game.
 
 ## There are a few options avalible below to customise the game:
 
 **Make sure the directory "/Users/{your_computer_user_name}/Documents/Shared Playground Data" exists and that you do not have a file named "UserData.json" otherwise this app will not work.**
 */
// Would you like to use particles? If you choose yes this may result in a laggy game.
let usesParticles = true

// The (starting wait duration) impacts how long it takes for a object to spawn.
// The (stating speed of enemy) impacts how fast the object makes its way to Earth.
let waitDuration = 2.15
let speedOfEnemy = 3.00
// Please keep in mind, as the game progresses these values will automatically become smaller and smaller to make the game harder.


// Load the SKScene from "HomeScreen.sks"
let sceneView = SKView(frame: CGRect(x: 0, y: 0, width: 640, height: 480))
if let homeScreen = HomeScreen(fileNamed: "HomeScreen") {
    
    // Set the scale mode to scale to fit the window
    homeScreen.scaleMode = .aspectFill
    
    // Set user propreties
    homeScreen.usesParticles = usesParticles
    homeScreen.waitDuration = Double(waitDuration)
    homeScreen.speedOfEnemy = Double(speedOfEnemy)
    
    // Present the scene
    sceneView.presentScene(homeScreen)
}

// Present in Swift Playgrounds live view
PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
