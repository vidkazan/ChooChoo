//
//  MapDetailsUIView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 22.02.24.
//

import Foundation

import SwiftUI
import OrderedCollections
import MapKit

struct MapDetailsUIView: UIViewRepresentable {
	let legs : OrderedSet<MapLegData>
	let region: MKCoordinateRegion
	
	func makeUIView(context: Context) -> MKMapView {
		let mapView = MKMapView()
		mapView.delegate = context.coordinator
		mapView.region = region
		mapView.showsUserLocation = true
		mapView.isZoomEnabled = true
		mapView.isUserInteractionEnabled = true
		mapView.pointOfInterestFilter = .includingAll
		
		
		legs.forEach({ leg in
//			#warning("vehicle locaiton: for test")
//			#if DEBUG
//			let anno = VehicleLocationAnnotation(
//				location: leg.currenLocation?.cllocationcoordinates2d ?? .init(),
//				type: leg.lineType
//			)
//			mapView.addAnnotation(anno)
//			#endif
			
			leg.stops.forEach { stop in
				MapPickerViewModel.addStopAnnotation(
					id: stop.id,
					lineType: leg.lineType,
					stopName: stop.name,
					coords: stop.locationCoordinates.cllocationcoordinates2d,
					mapView: mapView,
					stopOverType: stop.stopOverType
				)
			}
			
			if let route = leg.route {
				if leg.type != .line {
					route.title = "foot"
				}
				mapView.addOverlay(route, level: .aboveRoads)
			}
		})
		
		StopAnnotation.registerStopViews(mapView)
		return mapView
	}
	
	func updateUIView(_ view: MKMapView, context: Context) {}

	func makeCoordinator() -> Coordinator {
		Coordinator()
	}
}

extension MapDetailsUIView {
	class Coordinator: NSObject, MKMapViewDelegate {
		func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay
		) -> MKOverlayRenderer {
			if overlay is MKPolyline {
				if overlay.title == "foot" {
					return ChooFootPolylineRenderer(overlay: overlay)
				}
				return ChooPolylineRenderer(overlay: overlay)
			}
			return MKOverlayRenderer()
		}
		
		func mapView(_ mapView: MKMapView,viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//			#warning("check actual locaiton with API given locaiton")
			if let anno = annotation as? VehicleLocationAnnotation {
				return MKMarkerAnnotationView(annotation: anno, reuseIdentifier: "anno")
			}
			let view = MapPickerViewModel.mapView(mapView, viewFor: annotation)
			if let anno = annotation as? StopAnnotation {
				switch anno.stopOverType {
				case .origin,.destination:
					view?.displayPriority = .required
					view?.zPriority = .defaultUnselected
				case .transfer:
					view?.displayPriority = .required
					view?.zPriority = .max
				case .stopover:
					view?.displayPriority = MKFeatureDisplayPriority(0)
					view?.zPriority = .min
				default:
					view?.displayPriority = MKFeatureDisplayPriority(1)
					view?.zPriority = .min
				}
			}
			return view
		}
	}
}

class ChooPolylineRenderer : MKPolylineRenderer {
	override init(overlay: MKOverlay) {
		super.init(overlay: overlay)
		self.lineWidth = 7
		self.miterLimit = 1
		self.lineJoin = .round
		self.lineCap = .round
		self.strokeColor = UIColor(Color.chewFillYellowPrimary)
	}
}

class ChooFootPolylineRenderer : ChooPolylineRenderer {
	override init(overlay: MKOverlay) {
		super.init(overlay: overlay)
		self.lineDashPattern = [1,10]
	}
}
