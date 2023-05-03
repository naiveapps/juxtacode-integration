import Cocoa

public let juxtaCodeBundleID = "com.naiveapps.juxtacode"

public var juxtaCodeURL: URL? {
#if DEBUG
  if let path = ProcessInfo.processInfo.environment["JUXTACODE_INTEGRATION_PATH"] {
    return .init(fileURLWithPath: path)
  }
#endif
  return NSWorkspace.shared.urlForApplication(withBundleIdentifier: juxtaCodeBundleID)
}

public var juxtaCodeDriverURL: URL? {
  guard let baseURL = juxtaCodeURL else { return nil }
  let path = baseURL.path + "/Contents/Resources/JuxtaCodeDriver.app"
  return URL(fileURLWithPath: path)
}

public var isJuxtaCodeInstalled: Bool {
  juxtaCodeURL != nil
}
