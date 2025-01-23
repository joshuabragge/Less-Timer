import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        let controller = SFSafariViewController(url: url, configuration: config)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }
    
    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        @Binding var isPresented: Bool
        
        init(isPresented: Binding<Bool>) {
            _isPresented = isPresented
        }
        
        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            isPresented = false
        }
    }
}

class SafariService {
    static let shared = SafariService()
    private init() {}
    
    func validateURL(_ urlString: String) -> URL? {
        guard let url = URL(string: urlString),
              UIApplication.shared.canOpenURL(url) else {
            return nil
        }
        return url
    }
}
