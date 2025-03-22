import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), birthDate: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), birthDate: UserDefaults(suiteName: "group.com.example.AgeCalculator")?.object(forKey: "birthDate") as? Date)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let birthDate = UserDefaults(suiteName: "group.com.example.AgeCalculator")?.object(forKey: "birthDate") as? Date
        
        // Update once per day at midnight
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        let midnight = calendar.startOfDay(for: tomorrow)
        
        let entry = SimpleEntry(date: currentDate, birthDate: birthDate)
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let birthDate: Date?
}

struct AgeCalculatorWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        if let birthDate = entry.birthDate {
            let ageInfo = calculateAgeAndNextBirthday(from: birthDate)
            VStack(spacing: 8) {
                Text("Current Age")
                    .font(.headline)
                
                Text("\(ageInfo.years)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("years old")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Divider()
                    .padding(.vertical, 4)
                
                Text("Next Birthday")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if ageInfo.daysUntilBirthday == 0 {
                    Text("Today! 🎉")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                } else {
                    Text("\(ageInfo.daysUntilBirthday) days")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                }
                
                if ageInfo.monthsUntilBirthday > 0 {
                    Text("(\(ageInfo.monthsUntilBirthday) months)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        } else {
            VStack {
                Text("Age Calculator")
                    .font(.headline)
                
                Spacer()
                
                Text("Set your birth date in the app")
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
        }
    }
    
    func calculateAgeAndNextBirthday(from birthDate: Date) -> (years: Int, daysUntilBirthday: Int, monthsUntilBirthday: Int) {
        let calendar = Calendar.current
        let now = Date()
        
        // Calculate current age in years
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
        let years = ageComponents.year ?? 0
        
        // Calculate next birthday
        let birthdayMonth = calendar.component(.month, from: birthDate)
        let birthdayDay = calendar.component(.day, from: birthDate)
        let currentYear = calendar.component(.year, from: now)
        
        // Create date for this year's birthday
        var nextBirthdayComponents = DateComponents()
        nextBirthdayComponents.year = currentYear
        nextBirthdayComponents.month = birthdayMonth
        nextBirthdayComponents.day = birthdayDay
        
        guard let thisYearBirthday = calendar.date(from: nextBirthdayComponents) else {
            return (years, 0, 0)
        }
        
        // If this year's birthday has passed, use next year's birthday
        var nextBirthday = thisYearBirthday
        if thisYearBirthday < now {
            nextBirthdayComponents.year = currentYear + 1
            if let nextYearBirthday = calendar.date(from: nextBirthdayComponents) {
                nextBirthday = nextYearBirthday
            }
        }
        
        // Calculate time until next birthday
        let untilBirthdayComponents = calendar.dateComponents([.month, .day], from: now, to: nextBirthday)
        let daysUntilBirthday = untilBirthdayComponents.day ?? 0
        let monthsUntilBirthday = untilBirthdayComponents.month ?? 0
        
        return (years, daysUntilBirthday, monthsUntilBirthday)
    }
}

struct AgeCalculatorWidget: Widget {
    let kind: String = "AgeCalculatorWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            AgeCalculatorWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Age Calculator")
        .description("Shows your current age and days until your next birthday.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct AgeCalculatorWidget_Previews: PreviewProvider {
    static var previews: some View {
        let calendar = Calendar.current
        let pastDate = calendar.date(byAdding: .year, value: -30, to: Date())!
        
        AgeCalculatorWidgetEntryView(entry: SimpleEntry(date: Date(), birthDate: pastDate))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        AgeCalculatorWidgetEntryView(entry: SimpleEntry(date: Date(), birthDate: nil))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

