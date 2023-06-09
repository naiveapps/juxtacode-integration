import Foundation

public struct MergeTool {
  
  /// Tells JuxtaCode to open the given file in a merge tool (if it's not already open) and returns the result.
  /// - Parameter file: The conflicted file to open.
  /// - Parameter repo: The local repository containing the conflicted file.
  /// - Parameter timeout: Timeout duration for the merge interaction. Default is 5 hours.
  /// - Returns: Whether or not the user resolved the conflict.
  public static func open(_ file: URL, in repo: URL, timeout: TimeInterval = 18000) async throws -> Result {
    return try await MergeToolClient.open(url: file.resolvingSymlinksInPath(),
                                          in: repo.resolvingSymlinksInPath(),
                                          timeout: timeout)
  }
  
  /// The result of a merge tool interaction.
  public enum Result {
    
    /// The file was resolved and the merge tool closed.
    case resolved
    
    /// The merge tool closed without resolving the file.
    case unresolved
  }
}
