//
//  AppState.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 29.08.25.
//

import Foundation



public protocol AppStateProtocol {}

public protocol AppActionProtocol {}

public protocol AppStoreProtocol: ObservableObject {
    associatedtype S: AppStateProtocol

    var state: S { get }

    func dispatch(_ action: AppActionProtocol)
}

public protocol AppReducerProtocol {
    associatedtype S: AppStateProtocol

    func reduce(state: S, action: AppActionProtocol) -> S
}

struct AppState: AppStateProtocol {
}
