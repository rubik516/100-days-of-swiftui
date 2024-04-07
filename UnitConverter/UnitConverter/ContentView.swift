import SwiftUI

enum Category: String, CaseIterable {
    case Angle = "Angle"
    case Area = "Area"
    case Length = "Length"
    case Mass = "Mass"
    case Speed = "Speed"
    case Temperature = "Temperature"
    case Time = "Time"
    case Volume = "Volume"
}

struct MeasurementUnit {
    static let Angle = ["Degree", "Radian"]
    static let Area = ["Hectare", "Sq cm", "Sq ft", "Sq inch", "Sq km", "Sq meter"]
    static let Length = ["Feet", "Inch", "Kilometers", "Meters", "Miles", "Yards"]
    static let Mass = ["g", "kg", "lb", "mg", "oz"]
    static let Speed = ["km/h", "m/s", "mph"]
    static let Temperature = ["Celsius", "Fahrenheit", "Kelvin"]
    static let Time = ["Hours", "Minutes", "Seconds"]
    static let Volume = ["Cups", "Fl oz", "Gallons", "Liters", "Milliliters", "Pints", "Tablespoon", "Teaspoon"]
}

let UnitMap = [
    "Degree": UnitAngle.degrees,
    "Radian": UnitAngle.radians,
    
    "Hectare": UnitArea.hectares,
    "Sq cm": UnitArea.squareCentimeters,
    "Sq ft": UnitArea.squareFeet,
    "Sq inch": UnitArea.squareInches,
    "Sq km": UnitArea.squareKilometers,
    "Sq meter": UnitArea.squareMeters,
    
    "Feet": UnitLength.feet,
    "Inch": UnitLength.inches,
    "Kilometers": UnitLength.kilometers,
    "Meters": UnitLength.meters,
    "Miles": UnitLength.miles,
    "Yards": UnitLength.yards,
    
    "g": UnitMass.grams,
    "kg": UnitMass.kilograms,
    "lb": UnitMass.pounds,
    "mg": UnitMass.milligrams,
    "oz": UnitMass.ounces,
    
    "km/h": UnitSpeed.kilometersPerHour,
    "m/s": UnitSpeed.metersPerSecond,
    "mph": UnitSpeed.milesPerHour,
    
    "Celsius": UnitTemperature.celsius,
    "Fahrenheit": UnitTemperature.fahrenheit,
    "Kelvin": UnitTemperature.kelvin,
    
    "Hours": UnitDuration.hours,
    "Minutes": UnitDuration.minutes,
    "Seconds": UnitDuration.seconds,
    
    "Cups": UnitVolume.cups,
    "Fl oz": UnitVolume.fluidOunces,
    "Gallons": UnitVolume.gallons,
    "Liters": UnitVolume.liters,
    "Milliliters": UnitVolume.milliliters,
    "Pints": UnitVolume.pints,
    "Tablespoon": UnitVolume.tablespoons,
    "Teaspoon": UnitVolume.teaspoons
]

struct ContentView: View {
    @State private var selectedCategory = Category.Mass
    @State private var units = MeasurementUnit.Mass
    @State private var selectedFrom = MeasurementUnit.Mass[0]
    @State private var selectedTo = MeasurementUnit.Mass[1]
    @State private var input = "0"
    
    @FocusState private var isInputFocused: Bool
    
    func mapUnit(_ unit: String) -> Dimension? {
        return UnitMap[unit]
    }
    
    func shouldShowInputError() -> Bool {
        if input == "" || input == "." || input == "-" {
            return false
        }
        return Double(input) == nil
    }
    
    func shouldShowResultError() -> Bool {
        output == Double.infinity
    }
    
    var output: Double {
        if input == "" || input == "." || input == "-" {
            return 0
        }
        
        guard let numericalInput = Double(input) else {
            return Double.infinity
        }
        
        guard let fromUnit = mapUnit(selectedFrom), let toUnit = mapUnit(selectedTo) else {
            return Double.infinity
        }
        
        let measurement = Measurement(value: numericalInput, unit: fromUnit)
        return measurement.converted(to: toUnit).value
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Category") {
                    Picker("Choose a category", selection: $selectedCategory) {
                        ForEach(Category.allCases, id: \.self) { unit in
                            Text(unit.rawValue)
                        }
                    }
                    .onChange(of: selectedCategory, {
                        switch selectedCategory {
                        case .Angle:
                            units = MeasurementUnit.Angle
                        case .Area:
                            units = MeasurementUnit.Area
                        case .Length:
                            units = MeasurementUnit.Length
                        case .Mass:
                            units = MeasurementUnit.Mass
                        case .Speed:
                            units = MeasurementUnit.Speed
                        case .Temperature:
                            units = MeasurementUnit.Temperature
                        case .Time:
                            units = MeasurementUnit.Time
                        case .Volume:
                            units = MeasurementUnit.Volume
                        }
                        selectedFrom = units[0]
                        selectedTo = units[1]
                        input = "0"
                    })
                }
                Section("From") {
                    Picker("Choose a unit", selection: $selectedFrom) {
                        ForEach(units, id: \.self) { unit in
                            Text(unit)
                        }
                    }
                }
                Section("To") {
                    Picker("Choose a unit", selection: $selectedTo) {
                        ForEach(units, id: \.self) { unit in
                            Text(unit)
                        }
                    }
                }
                Section("Enter a value") {
                    TextField("E.g.: 10.0", text: $input)
                        .keyboardType(.numbersAndPunctuation)
                        .focused($isInputFocused)
                    if shouldShowInputError() {
                        Text("Please enter a valid value: (0-9, ., -)")
                            .listRowBackground(Color(UIColor.systemGroupedBackground))
                    }
                }
                Section("Result") {
                    Text(output, format: .number)
                    if shouldShowResultError() {
                        Text("Some error may have happened..")
                            .listRowBackground(Color(UIColor.systemGroupedBackground))
                    }
                }
            }
            .navigationTitle("Unit Converter")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                if isInputFocused {
                    Button("Done") {
                        isInputFocused = false
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
