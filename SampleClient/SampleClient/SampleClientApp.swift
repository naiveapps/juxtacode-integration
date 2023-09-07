import SwiftUI

@main
struct SampleClientApp: App {
  
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var body: some Scene {
    Window("Sample Client", id: "main") {
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
    return windowResizability(.contentSize)
  }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
  @Published var url: URL?
  
  func application(_ application: NSApplication, open urls: [URL]) {
    self.url = urls.first
  }
}
