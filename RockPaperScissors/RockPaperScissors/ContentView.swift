import SwiftUI

enum GameMove: String, CaseIterable {
    case Rock = "Rock"
    case Paper = "Paper"
    case Scissors = "Scissors"
}

struct Move {
    let move: GameMove
    let name: String
    let icon: String
    let beat: GameMove
    let yield: GameMove
    
    init(move: GameMove) {
        self.move = move
        switch move {
        case GameMove.Rock:
            self.name = GameMove.Rock.rawValue
            self.icon = "👊"
            self.beat = GameMove.Scissors
            self.yield = GameMove.Paper
        case .Paper:
            self.name = GameMove.Paper.rawValue
            self.icon = "🖐️"
            self.beat = GameMove.Rock
            self.yield = GameMove.Scissors
        case .Scissors:
            self.name = GameMove.Scissors.rawValue
            self.icon = "✌️"
            self.beat = GameMove.Paper
            self.yield = GameMove.Rock
        }
    }
}

extension Move: Comparable {
    static func < (lhs: Move, rhs: Move) -> Bool {
        return lhs.move == rhs.beat
    }
    
    static func == (lhs: Move, rhs: Move) -> Bool {
        return lhs.move == rhs.move
    }
    
    static func > (lhs: Move, rhs: Move) -> Bool {
        return lhs.move == rhs.yield
    }
}

let moves = GameMove.allCases.map {
    Move(move: $0)
}

struct MoveButton: View {
    let move: Move
    let action: () -> Void
    
    var body: some View {
        Button() {
            action()
        } label: {
            Text("\(move.icon)")
                .font(.system(size: 80))
        }
        .padding(10)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 5))
        .shadow(color: .white, radius: 5)
    }
}

struct ContentView: View {
    @State private var numberOfRounds = 10
    @State private var currentMove = moves.randomElement() ?? moves[0]
    @State private var shouldWin = Bool.random()
    @State private var score = 0
    @State private var isGameOver = false
    
    func goToNextGame() {
        numberOfRounds -= 1
        if numberOfRounds <= 0 {
            isGameOver = true
            return
        }
        shouldWin = Bool.random()
        currentMove = moves.randomElement() ?? moves[0]
    }
    
    func resetGame() {
        numberOfRounds = 10
        currentMove = moves.randomElement() ?? moves[0]
        shouldWin = Bool.random()
        score = 0
        isGameOver = false
    }
    
    func updateScore(for move: Move) {
        if shouldWin && move > currentMove {
            score += 1
            return
        }
        
        if !shouldWin && move < currentMove {
            score += 1
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    Text(currentMove.icon)
                        .font(.system(size: 100))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black)
                HStack {
                    ForEach(moves.shuffled(), id: \.self.name) { move in
                        MoveButton(move: move) {
                            updateScore(for: move)
                            goToNextGame()
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.red)
            }
            
            ZStack {
                VStack {
                    Text("Rounds remaining: \(numberOfRounds)")
                        .foregroundStyle(.red)
                    Text("Current Score: \(score)")
                        .foregroundStyle(.red)
                        .font(.headline.weight(.semibold))
                    Spacer()
                }
                .padding(.top, 50)
            }
            
            Text(shouldWin ? "Let's Win" : "Let's lose")
                .padding(20)
                .background(.white)
                .font(.system(size: 50).weight(.semibold))
                .clipShape(.rect(cornerRadius: 10))
            
        }
        .ignoresSafeArea()
        .alert("Game Ended", isPresented: $isGameOver) {
            Button("Play Again") {
                resetGame()
            }
        } message: {
            Text("Your score is \(score)")
        }
    }
}

#Preview {
    ContentView()
}
