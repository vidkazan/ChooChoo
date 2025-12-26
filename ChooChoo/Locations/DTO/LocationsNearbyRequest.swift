//
//  SelectionRequest.swift
//  Datify-iOS-Core
//
//  Created by Dmitrii Grigorev on 05.08.24.
//

import Foundation

struct SelectionRequest: Encodable {
    let page: Int
    let orientation: [Int]
    let searchStatus: [Int]
    let minAge: Int
    let maxAge: Int
}
