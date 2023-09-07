import AppKit

public struct DiffTool {
  
  /// Tells JuxtaCode to compare the given revspec(s) in the given repository.
  /// - Parameters:
  ///   - revspecA: The revspec to compare with `revspecB`.
  ///   - revspecB: The revspec to compare with `revspecA`. If `nil`, `revspecA` will be compared with the working directory.
  ///   - repo: The local repository.
  ///   - pathspecs: The pathspecs to compare. If empty, all files will be compared.
  public static func compare(_ revspecA: String, and revspecB: String? = nil, in repo: URL, pathspecs: [String] = []) async throws {
    let appURL = try URL.juxtaCodeURL()

    let diffURL = try URL.diff(repo: repo, revspecA: revspecA, revspecB: revspecB, pathspecs: pathspecs)
    
    if #available(macOS 14.0, *) {
      await NSApp.yieldActivation(toApplicationWithBundleIdentifier: juxtaCodeBundleID)
    }
    
    try await NSWorkspace.shared.open([diffURL], withApplicationAt: appURL, configuration: .init())
  }
}
