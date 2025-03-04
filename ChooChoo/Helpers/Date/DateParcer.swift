//
//  DateParcer.swift
//  49EuroTravel
//
//  Created by Dmitrii Grigorev on 05.05.23.
//

import Foundation

// TODO: tests
class DateParcer {
    enum ChooDuration {
        case mins
        case hoursAndMins
        case hours
        case daysAndHours
        case days
        case months
        case years
        
        var durationFormatter : DateComponentsFormatter {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .short
            switch self {
                case .mins:
                    formatter.allowedUnits = [.minute]
                case .hoursAndMins:
                    formatter.allowedUnits = [.hour, .minute]
                case .hours:
                    formatter.allowedUnits = [.hour]
                case .daysAndHours:
                    formatter.allowedUnits = [.day,.hour]
                case .days:
                    formatter.allowedUnits = [.day]
                case .months:
                    formatter.allowedUnits = [.month]
                case .years:
                    formatter.allowedUnits = [.year]
            }
            return formatter
        }
        
        func timeOffsetString(minutes : Int) -> String? {
            self.durationFormatter.string(from: Double(minutes * 60))
        }
    }
    
	private static let durationFormatter : DateComponentsFormatter = {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .short
		formatter.allowedUnits = [.day, .hour, .minute]
	 return formatter
	}()
	
	static private let formatDateAndTime = "yyyyMMdd'T'HHmmssZ"
	
	static private let dateFormatter : DateFormatter = {
		let f = DateFormatter()
		f.dateFormat = formatDateAndTime
		return f
	}()
	
	static private let ISOdateFormatter : ISO8601DateFormatter = {
		let f = ISO8601DateFormatter()
		return f
	}()
	
	static private func parseDate(from dateString : String?) -> Date? {
		guard var dateString = dateString else { return nil }
        if dateString.last != "Z" {
            dateString += "Z"
        }
        if let date = dateFormatter.date(from: dateString) {
            return date
        }
		guard let date = ISOdateFormatter.date(from: dateString) else { return nil }
		return date
	}
	
	static func getTwoDateIntervalInMinutes(date1 : Date,date2 : Date) -> Int {
		let interval = date2.timeIntervalSinceReferenceDate - date1.timeIntervalSinceReferenceDate
		return Int((interval / 60))
	}
	
	static func getTwoDateIntervalInMinutes(date1 : Date?,date2 : Date?) -> Int? {
		guard let date1 = date1,
			  let date2 = date2 else { return nil }
		return getTwoDateIntervalInMinutes(date1: date1, date2: date2)
	}
	
	static func getTwoDateInterval(date1 : Date?,date2 : Date?) -> Double? {
		guard let date1 = date1,
			  let date2 = date2 else { return nil }
		let interval = date1.timeIntervalSinceReferenceDate - date2.timeIntervalSinceReferenceDate
		return interval
	}
	
	static func getDateFromDateString(dateString : String?) -> Date? {
		return parseDate(from: dateString)
	}
	static func getStringFromDate(date : Date) -> String? {
		return dateFormatter.string(from: date)
	}
	
	static func getDateMinusMonthsAgo(monthsAgo : Int) -> Date? {
		let currentDate = Date()
		let calendar = Calendar.current
		var dateComponents = DateComponents()
		dateComponents.month = -monthsAgo
		let newDate = calendar.date(byAdding: dateComponents, to: currentDate)
		return newDate
	}
	
	static func getTimeStringFromDate(date : Date?) -> String? {
		guard let date = date else { return nil }
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm"
		let timeString = dateFormatter.string(from: date)
		return timeString
	}
	
	static func getTimeAndDateStringFromDate(date : Date, withYear : Bool = false) -> String {
		let dateFormatter = DateFormatter()
		switch withYear {
		case true:
			dateFormatter.dateFormat = "dd MMM YYYY HH:mm"
		case false:
			dateFormatter.dateFormat = "dd MMM HH:mm"
		}
		
		let timeString = dateFormatter.string(from: date)
		return timeString
	}
	
	static func getDateOnlyStringFromDate(date : Date?) -> String? {
		guard let date = date else { return nil }
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd MMM YYYY"
		let timeString = dateFormatter.string(from: date)
		return timeString
	}
	
	static func timeDuration(_ minutes : Int) -> String? {
        let string = { 
            switch abs(minutes) {
            case 0..<59:
                return DateParcer.ChooDuration.mins.timeOffsetString(minutes: minutes)
            case 60..<60*24:
                return DateParcer.ChooDuration.hoursAndMins.timeOffsetString(minutes: minutes)
            case 60*24..<60*24*3:
                return DateParcer.ChooDuration.daysAndHours.timeOffsetString(minutes: minutes)
            case 60*24*3..<60*24*45:
                return DateParcer.ChooDuration.days.timeOffsetString(minutes: minutes)
            case 60*24*45..<60*24*365:
                return DateParcer.ChooDuration.months.timeOffsetString(minutes: minutes)
            case 60*24*365..<Int.max:
                return DateParcer.ChooDuration.years.timeOffsetString(minutes: minutes)
            default:
                return nil
            }
        }()
        return string?
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: " ")
			
	}
	
	static func getCombinedDate(date: Date, time: Date) -> Date? {
		let timeComponents: DateComponents = Calendar.current.dateComponents([.hour,.minute,.second,.timeZone], from: time)
		let dateComponents: DateComponents = Calendar.current.dateComponents([.year,.month,.day], from: date)
		let combined = DateComponents(
			calendar: .current,
			timeZone: timeComponents.timeZone,
			year: dateComponents.year,
			month: dateComponents.month,
			day: dateComponents.day,
			hour: timeComponents.hour,
			minute: timeComponents.minute,
			second: timeComponents.second
		)
		
		return Calendar.current.date(from: combined)
	}
	
	static func getDaysIncludedInRange(
		startDateUnnormalised: Date,
		endDateUnnormalised: Date
	) -> [Date] {
		guard let startDate = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: startDateUnnormalised),
			  let endDate = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: endDateUnnormalised) else { return [] }
		
		var currentDate = startDate
		var allDays: [Date] = []
		
		let calendar = Calendar.current
		
		while currentDate <= endDate {
			allDays.append(currentDate)
			guard let newCurrDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { return [] }
			currentDate = newCurrDate
		}
		return allDays
	}
    
    static func timeOffsetString(_ refTime : Date,chewDate : ChewDate = .now) -> String? {
        let min = DateParcer.getTwoDateIntervalInMinutes(
            date1: chewDate.date,
            date2: refTime
        )
        return Self.timeOffsetString(min)
    }
    
    static func timeOffsetString(_ minutes : Int) -> String? {
        switch minutes {
        case 0..<1:
            return NSLocalizedString("now", comment: "DateParcer.timeOffsetString")
        case 1...Int.max:
            if let dur = DateParcer.timeDuration(minutes) {
                return NSLocalizedString("in \(dur)", comment: "DateParcer.timeOffsetString")
            }
        case Int.min..<0:
            if let dur = DateParcer.timeDuration(abs(minutes)) {
                return NSLocalizedString("\(dur) ago", comment: "DateParcer.timeOffsetString")
            }
        default:
            break
        }
        return nil
    }
}

