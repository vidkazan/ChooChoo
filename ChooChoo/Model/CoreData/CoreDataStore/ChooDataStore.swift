//
//  ChooDataStore.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 01.07.24.
//

import Foundation
import FcodyCoreData

class ChooDataStore : FcodyCoreDataStore {
	public static let preview = ChooDataStore(container: PersistenceController.preview.container)
	var user : CDUser? = nil
}

extension CoreDataError : ChooError {}
