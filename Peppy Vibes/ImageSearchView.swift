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
import CoreData

struct ImageSearchView: View {
    @State private var selectedImage: UIImage? = nil
    @State private var showCamera = false
    @State private var classificationResult: String = ""
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: ClothingItem.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \ClothingItem.name, ascending: true)]) var items: FetchedResults<ClothingItem>

    let imageWidth = UIScreen.main.bounds.width
    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    
    var body: some View {
        VStack {
            ZStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .cornerRadius(10)
                        .frame(width: imageWidth, height: 300)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: imageWidth, height: 300)
                        .cornerRadius(10)
                        .overlay(
                            Text("Select an Image")
                                .foregroundColor(.white)
                        )
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack {
                            Button {
                                sourceType = .camera
                                showCamera = true
                            } label: {
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                            .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
                            
                            Button {
                                sourceType = .photoLibrary
                                showCamera = true
                            } label: {
                                Image(systemName: "photo.on.rectangle")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                        }
                        .padding()
                    }
                }
            }
            
            if !classificationResult.isEmpty {
                Text("Result: \(classificationResult)")
                    .font(.headline)
                    .padding()
            }
        
            ScrollView {
                LazyVGrid(columns: columns, content: {
                    ForEach(filteredItems, id: \.self) { item in
                        ClothingItemView(item: item)
                    }
                })
                .padding()
            }
            .navigationTitle("All Products")
        }
        .sheet(isPresented: $showCamera, content: {
            ImagePickerView(image: $selectedImage, sourceType: sourceType)
                .onDisappear {
                    if let image = selectedImage {
                        classificationResult = classifyImage(image)
                    }
                }
        })
    }
    
    var filteredItems: [ClothingItem] {
        items.filter({ $0.name?.isEmpty == false })
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
