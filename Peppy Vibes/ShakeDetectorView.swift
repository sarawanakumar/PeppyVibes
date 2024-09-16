//
//  ShakeDetectorView.swift
//  Peppy Vibes
//
//  Created by Saravanakumar Selladurai on 14/09/24.
//

import SwiftUI

struct ShakeDetectorView: UIViewControllerRepresentable {
    var onShake: () -> Void
    
    func makeUIViewController(context: Context) -> ShakeDetectingViewController {
        let vc = ShakeDetectingViewController()
        vc.onShake = onShake
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ShakeDetectingViewController, context: Context) {
    }
}
