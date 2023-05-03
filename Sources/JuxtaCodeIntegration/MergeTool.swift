import Foundation

public struct MergeTool {
  
  /// Tells JuxtaCode to open the given file in a merge tool (if it's not already open) and returns the result.
  /// - Parameter file: The conflicted file to open.
  /// - Parameter repo: The local repository containing the conflicted file.
  /// - Returns: Whether or not the user resolved the conflict.
  public static func open(_ file: URL, in repo: URL) async throws -> Result {
    return try await MergeToolClient.open(url: file.resolvingSymlinksInPath(), in: repo.resolvingSymlinksInPath())
  }
  
  /// The result of a merge tool interaction.
  public enum Result {
    
    /// The file was resolved and the merge tool closed.
    case resolved
    
    /// The merge tool closed without resolving the file.
    case unresolved
  }
}
