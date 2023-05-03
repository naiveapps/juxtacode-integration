import SwiftUI
import JuxtaCodeIntegration

struct DiffToolView: View {
  
  @State var url: URL?

  @State var revspecA: String = ""
  @State var revspecB: String = ""
  
  @State var message: String? = nil
  
  private var canOpenDiffTool: Bool {
    return url != nil && revspecA.isEmpty == false
  }
  
  var body: some View {
    VStack() {
      
      GroupBox("Repository") {
        HStack(spacing: 10) {
          if let url = url {
            Image(nsImage: NSWorkspace.shared.icon(forFile: url.path()))
            Text(url.path())
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
      
      GroupBox("Revspecs") {
        HStack {
          TextField("Revspec A", text: $revspecA)
          TextField("Revspec B (optional)", text: $revspecB)
        }
        .padding()
      }
      .padding()
      
      Spacer(minLength: 10)
      
      Button("Open Diff Tool") {
        if canOpenDiffTool, let url = url {
          message = nil
          Task {
            do {
              try await DiffTool.compare(revspecA, and: revspecB, in: url)
              message = "Opened 👍"
            } catch let error as JuxtaCodeError {
              message = "❌ " + error.message
            } catch {
              message = "❌ \(error)"
            }
          }
        }
      }
      .opacity(canOpenDiffTool ? 1 : 0.6)
      .controlSize(.large)
      
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
      url = dialog.url
    }
  }
}

struct DiffToolView_Previews: PreviewProvider {
  static var previews: some View {
    DiffToolView()
  }
}
