import Foundation

extension Date {
    var mediumDate: String {
        formatted(date: .abbreviated, time: .omitted)
    }

    var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: .now)
    }
}
