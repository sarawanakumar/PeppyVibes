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
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 100, height: 100)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading) {
                Text(item.name ?? "Unknown")
                    .font(.headline)
                Text(String(format: "₹%.2f", item.price ?? 50))
                    .font(.subheadline)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

//#Preview {
//    ClothingItemView()
//}
