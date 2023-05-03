import Foundation

actor SandboxDetector {
  
  static let shared = SandboxDetector()

  lazy private(set) var isSandboxed = _isSandboxed()
  
  private init() {}
  
  private func _isSandboxed() -> Bool {
    let bundleURL = Bundle.main.bundleURL as CFURL
    var staticCode: SecStaticCode?
    
    var isSandboxed = false
    let kSecCSDefaultFlags = SecCSFlags(rawValue: SecCSFlags.RawValue(0))
    
    if SecStaticCodeCreateWithPath(bundleURL, kSecCSDefaultFlags, &staticCode) == errSecSuccess,
       SecStaticCodeCheckValidityWithErrors(staticCode!, SecCSFlags(rawValue: kSecCSBasicValidateOnly), nil, nil) == errSecSuccess {
      
      let appSandbox = "entitlement[\"com.apple.security.app-sandbox\"] exists" as CFString
      
      var sandboxRequirement: SecRequirement?
      if SecRequirementCreateWithString(appSandbox, kSecCSDefaultFlags, &sandboxRequirement) == errSecSuccess {
        let codeCheckResult = SecStaticCodeCheckValidityWithErrors(staticCode!, SecCSFlags(rawValue: kSecCSBasicValidateOnly), sandboxRequirement, nil)
        if (codeCheckResult == errSecSuccess) {
          isSandboxed = true
        }
      }
    }
    return isSandboxed
  }
}
