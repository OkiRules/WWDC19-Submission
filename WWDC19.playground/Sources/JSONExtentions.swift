import Foundation
import PlaygroundSupport

public class JSONExtentions {
    
    // MARK: - Varibles / Constants
    let fileUrl = PlaygroundSupport.playgroundSharedDataDirectory.appendingPathComponent("UserData.json")
    
    // MARK: - Functions
    func saveToJsonFile(userData: UserData, completionHandler: (_ error: Error?) -> Void) {
        do {
            let jsonData = try JSONEncoder().encode(userData)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            do {
                try jsonString.write(to: fileUrl, atomically: true, encoding: .utf8)
                completionHandler(nil)
            } catch {
                completionHandler(nil)
            }
        } catch {
            completionHandler(nil)
        }
    }
    
    func retrieveFromJSONFile(completionHandler: (_ data: UserData?, _ error: Error?) -> Void) {
        do {
            let data = try Data(contentsOf: fileUrl)
            do {
                let userData = try JSONDecoder().decode(UserData.self, from: data)
                completionHandler(userData, nil)
            } catch {
                completionHandler(nil, error)
            }
        } catch {
            completionHandler(nil, error)
        }
    }
}
