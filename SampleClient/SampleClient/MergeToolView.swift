import SwiftUI
import Combine
import JuxtaCodeIntegration

struct MergeToolView: View {
  
  @State var repo: URL?
  @State var url: URL?
  @State var message: String? = nil
  
  @State private var isMergeToolOpen: Bool = false
  
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
              defer { isMergeToolOpen = false }
              
              do {
                let result = try await JuxtaCodeIntegration.MergeTool.open(url, in: repo)
                
                // Merge tool has finished so return the user to this app
                NSApp.activate(ignoringOtherApps: true)
                
                message = result.message
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

extension MergeTool.Result {
  var message: String {
    
    switch self {
    case .resolved:
      return "Conflict was resolved 👍"
    case .unresolved:
      return "Conflict was not resolved 👎"
    }
    
  }
}

public extension JuxtaCodeError {
  var message: String {
    switch self {
    case .applicationNotFound:
      return "Could not find JuxtaCode."
    case .fileNotFound:
      return "File not found."
    case .failedToExecute(_):
      return "Unable to communicate with JuxtaCode"
    case .failedToOpen:
      return "JuxtaCode was not able to open the file."
    case .unknown:
      return "Something went wrong."
    }
  }
}
