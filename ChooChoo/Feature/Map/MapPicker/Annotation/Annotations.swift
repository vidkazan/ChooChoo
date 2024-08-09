//
//  Annotations.swift
//  Chew-chew-SwiftUI
//
//  Created by Dmitrii Grigorev on 13.02.24.
//

import Foundation
import CoreLocation
import MapKit

protocol ChewStopAnnotaion {
	var stopOverType : StopOverType? { get }
	var stopId : String? { get }
	var name: String { get }
	var location: CLLocationCoordinate2D { get }
	var type : LineType { get }
	var reuseIdentifier : String { get }
	init(stopId: String?, name: String, location: CLLocationCoordinate2D, type: LineType,stopOverType : StopOverType?)
}

class LocationAnnotation : MKPointAnnotation {}

class VehicleLocationAnnotation : MKPointAnnotation {
	let type : LineType
	init(location: CLLocationCoordinate2D, type: LineType) {
		self.type = type
		super.init()
		self.coordinate = location
		self.title = type.rawValue
	}
}

class StopAnnotation: NSObject, Identifiable, ChewStopAnnotaion {
	let stopOverType : StopOverType?
	let stopId : String?
	let name: String
	let location: CLLocationCoordinate2D
	let type : LineType
	let reuseIdentifier : String
	
	required init(stopId: String?, name: String, location: CLLocationCoordinate2D, type: LineType,stopOverType : StopOverType?) {
		self.stopOverType = stopOverType
		self.stopId = stopId
		self.name = name
		self.location = location
		self.type = type
		self.reuseIdentifier = type.rawValue
	}
}

extension StopAnnotation : MKAnnotation {
	var coordinate: CLLocationCoordinate2D {
		location
	}
	var title: String? {
		name
	}
}

class BusStopAnnotation : StopAnnotation {}
class ReplacementBusStopAnnotation : StopAnnotation {}
class IceStopAnnotation : StopAnnotation {}
class ReStopAnnotation : StopAnnotation {}
class SStopAnnotation : StopAnnotation {}
class UStopAnnotation : StopAnnotation {}
class TramStopAnnotation : StopAnnotation {}
class ShipStopAnnotation : StopAnnotation {}
class TaxiStopAnnotation : StopAnnotation {}
class FootStopAnnotation : StopAnnotation {}
class TransferStopAnnotation : StopAnnotation {}


extension StopAnnotation {
	static func registerStopViews(_ mapView : MKMapView){
		mapView.register(ReplacementBusStopAnnotation.self,
					forAnnotationViewWithReuseIdentifier: NSStringFromClass(BusStopAnnotation.self))
		mapView.register(BusStopAnnotationView.self,
					forAnnotationViewWithReuseIdentifier: NSStringFromClass(BusStopAnnotation.self))
		mapView.register(IceStopAnnotationView.self,
					forAnnotationViewWithReuseIdentifier: NSStringFromClass(IceStopAnnotation.self))
		mapView.register(ReStopAnnotationView.self,
					forAnnotationViewWithReuseIdentifier: NSStringFromClass(ReStopAnnotation.self))
		mapView.register(SStopAnnotationView.self,
					forAnnotationViewWithReuseIdentifier: NSStringFromClass(SStopAnnotation.self))
		mapView.register(UStopAnnotationView.self,
					forAnnotationViewWithReuseIdentifier: NSStringFromClass(UStopAnnotation.self))
		mapView.register(TramStopAnnotationView.self,
					forAnnotationViewWithReuseIdentifier: NSStringFromClass(TramStopAnnotation.self))
		mapView.register(ShipStopAnnotationView.self,
					forAnnotationViewWithReuseIdentifier: NSStringFromClass(ShipStopAnnotation.self))
		mapView.register(TaxiStopAnnotationView.self,
					forAnnotationViewWithReuseIdentifier: NSStringFromClass(TaxiStopAnnotation.self))
		mapView.register(FootStopAnnotationView.self,
					forAnnotationViewWithReuseIdentifier: NSStringFromClass(FootStopAnnotation.self))
		mapView.register(TransferStopAnnotationView.self,
					forAnnotationViewWithReuseIdentifier: NSStringFromClass(TransferStopAnnotation.self))

	}
}
