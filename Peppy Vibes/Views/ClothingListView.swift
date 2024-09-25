//
//  ClothingListView.swift
//  Peppy Vibes
//
//  Created by Saravanakumar Selladurai on 13/09/24.
//

import SwiftUI
import CoreData

struct ClothingListView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: ClothingItem.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \ClothingItem.name, ascending: true)]) var items: FetchedResults<ClothingItem>
    
    @State private var searchText = ""
    @State private var selectedSize = "All"
    @State private var shakeDetected: Bool = false
    @State private var presentingModal: Bool = false
    var shouldPerformInsert = false
    
    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Search", text: $searchText)
                        .padding(EdgeInsets.init(top: 8, leading: 8, bottom: 8, trailing: 8))
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .contentMargins(16)
                    
                    NavigationLink(destination: ImageSearchView()) {
                        Image(systemName: "camera.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32, alignment: .center)
                    }
                }
                
                Picker("Size", selection: $selectedSize) {
                    Text("All").tag("all")
                    Text("S").tag("s")
                    Text("M").tag("m")
                    Text("L").tag("l")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                ScrollView {
                    LazyVGrid(columns: columns, content: {
                        ForEach(filteredItems, id: \.self) { item in
                            ClothingItemView(item: item)
                        }
                    })
                }
                .navigationTitle("All Products")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            self.insertStaticData()
                        } label: {
                            Image(systemName: "plus")
                        }

                    }
                }
            }
            .padding(8)
        }
        .background(content: {
            ShakeDetectorView {
                self.presentingModal = true
                shakeDetected.toggle()
            }
            .sheet(isPresented: self.$presentingModal, content: {
                AddClothingItemView(presentedAsModal: self.$presentingModal)
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            })
        })
    }
    
    private func insertStaticData() {
        guard let data = ApparelDataDecoder.loadJson(filename: "apparel-data", as: ApparelData.self) else {
            return
        }
        performBackgroundInsert(withData: data)
    }
    
    var filteredItems: [ClothingItem] {
        let filtered =  items.filter { item in
            (selectedSize == "All" || item.size == selectedSize) && (searchText.isEmpty || item.name?.lowercased().contains(searchText.lowercased()) == true)
        }
        return filtered
    }
    
    func performBackgroundInsert(withData d: ApparelData) {
        PersistenceController.shared.container.performBackgroundTask { context in
            for data in d.items {
                let clothingItemEntity = ClothingItem(context: context)
                clothingItemEntity.name = data.name
                clothingItemEntity.category = data.category
                clothingItemEntity.color = data.color
                clothingItemEntity.price = NSDecimalNumber(string: data.price)
                clothingItemEntity.size = data.size
                clothingItemEntity.label = data.label
                
                if let selectedImage = UIImage(named: data.resName) {
//                    newItem.image = selectedImage.jpegData(compressionQuality: 0.8)
                    clothingItemEntity.image = selectedImage.jpegData(compressionQuality: 0.8)
                }
                
                try? context.save()
            }
            
        }
    }
}

#Preview {
    ClothingListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
