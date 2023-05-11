import Cocoa

struct MergeToolClient {
  
  static func open(url: URL, in repo: URL, timeout: TimeInterval) async throws -> MergeTool.Result {
    
    var isDir: ObjCBool = false
    guard FileManager.default.fileExists(atPath: repo.path, isDirectory: &isDir), isDir.boolValue,
          FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir), !isDir.boolValue
    else {
      throw JuxtaCodeError.fileNotFound
    }
    
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
  with timeout of \(timeout) seconds
    merge "\(url.path)" in "\(repo.path)" \(isSandboxed ? "and prompt for permission yes" : "")
  end timeout
end tell
"""
        
    return try await Task(priority: .userInitiated) {
      guard let script = NSAppleScript(source: scriptSource) else { throw JuxtaCodeError.applicationNotFound }

      var errorInfo: NSDictionary?
      
      let descriptor = script.executeAndReturnError(&errorInfo)
      
      guard let stringResult = descriptor.stringValue,
            let data = stringResult.data(using: .utf8),
            let result = try? JSONDecoder().decode(Result.self, from: data)
      else {
        if errorInfo?[NSAppleScript.errorNumber] as? Int == -1712 {
          throw JuxtaCodeError.timedOut
        }
        throw JuxtaCodeError.failedToExecute(String(describing: errorInfo))
      }

      switch result.code {
      case 0:
        return MergeTool.Result.resolved
      case 1:
        return MergeTool.Result.unresolved
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
