//
//  SheetViewModel+SheetType.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 13.07.24.
//

import Foundation

extension SheetViewModel {
	enum SheetType : Equatable {
		static func == (lhs: SheetViewModel.SheetType, rhs: SheetViewModel.SheetType) -> Bool {
			lhs.description == rhs.description
		}
		
		case none
		case tip(ChooTip)
		case date
		case appSettings
		case journeySettings
		case route(leg : LegViewData)
		case mapDetails(_ request : MapDetailsRequest)
		case mapPicker(type : LocationDirectionType)
		case onboarding
		case remark(remarks : [RemarkViewData])
		case journeyDebug(legs : [LegDTO])
		case alternatives(for: JourneyDetailsViewModel)
		
		var detents : [ChewPresentationDetent] {
			switch self {
			case .tip:
				return [.height(200)]
			case .mapPicker:
				return [.large]
			case .none:
				return []
			case .date:
				return [.large]
			case .journeySettings:
				return [.medium,.large]
			case .appSettings:
				return [.medium,.large]
			case .route:
				return [.medium,.large]
			case .mapDetails:
				return [.large]
			case .onboarding:
				return [.large]
			case .remark:
				return [.medium,.large]
			case .journeyDebug:
				return [.medium,.large]
			case .alternatives:
				return [.large]
			}
		}
		
		var description : String {
			switch self {
			case .alternatives:
				return NSLocalizedString("Alternatives", comment: "SheetViewModel: SheetType")
			case .tip:
				return NSLocalizedString("Tip", comment: "SheetViewModel: SheetType")
			case .mapPicker:
				return NSLocalizedString("Map picker", comment: "SheetViewModel: SheetType")
			case .none:
				return ""
			case .date:
				return NSLocalizedString("Date", comment: "SheetViewModel: SheetType")
			case .appSettings:
				return NSLocalizedString("App Settings", comment: "SheetViewModel: SheetType")
			case .journeySettings:
				return NSLocalizedString("Journey Settings", comment: "SheetViewModel: SheetType")
			case .route:
				return NSLocalizedString("Route", comment: "SheetViewModel: SheetType")
			case .mapDetails:
				return NSLocalizedString("Map Details", comment: "SheetViewModel: SheetType")
			case .onboarding:
				return NSLocalizedString("Onboarding", comment: "SheetViewModel: SheetType")
			case .remark:
				return NSLocalizedString("Remarks", comment: "SheetViewModel: SheetType")
			case .journeyDebug:
				return NSLocalizedString("Journey Debug", comment: "SheetViewModel: SheetType")
			}
		}
		
		var dataSourceType : any SheetViewDataSource.Type {
			switch self {
			case .alternatives:
				return JourneyAlternativesViewDataSource.self
			case .tip:
				return InfoDataSource.self
			case .none:
				return EmptyDataSource.self
			case .mapPicker:
				return MapPickerViewDataSource.self
			case .date:
				return DatePickerViewDataSource.self
			case .appSettings:
				return AppSettingsViewDataSource.self
			case .journeySettings:
				return JourneySettingsViewDataSource.self
			case .route:
				return RouteViewDataSource.self
			case .mapDetails:
				return MapDetailsViewDataSource.self
			case .onboarding:
				return OnboardingViewDataSource.self
			case .remark:
				return RemarksViewDataSource.self
			case .journeyDebug:
				return JourneyDebugViewDataSource.self
			}
		}
	}
}
