//
//  ApparelDataDecoder.swift
//  Peppy Vibes
//
//  Created by Saravanakumar Selladurai on 24/09/24.
//

import Foundation

struct ApparelData: Decodable {
    let items: [Apparel]
}

struct Apparel: Decodable {
    let category: String
    let name: String
    let label: String
    let price: String
    let size: String
    let resName: String
    let color: String
}

struct ApparelDataDecoder {
    
    static func loadJson<T: Decodable>(filename: String, as type: T.Type) -> T? {
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let apparelData = try JSONDecoder().decode(T.self, from: data)
            return apparelData
        } catch {
            return nil
        }
    }
}
