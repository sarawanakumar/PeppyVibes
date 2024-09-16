//
//  AddClothingItemView.swift
//  Peppy Vibes
//
//  Created by Saravanakumar Selladurai on 13/09/24.
//

import SwiftUI

struct AddClothingItemView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var name: String = ""
    @State private var price: String = ""
    @State private var selectedSize: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @Binding var presentedAsModal: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    self.presentedAsModal = false
                } label: {
                    Image(systemName: "xmark.circle")
                }

            }
            TextField("Item Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Price", text: $price)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                showImagePicker.toggle()
            }, label: {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .contrast(10)
                } else {
                    Text("Select Image")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            })
            .padding()
            
            Button("Save Item") {
                let newItem = ClothingItem(context: viewContext)
                newItem.name = name
                newItem.price = NSDecimalNumber(string: price)
                newItem.size = selectedSize
                
                if let selectedImage = selectedImage {
                    newItem.image = selectedImage.jpegData(compressionQuality: 0.8)
                }
                
                try? viewContext.save()
            }
            .padding()
        }
        .sheet(isPresented: $showImagePicker, content: {
            ImagePickerView(image: $selectedImage)
        })
    }
}

#Preview {
    AddClothingItemView(presentedAsModal: .constant(false))
}
