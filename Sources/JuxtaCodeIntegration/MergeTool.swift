import AppKit

public struct MergeTool {
  
  /// Tells JuxtaCode to open the given file in a merge tool (if it's not already open) and returns the result.
  /// - Parameters:
  ///   - file: The conflicted file to open.
  ///   - repo: The local repository containing the conflicted file.
  ///   - callback: The URL to be opened by JuxtaCode when the merge tool closes.
  ///   - bundleID: The bundle ID of the application that JuxtaCode will yield to when the merge tool closes. Defaults to the ID of the current main bundle.
  public static func open(_ file: URL, in repo: URL, callback: URL? = nil, bundleID: String = Bundle.main.bundleIdentifier ?? "") async throws {
    let appURL = try URL.juxtaCodeURL()

    let mergeURL = try URL.merge(file: file, in: repo, callback: callback, bundleID: bundleID)
    
    if #available(macOS 14.0, *) {
      await NSApp.yieldActivation(toApplicationWithBundleIdentifier: juxtaCodeBundleID)
    }
    
    try await NSWorkspace.shared.open([mergeURL], withApplicationAt: appURL, configuration: .init())
  }
}
