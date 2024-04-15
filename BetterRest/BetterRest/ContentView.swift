import CoreML
import SwiftUI

struct FieldContainer<Content: View>: View {
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(.bottom, 25)
    }
}

struct DecorativeBackground: View {
    var body: some View {
        HStack {
            ForEach(0...2, id: \.self) {
                Text("Z")
                    .font(.system(size: 200))
                    .bold()
                    .foregroundStyle(Color.blue)
                    .offset(x: CGFloat(-20*$0), y: CGFloat(-60*$0))
            }
        }
        .opacity(0.2)
        .padding(.leading, 30)
        .accessibility(hidden: true)
    }
}

struct ContentView: View {
    @State private var wakeUpTime = defaultWakeUpTime
    @State private var sleepAmount = 8.0
    @State private var numberOfCoffeeCups = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeUpTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var sleepTime: Date {
        return calculateBedTime()
    }
    
    func calculateBedTime() -> Date {
        do {
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime)
            let hours = (components.hour ?? 0) * 60 * 60
            let minutes = (components.minute ?? 0) * 60
            
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let prediction = try model.prediction(wake: Double(hours + minutes), estimatedSleep: sleepAmount, coffee: Double(numberOfCoffeeCups))
            
            return wakeUpTime - prediction.actualSleep
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
            showingAlert = true
        }
        return Date.now
    }
    
    @ViewBuilder var fields: some View {
        FieldContainer {
            Text("When do you want to wake up?")
                .font(.headline)
                .padding(.bottom, 10)
            DatePicker("Select a time", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(5)
        }
        FieldContainer {
            Text("Desired hours of sleep")
                .font(.headline)
            Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                .background(Color(UIColor(.white)))
        }
        FieldContainer {
            HStack {
                Text("Daily coffee intake")
                    .font(.headline)
                Spacer()
                Picker("How many cups", selection: $numberOfCoffeeCups) {
                    ForEach(0...20, id: \.self) {
                        Text("^[\($0) cup](inflect: true)")
                    }
                }
                .labelsHidden()
            }
        }
    }
    
    @ViewBuilder var result: some View {
        Section {
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text("Your ideal bed time is")
                    .fontWeight(.semibold)
                Text("\(sleepTime.formatted(date: .omitted, time: .shortened))")
                    .foregroundStyle(.blue)
                    .font(.title)
                    .bold()
            }
            .listRowBackground(Color(UIColor.systemGroupedBackground))
        }
    }
    
    init() {
        // Inspiration source: https://www.hackingwithswift.com/forums/100-days-of-swiftui/custom-stepper-view/13742
        UIStepper.appearance().setDecrementImage(UIImage(systemName: "minus")!.withTintColor(UIColor.systemBlue, renderingMode: .alwaysOriginal), for: .normal)
        UIStepper.appearance().setIncrementImage(UIImage(systemName: "plus")!.withTintColor(UIColor.systemBlue, renderingMode: .alwaysOriginal), for: .normal)
    }
    
    var body: some View {
        ZStack (alignment: .bottom) {
            DecorativeBackground()
            VStack(alignment: .leading) {
                Text("BetterRest")
                    .font(.largeTitle)
                    .bold()
                    .padding(.vertical, 25)
                fields
                result
                Spacer()
            }
            .padding(.horizontal, 15)
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
    }
}

#Preview {
    ContentView()
}
