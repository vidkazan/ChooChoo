//
//  AppContainer.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 29.08.25.
//

import Foundation

protocol AppContainer {
    var locationsRepository: LocationsRepository { get }
    var store: ChooStore { get }
}

final class AppContainerImpl: AppContainer {
    static let shared = AppContainerImpl()
    
    @Inject(
        repo: {
            LocationsRepositoryImpl(
                locationsEndpoint: LocationsEndpointImpl()
            )
        }
    )
    var locationsRepository: LocationsRepository

    
    lazy var store = AppStore(
        initialState: AppState(),
        reducer: AppReducer()
    )
    private lazy var repositories: [String: Any] = [:]

    init() {}

    fileprivate func getRepository<T>(createRepository: @escaping () -> T) -> T {
        let key = String(describing: T.self)
        if let repo = repositories[key],
           let returnRepo = repo as? T {
            return returnRepo
        } else {
            repositories[key] = createRepository()
            return repositories[key] as! T
        }
    }
}

@propertyWrapper
struct Inject<T> {
    let repo: () -> T

    var wrappedValue: T { AppContainerImpl.shared.getRepository(createRepository: repo) }
    var projectedValue: () -> T { repo }
}

private extension LocationsRepositoryImpl {
    static func create(
        container: AppContainer = AppContainerImpl.shared,
        locationsEndpoint: LocationsEndpoint = LocationsEndpointImpl()
    ) -> LocationsRepositoryImpl {
        LocationsRepositoryImpl(
            locationsEndpoint: locationsEndpoint
        )
    }
}
