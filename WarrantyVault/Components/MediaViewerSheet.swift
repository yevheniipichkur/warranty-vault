import QuickLook
import SwiftUI

struct MediaViewerSheet: UIViewControllerRepresentable {
    let urls: [URL]
    var startIndex: Int = 0

    func makeUIViewController(context: Context) -> UINavigationController {
        let ql = QLPreviewController()
        ql.dataSource = context.coordinator
        ql.currentPreviewItemIndex = startIndex
        let nav = UINavigationController(rootViewController: ql)
        return nav
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        if let ql = uiViewController.topViewController as? QLPreviewController {
            ql.currentPreviewItemIndex = startIndex
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(urls: urls) }

    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let urls: [URL]
        init(urls: [URL]) { self.urls = urls }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { urls.count }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            urls[index] as NSURL
        }
    }
}
