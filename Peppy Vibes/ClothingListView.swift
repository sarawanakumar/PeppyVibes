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
                    .padding()
                }
                .navigationTitle("All Products")
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
    
    var filteredItems: [ClothingItem] {
        let filtered =  items.filter { item in
            (selectedSize == "All" || item.size == selectedSize) && (searchText.isEmpty || item.name?.lowercased().contains(searchText.lowercased()) == true)
        }
        return filtered
    }
}

#Preview {
    ClothingListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
