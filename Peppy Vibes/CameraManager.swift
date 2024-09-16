//
//  CameraManager.swift
//  Peppy Vibes
//
//  Created by Saravanakumar Selladurai on 15/09/24.
//

import Foundation
import AVFoundation
import CoreImage

class CameraManager: NSObject {
    
    let captureSession = AVCaptureSession()
    var deviceInput: AVCaptureDeviceInput?
    var videoOutput: AVCaptureVideoDataOutput?
    let systemPrefferedCamera = AVCaptureDevice.default(for: .video)
    var sessionQueue = DispatchQueue(label: "video.preview.session")
    
    var addToPreviewStream: ((CGImage) -> Void)?
    
    var isAuthorized: Bool {
        get async {
            let status =  AVCaptureDevice.authorizationStatus(for: .video)
            var isAuthed = status == .authorized
            if status == .notDetermined {
                isAuthed = await AVCaptureDevice.requestAccess(for: .video)
            }
            
            return isAuthed
        }
    }
    
    lazy var previewStream: AsyncStream<CGImage> = {
        AsyncStream { continuation in
            addToPreviewStream = { cgImage in
                continuation.yield(cgImage)
            }
        }
    }()
    
    override init() {
        super.init()
        
        Task {
            await configureSession()
            await startSession()
        }
    }
    
    func configureSession() async {
        
    }
    
    func startSession() async {
        
    }
}

extension CMSampleBuffer {
    
    var cgImage: CGImage? {
        let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(self)
        guard let imagePixelBuffer = pixelBuffer else {
            return nil
        }
        
        return CIImage(cvPixelBuffer: imagePixelBuffer).cgImage
    }
}

extension CIImage {
    var cgImage: CGImage? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        
        return cgImage
    }
}
