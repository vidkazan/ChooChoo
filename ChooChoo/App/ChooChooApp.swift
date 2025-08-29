 //
//  Chew_chew_SwiftUIApp.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 23.08.23.
//

import SwiftUI
import CoreData
import TipKit

@main
struct ChooChooApp: App {
    let container: AppContainer = AppContainerImpl.shared
	let chewViewModel = ChewViewModel(
        referenceDate: .now,
        coreDataStore: Model.shared.coreDataStore
    )
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(chewViewModel)
		}
	}
}

