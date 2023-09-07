import AppKit

// MARK: - Locating the JuxtaCode app

public let juxtaCodeBundleID = "com.naiveapps.juxtacode"

public var isJuxtaCodeInstalled: Bool {
  _juxtaCodeURL != nil
}

private var _juxtaCodeURL: URL? {
#if DEBUG
    if let path = ProcessInfo.processInfo.environment["JUXTACODE_INTEGRATION_PATH"] {
      return .init(fileURLWithPath: path)
    }
#endif
    return NSWorkspace.shared.urlForApplication(withBundleIdentifier: juxtaCodeBundleID)
}

extension URL {
  static public func juxtaCodeURL() throws -> URL {
    guard let url = _juxtaCodeURL else { throw JuxtaCodeError.applicationNotFound }
    return url
  }
}

// MARK: - Universal Links

private extension URLComponents {
  static func universalLinkStub(head: String, path: String) -> URLComponents {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "ulinks.juxtacode.app"
    components.path = "/\(head)/\(path)"
    return components
  }
}

extension URL {
  static func merge(file: URL, in repo: URL, callback: URL?, bundleID: String) throws -> URL {
    var components = URLComponents.universalLinkStub(head: "merge", path: file.path())
    components.queryItems = [.init(name: "repo", value: repo.path()),
                             .init(name: "bundleID", value: bundleID)]
    
    if let callback = callback {
        components.queryItems?.append(.init(name: "callback", value: callback.absoluteString))
    }
    
    guard let url = components.url else { throw JuxtaCodeError.failedToGenerateUniversalLink }
    
    return url
  }

  static func diff(repo: URL, revspecA: String, revspecB: String?, pathspecs: [String]) throws -> URL {
    var components = URLComponents.universalLinkStub(head: "diff", path: repo.path())
    components.queryItems = [.init(name: "revspecA", value: revspecA),
                             .init(name: "revspecB", value: revspecB)]
    
    for i in 0..<pathspecs.count {
      components.queryItems?.append(.init(name: "path_\(i)", value: pathspecs[i]))
    }
    
    guard let url = components.url else { throw JuxtaCodeError.failedToGenerateUniversalLink }
    
    return url
  }
}

// MARK: - Errors

public enum JuxtaCodeError: Error {
  
  /// Unable to find `JuxtaCode.app`.
  case applicationNotFound
  
  case failedToGenerateUniversalLink
}
