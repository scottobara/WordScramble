//
//  ContentView.swift
//  WordScramble
//
//  Created by Scott Obara on 13/1/21.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var userScore = 0
    @State private var scoreValues = [0,0,0,0,0,0,0,0,0]
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                        Text($0)
                }
                Text("Score: \(userScore)").font(.headline)
                HStack {
                    ForEach((3...scoreValues.count), id: \.self) { i in
                        VStack {
                            Image(systemName: "\(i).circle")
                            //Text("\(self.body)")
                        }
                    }
                }
                .padding(.top, 10.0)
            }
            .navigationBarTitle(rootWord)
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }.navigationBarItems(leading:
                Button("New Word") {
                    startGame()
                    usedWords = []
                    userScore = 0
                }
            )
        }
    }
    
    func addNewWord() {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // exit if the remaining string is empty
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original.")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word.")
            return
        }
        
        guard isLongEnough(word: answer) else {
            wordError(title: "Word too simple", message: "This word doesn't meet the minimum length of 3 characters.")
            return
        }
        
        usedWords.insert(answer, at: 0)
        scoreValues[answer.count] += 1
        
        
        switch answer.count {
        case 3:
            userScore += 1
        case 4:
            userScore += 2
        case 5:
            userScore += 4
        case 6:
            userScore += 7
        case 7:
            userScore += 11
        case 8:
            userScore += 16
        default:
            userScore += 0
        }
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworms"
                return
            }
        }
        
        fatalError("could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        
        if word == rootWord {
            return false
        } else {
            return !usedWords.contains(word)
        }
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    func isLongEnough(word: String) -> Bool {
        if word.count < 3 {
            print(word.count)
            return false
        } else {
            return true
        }
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



