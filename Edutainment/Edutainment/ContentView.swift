import SwiftUI

let BackSpace = "C"
let AllClear = "AC"
let primaryColor = Color(red: 1, green: 0.8, blue: 0)

struct Question {
    var question: String
    var answer: Int
}

struct FieldInput: View {
    @Binding var input: Int
    let label: String
    var placeholder = "E.g.: 12"
    
    var body: some View{
        VStack(alignment: .leading) {
            Text(label)
                .fontWeight(.bold)
                .foregroundColor(.white)
            TextField(placeholder, value: $input, format: .number)
                .fontWeight(.semibold)
                .inputContainer()
        }
    }
}

struct NumberKey: View {
    let key: String
    let onAction: (String) -> Void
    
    var body: some View {
        Button(action: {
            onAction(key)
        }) {
            Text("\(key)")
                .frame(minWidth: 96)
                .padding(.vertical, 16)
                .font(.system(size: 32, weight: .semibold))
                .roundedMaterialButton(radius: 10)
        }
    }
}

struct GridNumberPad: View {
    let onAction: (String) -> Void
    
    var body: some View {
        VStack {
            ForEach(1...3, id: \.self) { row in
                HStack() {
                    ForEach(1...3, id: \.self) { col in
                        let value = (row - 1) * 3 + col
                        NumberKey(key: String(value), onAction: onAction)
                        if col != 3 {
                            Spacer()
                        }
                    }
                }
            }
            HStack {
                NumberKey(key: AllClear, onAction: onAction)
                Spacer()
                NumberKey(key: "0", onAction: onAction)
                Spacer()
                NumberKey(key: BackSpace, onAction: onAction)
            }
        }
    }
}

struct ProgressBar: View {
    let maxValue: Int
    @Binding var currentValue: Int
    
    var currentProgress: CGFloat {
        (UIScreen.main.bounds.width - 80) * CGFloat(Double(maxValue - currentValue) / Double(maxValue))
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(primaryColor)
                .stroke(Color.white, lineWidth: 2)
                .frame(width: UIScreen.main.bounds.width - 80, height: 20)
            Capsule()
                .fill(.thickMaterial)
                .stroke(Color.white, lineWidth: 2)
                .frame(width: currentProgress, height: 20)
        }
    }
}

struct ContentView: View {
    @State var gameStarted = false
    @State var numQuestions = 10
    @State var maxNumQuestions = 10
    @State var timesTablesIncluded = 12
    
    @State var questions = [Question]()
    @State var score = 0
    @State var userInput = ""
    @State var showEndGameAlert = false
    @State var showResetGameWarning = false
    
    @State var currentQuestionRotationAmount = 0.0
    @State var currentBackgroundColor = primaryColor
    
    var currentQuestion: Question {
        guard !questions.isEmpty else { return Question(question: "1×1", answer: 1) }
        
        if numQuestions == 0 {
            return questions[0]
        }
        
        return questions[numQuestions - 1]
    }
    
    func populateQuestions(maxTablesIncluded: Int) -> [Question] {
        var questions = [Question]()
        for multiplicand in 1...maxTablesIncluded {
            for multiplier in 1...maxTablesIncluded {
                let questionLabel = "\(multiplicand)×\(multiplier)"
                let answer = multiplicand * multiplier
                let question = Question(question: questionLabel, answer: answer)
                questions.append(question)
            }
        }
        return questions
    }
    
    func randomizeQuestions() {
        let allQuestions = populateQuestions(maxTablesIncluded: timesTablesIncluded)
        questions = Array(allQuestions.shuffled().prefix(numQuestions))
    }
    
    func resetGame() {
        showEndGameAlert = false
        gameStarted = false
        numQuestions = 10
        timesTablesIncluded = 12
        score = 0
    }
    
    func startGame() {
        maxNumQuestions = numQuestions
        randomizeQuestions()
        gameStarted = true
    }
    
    func updateInput(value: String) {
        if value == AllClear {
            userInput = ""
            return
        }
        
        if value == BackSpace {
            if !userInput.isEmpty {
                userInput.removeLast()
            }
            return
        }
        
        userInput = userInput + value
    }
    
    func updateScore() {
        if Int(userInput) == currentQuestion.answer {
            score += 1
        }
    }
    
    var gameView: some View {
        VStack {
            VStack {
                HStack {
                    Text("0")
                    ProgressBar(maxValue: maxNumQuestions, currentValue: $numQuestions)
                    Text(maxNumQuestions, format: .number)
                }
                Text("Score: \(score)")
                    .font(.headline)
            }
            .foregroundColor(.white)
            
            Spacer()
            
            Text(currentQuestion.question)
                .font(.system(size: 96, weight: .semibold))
                .foregroundStyle(primaryColor)
                .frame(minWidth: UIScreen.main.bounds.width - 32)
                .padding(.vertical, 32)
                .background(.thickMaterial)
                .clipShape(.rect(cornerRadius: 10))
                .rotation3DEffect(.degrees(currentQuestionRotationAmount), axis: (x: 0, y: 1, z: 0))
            
            Spacer()
            
            VStack {
                HStack {
                    Text(userInput)
                        .font(.system(size: 32, weight: .semibold))
                    Spacer()
                    
                    Button {
                        withAnimation(
                            .easeInOut(duration: 0.5)
                        ) {
                            if Int(userInput) == currentQuestion.answer {
                                currentBackgroundColor = Color.green
                            } else {
                                currentBackgroundColor = Color.red
                            }
                        } completion: {
                            withAnimation(
                                .easeInOut(duration: 0.5)
                            ) {
                                currentBackgroundColor = primaryColor
                            }
                        }
                        
                        updateScore()
                        numQuestions -= 1
                        userInput = ""
                        
                        if numQuestions == 0 {
                            showEndGameAlert = true
                        }
                        
                        if numQuestions > 0 {
                            withAnimation(.spring(duration: 1, bounce: 0.5)) {
                                currentQuestionRotationAmount += 360
                            }
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.title)
                            .frame(width: 60, height: 60)
                            .roundedMaterialButton(radius: 10)
                    }
                    .padding(.trailing, -14)
                    
                }
                .inputContainer()
                
                GridNumberPad(onAction: updateInput)
            }
        }
        .alert("Game Ended", isPresented: $showEndGameAlert) {
            Button("Play Again") {
                resetGame()
            }
        } message: {
            Text("Your score is: \(score)")
        }
        .alert("End current game?", isPresented: $showResetGameWarning) {
            Button("End", role: .destructive) {
                resetGame()
            }
            Button("Cancel", role: .cancel) {
            }
        } message: {
            Text("Your current progress will be discard.")
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button() {
                    if numQuestions != maxNumQuestions {
                        showResetGameWarning = true
                        return
                    }
                    resetGame()
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .frame(width: 48, height: 48)
                        .roundedMaterialButton(radius: 50)
                }
            }
        }
    }
    
    var requestInfoView: some View {
        VStack {
            Text("MATHertainment")
                .foregroundColor(.white)
                .font(.largeTitle)
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .padding(.bottom, 150)
                .padding(.top, 50)
            
            VStack{
                FieldInput(input: $timesTablesIncluded, label: "Number of times tables included")
                    .padding(.bottom)
                FieldInput(input: $numQuestions, label: "How many questions do you want to play?", placeholder: "E.g.: 15")
                    .padding(.bottom)
                
                Button(action: startGame) {
                    Text("Start Game")
                        .frame(minWidth: 250, minHeight: 64)
                        .background(.thickMaterial)
                        .clipShape(.rect(cornerRadius: 50))
                        .foregroundColor(primaryColor)
                        .fontWeight(.bold)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 50)
                        .inset(by: 2)
                        .stroke(primaryColor, lineWidth: 2)
                )
                .padding(.top)
            }
            
            Spacer()
        }
        .padding()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                currentBackgroundColor.ignoresSafeArea()
                ZStack {
                    if !gameStarted {
                        requestInfoView
                    }
                    if gameStarted {
                        gameView
                    }
                }
            }
        }
    }
}

struct RoundedMaterialButton: ViewModifier {
    let radius: Int
    func body(content: Content) -> some View {
        content
            .foregroundColor(primaryColor)
            .background(.thickMaterial)
            .clipShape(.rect(cornerRadius: CGFloat(radius)))
            .overlay(
                RoundedRectangle(cornerRadius: CGFloat(radius))
                    .inset(by: 2)
                    .stroke(primaryColor, lineWidth: 2)
            )
    }
}

struct InputContainer: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .frame(height: 64)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .inset(by: 2)
                    .stroke(.white, lineWidth: 2)
            )
            .foregroundColor(.white)
    }
}

extension View {
    func inputContainer() -> some View {
        modifier(InputContainer())
    }
    
    func roundedMaterialButton(radius: Int) -> some View {
        modifier(RoundedMaterialButton(radius: radius))
    }
}

#Preview {
    ContentView()
}
