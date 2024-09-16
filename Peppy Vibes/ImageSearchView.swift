//
//  ImageSearchView.swift
//  Peppy Vibes
//
//  Created by Saravanakumar Selladurai on 15/09/24.
//

import SwiftUI
import CoreML
import Vision
import UIKit

struct ImageSearchView: View {
    @State private var selectedImage: UIImage? = nil
    @State private var showCamera = false
    @State private var classificationResult: String = ""
    
    var body: some View {
        VStack(content: {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            } else {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 200, height: 200, alignment: .center)
            }
            
            Button("Open Camera") {
                showCamera = true
            }
            .padding()
            
            if !classificationResult.isEmpty {
                Text("Result: \(classificationResult)")
                    .font(.headline)
                    .padding()
            }
        })
        .sheet(isPresented: $showCamera, content: {
            CameraView(image: $selectedImage)
                .onDisappear {
                    if let image = selectedImage {
                        classifyImage(image)
                    }
                }
        })
    }
}

#Preview {
    ImageSearchView()
}

func classifyImage(_ image: UIImage) -> String {
    
    // Resize the image
    let modelSize = 360
    let pixelBuffer = image
        .resized(to: .init(width: modelSize, height: modelSize))
        .toCVPixelBuffer()
    
    // Convert to CVPixelBuffer
    
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    
    let classifierModel = try? ClothingImageClassifier(configuration: .init())
    do {
        guard let prediction = try classifierModel?.prediction(image: pixelBuffer!) else { return "" }
        return prediction.target
    } catch {
        print(error)
    }
    return ""
}

extension UIImage {
    
    func resized(to size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: .init(origin: .zero, size: size))
        }
    }
    
    func toCVPixelBuffer() -> CVPixelBuffer? {
        
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        let width = Int(size.width)
        let height = Int(size.height)
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32ARGB,
            attrs,
            &pixelBuffer
        )
        
        guard (status == kCVReturnSuccess) else { return nil}
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )
        
        context?.translateBy(x: 0, y: size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        draw(in: .init(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        return pixelBuffer!
    }
}
