import SwiftUI

@main
struct SampleClientApp: App {
  var body: some Scene {
    WindowGroup {
      TabView {
        DiffToolView()
          .tabItem {
            Text("Diff Tool")
          }
        MergeToolView()
          .tabItem {
            Text("Merge Tool")
          }
      }
        .padding()
        .frame(minWidth: 400, minHeight: 370, maxHeight: 370)
        .fixedSize(horizontal: false, vertical: true)
    }
    .windowResizabilityContentSize()
  }
}

extension Scene {
  func windowResizabilityContentSize() -> some Scene {
    if #available(macOS 13.0, *) {
      return windowResizability(.contentSize)
    } else {
      return self
    }
  }
}
