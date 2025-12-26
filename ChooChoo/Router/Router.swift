//
//  Router.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 29.08.25.
//

import Foundation
import SwiftUI

final class Router<T: Hashable>: ObservableObject {
    @Published var paths: [T] = []

    func push(_ path: T) {
        Task { @MainActor in
            guard paths.last != path else { return }
            paths.append(path)
        }
    }

    func pop() {
        Task { @MainActor in
            paths.removeLast(1)
        }
    }

    func pop(to: T) {
        Task { @MainActor in
            guard let found = paths.firstIndex(where: { $0 == to }) else { return }
            let numToPop = (found ..< paths.endIndex).count - 1
            paths.removeLast(numToPop)
        }
    }

    func popToRoot() {
        Task { @MainActor in
            paths.removeAll()
        }
    }
}
