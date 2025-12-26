//
//  Inject.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 26.12.25.
//

import Foundation

@propertyWrapper
struct Inject<T> {
    let repo: () -> T

    var wrappedValue: T { AppContainerImpl.shared.getRepository(createRepository: repo) }
    var projectedValue: () -> T { repo }
}
