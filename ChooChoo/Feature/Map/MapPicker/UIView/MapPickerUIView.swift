//
//  MapPickerUIView.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 13.02.24.
//

import Foundation
import SwiftUI
import MapKit

struct MapPickerUIView: UIViewRepresentable {
	@ObservedObject var vm : MapPickerViewModel
	var mapCenterCoords: CLLocationCoordinate2D
	
	func makeCoordinator() -> Coordinator {
		Coordinator(parent: self)
	}

	func makeUIView(context: Context) -> MKMapView {
		let mapView = MKMapView()
		mapView.delegate = context.coordinator
		mapView.showsUserLocation = true
		mapView.isRotateEnabled = false
		let initialLocation = mapCenterCoords
		
		
		let span = MKCoordinateSpan(
			latitudeDelta: 0.01,
			longitudeDelta: 0.01
		)
		
		let region = MKCoordinateRegion(center: initialLocation, span: span)
		mapView.setRegion(region, animated: true)
		
		let gestureRecognizer = UILongPressGestureRecognizer(
			target: context.coordinator,
			action: #selector(Coordinator.handleTap(_:))
		)
		gestureRecognizer.delegate = context.coordinator
		mapView.addGestureRecognizer(gestureRecognizer)
		
		StopAnnotation.registerStopViews(mapView)
		return mapView
	}
	
	func updateUIView(_ uiView: MKMapView, context: Context) {
		
		if let selectedCoordinate = vm.state.data.selectedStop?.coordinates {
			if let annotation = uiView.annotations.first(where: { $0 is LocationAnnotation }) {
				uiView.removeAnnotation(annotation)
			}
			let annotation = LocationAnnotation()
			annotation.title = vm.state.data.selectedStop?.name
			annotation.coordinate = selectedCoordinate.cllocationcoordinates2d
			uiView.addAnnotation(annotation)
		}
		
		if uiView.region.span.longitudeDelta > 0.02 {
			uiView.removeAnnotations(uiView.annotations.filter {
				$0.isKind(of: StopAnnotation.self)
			})
		} else {
			vm.state.data.stops.forEach({ stop in
				if uiView.annotations.first(
					where: {$0.coordinate == stop.coordinates.cllocationcoordinates2d}) == nil,
				   let lineType = stop.stopDTO?.products?.lineType
				{
					MapPickerViewModel.addStopAnnotation(
						id: stop.id,
						lineType: lineType,
						stopName: stop.name,
						coords: stop.coordinates.cllocationcoordinates2d,
						mapView: uiView,
						stopOverType: nil
					)
				}
			})
		}
	}
}


#if DEBUG
struct MapPickerUIViewPreview: PreviewProvider {
	static var previews: some View {
		MapPickerView(
			vm: .init(
				.loadingNearbyStops(.init(
						center: .init(latitude: 51.2, longitude: 6.685),
						latitudinalMeters: 0.02,
						longitudinalMeters: 0.02
					)
				)
			),
			initialCoords: .init(
				latitude: 51.2,
				longitude: 6.685
			),
			type: .departure
		)
	}
}
#endif
