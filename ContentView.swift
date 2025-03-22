import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = AgeCalculatorViewModel()
    @State private var isHovering = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom title bar
            HStack {
                Text("Age Calculator")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    appState.toggleWidget()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                .buttonStyle(PlainButtonStyle())
                .help("Hide Widget (⌘⌥W)")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.8))
            .onHover { hovering in
                isHovering = hovering
            }
            
            // Main content
            ZStack {
                Color.black
                
                VStack(spacing: 20) {
                    // Date input section
                    VStack(spacing: 8) {
                        Text("Date of Birth (MM/DD/YYYY)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        
                        HStack {
                            TextField("MM/DD/YYYY", text: $viewModel.dateInput)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .foregroundColor(.white)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                                .onChange(of: viewModel.dateInput) { _ in
                                    viewModel.validateAndUpdateDate()
                                }
                            
                            Button(action: {
                                viewModel.showDatePicker.toggle()
                            }) {
                                Image(systemName: "calendar")
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                        }
                        
                        if viewModel.showDatePicker {
                            DatePicker(
                                "",
                                selection: $viewModel.selectedDate,
                                in: ...Date(),
                                displayedComponents: .date
                            )
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .labelsHidden()
                            .onChange(of: viewModel.selectedDate) { _ in
                                viewModel.updateDateInputFromSelection()
                                viewModel.showDatePicker = false
                            }
                            .frame(height: 240)
                        }
                    }
                    .padding(.horizontal)
                    
                    if !viewModel.showDatePicker {
                        // Age display
                        VStack(spacing: 4) {
                            Text("Current Age")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                            
                            HStack {
                                Text("\(viewModel.age)")
                                    .font(.system(size: 42, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Button(action: {
                                    viewModel.copyAgeToClipboard()
                                }) {
                                    Image(systemName: viewModel.isCopied ? "checkmark.circle.fill" : "doc.on.doc")
                                        .foregroundColor(viewModel.isCopied ? .green : .white)
                                        .font(.system(size: 16))
                                }
                                .buttonStyle(PlainButtonStyle())
                                .help("Copy age to clipboard")
                            }
                            
                            Text("years old")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        
                        // Next birthday display
                        VStack(spacing: 4) {
                            Text("Next Birthday")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                            
                            if viewModel.isBirthday {
                                Text("Today! 🎉")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.green)
                            } else {
                                HStack(spacing: 20) {
                                    if viewModel.monthsUntilBirthday > 0 {
                                        VStack {
                                            Text("\(viewModel.monthsUntilBirthday)")
                                                .font(.system(size: 28, weight: .bold))
                                                .foregroundColor(.white)
                                            Text("months")
                                                .font(.system(size: 12))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    
                                    VStack {
                                        Text("\(viewModel.daysUntilBirthday)")
                                            .font(.system(size: 28, weight: .bold))
                                            .foregroundColor(.white)
                                        Text("days")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.top, 10)
            }
        }
        .background(
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .edgesIgnoringSafeArea(.all)
        )
        .frame(minWidth: 300, minHeight: 400)
        .onAppear {
            // Make the window draggable from anywhere
            if let window = NSApp.windows.first {
                window.isMovableByWindowBackground = true
                window.backgroundColor = NSColor.clear
                window.hasShadow = true
                window.level = .floating
            }
        }
    }
}

// ViewModel for the age calculator
class AgeCalculatorViewModel: ObservableObject {
    @Published var dateInput: String = ""
    @Published var selectedDate: Date = Date()
    @Published var showDatePicker: Bool = false
    @Published var errorMessage: String = ""
    @Published var age: Int = 0
    @Published var daysUntilBirthday: Int = 0
    @Published var monthsUntilBirthday: Int = 0
    @Published var isBirthday: Bool = false
    @Published var isCopied: Bool = false
    
    private let dateFormatter: DateFormatter
    
    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        // Load saved date if available
        if let savedDateString = UserDefaults.standard.string(forKey: "birthDate"),
           let savedDate = dateFormatter.date(from: savedDateString) {
            selectedDate = savedDate
            dateInput = dateFormatter.string(from: savedDate)
            calculateAge()
        }
    }
    
    func validateAndUpdateDate() {
        errorMessage = ""
        
        guard !dateInput.isEmpty else { return }
        
        if let date = dateFormatter.date(from: dateInput) {
            if date > Date() {
                errorMessage = "Date cannot be in the future"
            } else {
                selectedDate = date
                saveBirthDate()
                calculateAge()
            }
        } else {
            if dateInput.count >= 10 {
                errorMessage = "Invalid date format (MM/DD/YYYY)"
            }
        }
    }
    
    func updateDateInputFromSelection() {
        dateInput = dateFormatter.string(from: selectedDate)
        saveBirthDate()
        calculateAge()
    }
    
    func saveBirthDate() {
        UserDefaults.standard.set(dateInput, forKey: "birthDate")
    }
    
    func calculateAge() {
        let calendar = Calendar.current
        let now = Date()
        
        // Calculate age in years
        let ageComponents = calendar.dateComponents([.year], from: selectedDate, to: now)
        age = ageComponents.year ?? 0
        
        // Calculate next birthday
        let birthdayMonth = calendar.component(.month, from: selectedDate)
        let birthdayDay = calendar.component(.day, from: selectedDate)
        let currentYear = calendar.component(.year, from: now)
        
        var nextBirthdayComponents = DateComponents()
        nextBirthdayComponents.year = currentYear
        nextBirthdayComponents.month = birthdayMonth
        nextBirthdayComponents.day = birthdayDay
        
        guard let thisYearBirthday = calendar.date(from: nextBirthdayComponents) else {
            return
        }
        
        var nextBirthday = thisYearBirthday
        if thisYearBirthday < now {
            nextBirthdayComponents.year = currentYear + 1
            if let nextYearBirthday = calendar.date(from: nextBirthdayComponents) {
                nextBirthday = nextYearBirthday
            }
        }
        
        // Check if today is birthday
        let todayComponents = calendar.dateComponents([.month, .day], from: now)
        let birthdayComponents = calendar.dateComponents([.month, .day], from: selectedDate)
        
        isBirthday = todayComponents.month == birthdayComponents.month && 
                     todayComponents.day == birthdayComponents.day
        
        // Calculate time until next birthday
        if !isBirthday {
            let untilBirthdayComponents = calendar.dateComponents([.month, .day], from: now, to: nextBirthday)
            daysUntilBirthday = untilBirthdayComponents.day ?? 0
            monthsUntilBirthday = untilBirthdayComponents.month ?? 0
        } else {
            daysUntilBirthday = 0
            monthsUntilBirthday = 0
        }
    }
    
    func copyAgeToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString("\(age)", forType: .string)
        
        // Show copy confirmation
        isCopied = true
        
        // Reset after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.isCopied = false
        }
    }
}

// Visual effect view for the blurred background
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }
    
    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}

