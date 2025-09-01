//
//  AppStore.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 29.08.25.
//

import Foundation

typealias ChooStore = AppStore<AppState, AppReducer>

open class AppStore<AppState, AppReducer>: AppStoreProtocol where AppReducer: AppReducerProtocol, AppReducer.S == AppState {
    @Published public private(set) var state: AppState

    private let reducer: AppReducer

    init(initialState: AppState, reducer: AppReducer) {
        self.state = initialState
        self.reducer = reducer
    }

    public func dispatch(_ action: AppActionProtocol) {
        Task { @MainActor in
            state = reducer.reduce(state: state, action: action)
        }
    }
}
