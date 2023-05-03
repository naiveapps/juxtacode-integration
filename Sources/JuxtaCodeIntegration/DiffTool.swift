import Foundation

public struct DiffTool {
  
  /// Tells JuxtaCode to compare the given revspec(s) in the given repository.
  /// - Parameters:
  ///   - revspecA: The revspec to compare with `revspecB`.
  ///   - revspecB: The revspec to compare with `revspecA`. If `nil`, `revspecA` will be compared with the working directory.
  ///   - repo: The local repository.
  public static func compare(_ revspecA: String, and revspecB: String? = nil, in repo: URL) async throws {
    try await DiffToolClient.open(repo: repo.resolvingSymlinksInPath(), revspecA: revspecA, revspecB: revspecB)
  }
}
