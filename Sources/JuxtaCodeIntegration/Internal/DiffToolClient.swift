import Cocoa

struct DiffToolClient {
  
  static func open(repo: URL, revspecA: String, revspecB: String?) async throws {
    
    var isDir: ObjCBool = false
    guard FileManager.default.fileExists(atPath: repo.path, isDirectory: &isDir), isDir.boolValue else { throw JuxtaCodeError.fileNotFound }
    
    guard let appURL = juxtaCodeURL,
          let driverURL = juxtaCodeDriverURL
    else {
      throw JuxtaCodeError.applicationNotFound
    }
    
    let isSandboxed = await SandboxDetector.shared.isSandboxed
    
    if !isSandboxed {
      let config = NSWorkspace.OpenConfiguration()
      config.allowsRunningApplicationSubstitution = false
      config.createsNewApplicationInstance = true
      
      try await NSWorkspace.shared.open([repo], withApplicationAt: driverURL, configuration: config)
    }
    
    let scriptSource =
"""
tell application "\(appURL.path)"
  diff "\(revspecA)" \(revspecB == nil ? "" : "and \"\(revspecB!)\"") in "\(repo.path)" \(isSandboxed ? "and prompt for permission yes" : "")
end tell
"""
    
    try await Task(priority: .userInitiated) {
      guard let script = NSAppleScript(source: scriptSource) else { throw JuxtaCodeError.applicationNotFound }
      
      var errorInfo: NSDictionary?
      
      let descriptor = script.executeAndReturnError(&errorInfo)
      
      guard let stringResult = descriptor.stringValue,
            let data = stringResult.data(using: .utf8),
            let result = try? JSONDecoder().decode(Result.self, from: data)
      else {
        throw JuxtaCodeError.failedToExecute(String(describing: errorInfo))
      }
      
      switch result.code {
      case 0:
        return
      case -1:
        throw JuxtaCodeError.failedToOpen
      default:
        throw JuxtaCodeError.unknown
      }
      
    }.value
  }
  
  private struct Result: Codable {
    let code: Int
  }
}
