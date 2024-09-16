//
//  Peppy_VibesApp.swift
//  Peppy Vibes
//
//  Created by Saravanakumar Selladurai on 13/09/24.
//

import SwiftUI

@main
struct Peppy_VibesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ClothingListView()
//            AddClothingItemView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
