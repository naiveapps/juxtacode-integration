import SwiftUI
import Combine
import JuxtaCodeIntegration

struct MergeToolView: View {
  
  @EnvironmentObject private var appDelegate: AppDelegate
  
  @State var repo: URL?
  @State var url: URL?
  @State var message: String? = nil
  
  @State private var isMergeToolOpen: Bool = false {
    didSet {
      if isMergeToolOpen {
        // reset url
        appDelegate.url = nil
      }
    }
  }
  
  private var canOpenMergeTool: Bool {
    return !isMergeToolOpen && repo != nil && url != nil
  }
  
  var body: some View {
    VStack {
      GroupBox("Repository") {
        HStack(spacing: 10) {
          if let repo = repo {
            Image(nsImage: NSWorkspace.shared.icon(forFile: repo.path()))
            Text(repo.path())
              .truncationMode(.head)
              .lineLimit(1)
          }
          
          Spacer(minLength: 0)
          
          Button("Choose Repository…", action: chooseRepository)
            .fixedSize()
        }
        .padding()
      }
      .padding()
      
      GroupBox("Conflicted File") {
        HStack(spacing: 10) {
          if let url = url {
            Image(nsImage: NSWorkspace.shared.icon(forFile: url.path()))
            Text(url.path())
              .truncationMode(.head)
              .lineLimit(1)
          }
          
          Spacer(minLength: 0)
          
          Button("Choose Conflicted File…", action: chooseFile)
            .fixedSize()
        }
        .padding()
      }
      .padding()
      
      Spacer(minLength: 10)
      
      if isMergeToolOpen {
        ProgressView()
      } else {
        Button("Open Merge Tool") {
          if canOpenMergeTool, let repo = repo, let url = url {
            message = nil
            Task {
              isMergeToolOpen = true
              
              do {
                try await JuxtaCodeIntegration.MergeTool.open(url, in: repo, callback: .init(string: "juxtacode-client://merge-tool"))
              } catch let error as JuxtaCodeError {
                message = "❌ " + error.message
              } catch {
                message = "❌ \(error)"
              }
            }
          }
        }
        .opacity(canOpenMergeTool ? 1 : 0.6)
        .controlSize(.large)
      }
      
      Text(message ?? "")
        .lineLimit(0)
        .frame(minHeight: 20)
    }
    .onChange(of: appDelegate.url) { url in
      isMergeToolOpen = (url == nil)
    }
  }
  
  func chooseRepository() {
    let dialog = NSOpenPanel()
    dialog.canCreateDirectories = false
    dialog.canChooseFiles = false
    dialog.canChooseDirectories = true
    dialog.allowedContentTypes = [.folder]
    
    dialog.prompt = "Choose Repository"
    
    if dialog.runModal() == .OK {
      repo = dialog.url
    }
  }

  func chooseFile() {
    let dialog = NSOpenPanel()
    dialog.canCreateDirectories = false
    
    dialog.prompt = "Choose Conflicted File"
    
    if dialog.runModal() == .OK {
      url = dialog.url
    }
  }
}

struct MergeTool_Previews: PreviewProvider {
  static var previews: some View {
    MergeToolView()
  }
}

public extension JuxtaCodeError {
  var message: String {
    switch self {
    case .applicationNotFound:
      return "Could not find JuxtaCode."
    case .failedToGenerateUniversalLink:
      return "JuxtaCode was not able to open the file."
    }
  }
}
