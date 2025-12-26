//
//  AppState.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 29.08.25.
//

import Foundation



protocol AppStateProtocol {}

protocol AppActionProtocol {}

protocol AppStoreProtocol: ObservableObject {
    associatedtype S: AppStateProtocol

    var state: S { get }

    func dispatch(_ action: AppActionProtocol)
}

protocol AppReducerProtocol {
    associatedtype S: AppStateProtocol

    func reduce(state: S, action: AppActionProtocol) -> S
}

struct AppState: AppStateProtocol {
}
