import Foundation

@main
struct day04 {
    static func main() throws {
        let input = try String(contentsOfFile: Bundle.module.url(forResource: "input", withExtension: "txt")!.path)
        // let input = """
        // Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
        // Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
        // Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
        // Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
        // Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
        // Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
        // """

        let cards = Cards.parse(input)

        print("part 1:", cards.reduce(0, { $0 + $1.points }))

        print("part 2:", cards.play().reduce(0, +))
    }
}

typealias Cards = [Card]

extension Cards {
    static func parse(_ input: some StringProtocol) -> Self {
        input.split(whereSeparator: \.isNewline).map { line in
            Card.parse(line)
        }
    }

    func get(card: Int) -> Card {
        self[card - 1]
    }

    /// part2
    /// Returns the counts per scratchcards you end up with
    func play() -> [Int] {
        var cardCounts = Array<Int>(repeating: 1, count: self.count)
        for i in 0..<cardCounts.count {
            let cardCount = cardCounts[i]
            let cardId = i + 1
            let matches = self.get(card: cardId).matches.count
            for m in 0..<matches {
                cardCounts[i + m + 1] += cardCount
            }
        }
        return cardCounts
    }
}

struct Card {
    let id: Int
    let winningNumbers: [Int]
    let ownedNumbers: [Int]

    static func parse(_ input: some StringProtocol) -> Self {
        let card = input.split(separator: ":")
        let cardNum = Int(card[0].split(separator: " ")[1])!
        let numbers = card[1].split(separator: "|")
        let winningNumbers = numbers[0].split(separator: " ").map { Int($0)! }
        let ownedNumbers = numbers[1].split(separator: " ").map { Int($0)! }
        return Card(id: cardNum, winningNumbers: winningNumbers, ownedNumbers: ownedNumbers)
    }

    var matches: [Int] {
        self.ownedNumbers.filter { winningNumbers.contains($0) }
    }

    func nextCards() -> [Int] {
        (1...self.matches.count).map { $0 + self.id }
    }

    /// Points in part 1
    var points: Int {
        let matchCount = self.matches.count
        if matchCount == 0 {
            return 0
        } else {
            if matchCount == 1 {
                return 1
            } else {
                return Int(round(
                    pow(
                        Double(2),
                        Double(matchCount - 1)
                    )
                ))
            }
        }
    }
}

