import Foundation

public enum JuxtaCodeError: Error {
  
  /// Unable to find `JuxtaCode.app`.
  case applicationNotFound
  
  /// A given repository or conflicted file could not be found.
  case fileNotFound
  
  /// An error occured while attempting to send a request to JuxtaCode via AppleScript.
  case failedToExecute(String)
  
  /// JuxtaCode failed to load a given repository or conflicted file.
  case failedToOpen
  
  /// JuxtaCode reported an unrecognised error.
  case unknown
}
