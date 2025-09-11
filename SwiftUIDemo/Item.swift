//
//  Item.swift
//  SwiftUIDemo
//
//  Created by LLLRNSTB on 2025/9/11.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
