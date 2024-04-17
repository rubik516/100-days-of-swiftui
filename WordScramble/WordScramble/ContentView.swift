import SwiftUI

struct ContentView: View {
    @State private var allWords = [String]()
    @State private var usedWords = [String]()
    @State private var rootWord = "Root word"
    @State private var newWord = ""
    
    @State private var score = 0
    
    @State private var errorAlertTitle = ""
    @State private var errorAlertMessage = ""
    @State private var showingErrorAlert = false
    @State private var showingResetGameAlert = false
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if validateWord(word: answer) {
            withAnimation {
                usedWords.insert(answer, at: 0)
                updateScore(answer: answer)
            }
        }
        newWord = ""
    }
    
    func isAlreadyPresent(word: String) -> Bool {
        usedWords.contains(word)
    }
    
    func isComposableFromRootWord(word: String) -> Bool {
        var letters = rootWord
        for letter in word {
            guard let position = letters.firstIndex(of: letter) else {
                return false
            }
            letters.remove(at: position)
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let spellChecker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = spellChecker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func loadResource() {
        if let source = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let sourceContent = try? String(contentsOf: source) {
                allWords = sourceContent.components(separatedBy: "\n")
                return
            }
        }
        fatalError("A problem occurred when loading resource.")
    }
    
    func resetGame() {
        rootWord = allWords.randomElement() ?? allWords[Int.random(in: 0...allWords.count)]
        usedWords.removeAll()
    }
    
    func setAlertError(title: String, description: String) {
        errorAlertTitle = title
        errorAlertMessage = description
        showingErrorAlert = true
    }
    
    func updateScore(answer: String) {
        score += answer.count
    }
    
    func validateWord(word: String) -> Bool {
        guard word.count > 0 else {
            return false
        }
        
        if word == rootWord {
            setAlertError(title: "Word matches perfectly", description: "Guessing the given word is not fun. \nTry something else!")
            return false
        }
        
        if !isReal(word: word) {
            setAlertError(title: "Word does not exist", description: "You can't make up words, you know!")
            return false
        }
        
        if !isComposableFromRootWord(word: word) {
            setAlertError(title: "Invalid word", description: "Cannot form \(word) from \(rootWord)")
            return false
        }
        
        if isAlreadyPresent(word: word) {
            setAlertError(title: "Word previously entered", description: "Be more original!")
            return false
        }
        
        return true
    }
    
    var body: some View {
        NavigationStack {
            List {
                VStack (alignment: .leading) {
                    HStack {
                        Text(rootWord).font(.largeTitle).bold()
                        Spacer()
                        Button("Change Word") {
                            if usedWords.count > 0 {
                                showingResetGameAlert = true
                                return
                            }
                            resetGame()
                        }
                        .buttonStyle(.borderless)
                    }
                    Spacer()
                    VStack (alignment: .leading) {
                        HStack {
                            Text("Total words:").fontWeight(.semibold)
                            Text("\(usedWords.count)")
                        }
                        HStack {
                            Text("Current score:").fontWeight(.semibold)
                            Text("\(score)")
                        }
                    }
                }
                .listRowBackground(Color(UIColor.systemGroupedBackground))

                Section {
                    TextField("Enter a word", text: $newWord)
                        .textInputAutocapitalization(.never)
                        .onSubmit(addNewWord)
                }
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                    }
                }
            }
        }
        .onAppear(perform: {
            loadResource()
            resetGame()
        })
        .alert(errorAlertTitle, isPresented: $showingErrorAlert) {} message: {
            Text(errorAlertMessage)
        }
        .alert("Are you sure you want to restart?", isPresented: $showingResetGameAlert) {
            Button("Restart", role: .destructive) {
                resetGame()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your current progress will be discarded.")
        }
    }
}

#Preview {
    ContentView()
}
