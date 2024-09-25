//
//  ShakeDetectingViewController.swift
//  Peppy Vibes
//
//  Created by Saravanakumar Selladurai on 14/09/24.
//

import UIKit

class ShakeDetectingViewController: UIViewController {
    
    var onShake: (() -> Void)?

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            onShake?()
        }
    }

}
