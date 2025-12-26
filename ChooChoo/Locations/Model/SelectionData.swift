////
////  SelectionData.swift
////  Datify-iOS-Core
////
////  Created by Dmitrii Grigorev on 06.08.24.
////
//
//import Foundation
//
//struct SelectionData {
//	let users: [ProfileModel]
//
//    // TODO: "SelectionData->ProfileModel: color label did not set"
//    // TODO: "SelectionData->ProfileModel: birthday did not set"
//	init(selectionResponse: SelectionResponse) {
//        self.users = selectionResponse.users.map {
//            let locationString = String(
//                Measurement(
//                    value: Double($0.distance),
//                    unit: UnitLength.meters
//                )
//                .formatted(.measurement(width: .narrow))
//            )
//            return ProfileModel(
//                id: $0.id,
//                personalData: Profile(
//                    name: $0.fullName,
//                    birthday: .init(),
//                    gender: .init(rawValue: $0.genderCode) ?? .other,
//                    location: "\(locationString) away".localize(),
//                    description: $0.aboutMe ?? "",
//                    label: (DatingTarget(rawValue: $0.searchStatusCode) ?? .communication).title,
//                    colorLabel: .accentsGreen
//                ),
//                interaction: .init(
//                    liked: false,
//                    bookmarked: false,
//                    star: false
//                ),
//                mediaContent: MediaContent(
//                    visualData: Self.prepareVisual($0),
//                    audiofile: $0.voiceMessage,
//                    audioFileDuration: "-"
//                ),
//                additionalDetails: AdditionalDetails(
//                    barData: []
//                ),
//                responsePage: $0.page
//            )
//		}
//	}
//}
//
//private extension SelectionData {
//    static func prepareVisual(_ user: SelectionDTO) -> [VisualData] {
//        var visual: [VisualData] = user.photos.compactMap { photo in
//            VisualData(
//                path: photo,
//                isVideo: false,
//                data: nil
//            )
//        }
//        if let videoString = user.video {
//            visual.append(
//                VisualData(
//                    path: videoString,
//                    isVideo: true,
//                    data: nil
//                )
//            )
//        }
//        return visual
//    }
//}
