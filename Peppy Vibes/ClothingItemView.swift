//
//  ClothingItemView.swift
//  Peppy Vibes
//
//  Created by Saravanakumar Selladurai on 13/09/24.
//

import SwiftUI

struct ClothingItemView: View {
    var item: ClothingItem
    
    var body: some View {
        VStack {
            if let imageData = item.image,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 150)
                    .background(Color.gray)
                    .cornerRadius(8)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 100, height: 150)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading) {
                Text(item.name ?? "Unknown")
                    .font(.headline)
//                Text(String(format: "₹%.2f", item.price ?? 50))
                Text(String(format: "₹%@", item.price ?? 50))
                    .font(.subheadline)
            }
        }
        .padding(8)
    }
}
