//
//  Struct.swift
//  DogApp
//
//  Created by spark-03 on 2024/06/07.
//

import Foundation

struct DogBreed: Codable {
    let message: [String: [String]]
}

struct DogImage: Codable {
    let message: [String]
}
