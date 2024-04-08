import SwiftUI

struct ContentView: View {
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Monaco", "Nigeria", "Poland", "Spain", "UK", "Ukraine", "US"].shuffled()
    
    @State private var numberOfQuestions = 10
    @State private var showingNumberOfQuestionsPrompt = true
    
    @State private var correctAnswer = Int.random(in: 0...2)
    @State private var showingIncorrectAnswerExplanation = false
    @State private var incorrectGuessMessage = ""
    
    @State private var score = 0
    @State private var showingScore = false
    
    func tapFlag(of number: Int) {
        numberOfQuestions -= 1
        showingIncorrectAnswerExplanation = number != correctAnswer
        
        if number == correctAnswer {
            score += 1
        } else {
            incorrectGuessMessage = "This is the flag of \(countries[number])."
        }
        
        if showingIncorrectAnswerExplanation {
            return
        }
        
        showingScore = numberOfQuestions == 0
        if numberOfQuestions > 0 {
            shuffleQuestion()
        }
    }
    
    func resetGame() {
        numberOfQuestions = 10
        showingNumberOfQuestionsPrompt = true
        
        showingIncorrectAnswerExplanation = false
        incorrectGuessMessage = ""
        
        score = 0
        showingScore = false
        
        shuffleQuestion()
    }
    
    func shuffleQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            RadialGradient(stops: [
                .init(color: Color(red: 0.0039, green: 0.098, blue: 0.212), location: 0.3),
                .init(color: Color(red: 0.95, green: 0.66, blue: 0.30), location: 0.3),
            ], center: .top, startRadius: 200, endRadius: 400)
            .ignoresSafeArea()
            
            Text("Guess the Flag")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.white)
                .padding(.vertical, 30)
            
            if !showingNumberOfQuestionsPrompt {
                VStack {
                    Spacer()
                    Spacer()
                    
                    Text("Questions remaining: \(numberOfQuestions)")
                        .foregroundStyle(.white)
                        .font(.headline.weight(.semibold))
                    Spacer()
                    
                    VStack(spacing: 15) {
                        VStack {
                            Text("Tap the flag of")
                                .font(.subheadline.weight(.heavy))
                                .foregroundStyle(Color(red: 0.20, green: 0.19, blue: 0.28))
                            Text(countries[correctAnswer])
                                .font(.largeTitle.weight(.semibold))
                                .foregroundStyle(Color(red: 0.0039, green: 0.098, blue: 0.212))
                        }
                        ForEach(0..<3) { country in
                            Button {
                                tapFlag(of: country)
                            } label: {
                                Image(countries[country])
                                    .clipShape(.rect(cornerRadius: 10))
                                    .shadow(radius: 5)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(.thinMaterial)
                    .clipShape(.rect(cornerRadius: 20))
                    
                    Spacer()
                    Spacer()
                    
                    Text("Score: \(score)")
                        .font(.title.bold())
                        .foregroundStyle(Color(red: 0.0039, green: 0.098, blue: 0.212))
                    
                    Spacer()
                }
                .padding()
            }
        }
        .alert("How many questions do you want in this game?", isPresented: $showingNumberOfQuestionsPrompt) {
            TextField("E.g.: 10", value: $numberOfQuestions, format: .number)
                .keyboardType(.numberPad)
            Button("Start Game") {
                shuffleQuestion()
            }
        }
        .alert("Game ended!", isPresented: $showingScore) {
            Button("Play Again") {
                resetGame()
            }
        } message: {
            Text("Your score is \(score).")
        }
        .alert("Incorrect!", isPresented: $showingIncorrectAnswerExplanation) {
            Button("Continue") {
                showingIncorrectAnswerExplanation = false
                if numberOfQuestions > 0 {
                    shuffleQuestion()
                    return
                }
                showingScore = true
            }
        } message: {
            Text(incorrectGuessMessage)
        }
    }
}

#Preview {
    ContentView()
}
