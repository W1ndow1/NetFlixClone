//
//  PreviewExtension.swift
//  NetFlixClone
//
//  Created by window1 on 2023/01/05.
//

import SwiftUI

#if DEBUG
extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
    }
    func toPreview() -> some View {
        Preview(viewController: self)
    }
}
#endif
