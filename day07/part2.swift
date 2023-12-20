import Foundation

public struct Hands {
    public let hands: [Hand]
    
    public static func parse(_ input: String) -> Self {
        Hands(hands: input.split(whereSeparator: \.isNewline).map { (handS: Substring) in
            let hand: [Substring] = handS.split(separator: " ")
            return Hand(
                cards: hand[0].map { Card.from(character: $0) },
                bid: Int(hand[1])!
            )
        })
    }
    
    public enum Ordering {
        case lowestToHighest
        case highestToLowest
    }
    
    public func ordered(by ordering: Ordering) -> Self {
        if ordering == .lowestToHighest {
            return Hands(hands: self.hands.sorted { (handa: Hand, handb: Hand) in !handa.isHigher(than: handb) })
        } else {
            return Hands(hands: self.hands.sorted { (handa: Hand, handb: Hand) in handa.isHigher(than: handb) })
        }
    }
}

public struct Hand {
    public let cards: [Card]
    public let bid: Int
    
    public var type: HandType {
        let cardCounts: [Int] = self.cards.reduce(Array(repeating: 0, count: Card.A.strength), { _acc, card in
            var acc = _acc
            acc[card.strength - 1] += 1
            return acc
        })
        
        var cardCountsAddedWithJoker: [Int] = cardCounts.map { count in
            count + cardCounts[0]
        }
        cardCountsAddedWithJoker.removeFirst() // remove jokers
        
        if cardCountsAddedWithJoker.contains(5) {
            return .fiveOfAKind
        }
        
        if cardCountsAddedWithJoker.contains(4) {
            return .fourOfAKind
        }
        
        if (cardCounts.contains(3) && cardCounts.contains(2)) || self.isFullHouse(cardCounts: cardCounts) {
            return .fullHouse
        }
        
        if cardCountsAddedWithJoker.contains(3) {
            return .threeOfAKind
        }
        
        //if self.isTwoPair(cardCounts: cardCounts) {
        if cardCounts.filter({ $0 == 2 }).count == 2 ||
            cardCounts[0] == 2 ||
            (cardCounts.filter { $0 == 2 }.count == 1 && cardCounts[0] >= 1)
        {
            return .twoPair
        }
        
        if cardCountsAddedWithJoker.contains(2) || cardCounts.contains(2) {
            return .onePair
        }
        
        return .highCard
    }
    
    func isFullHouse(cardCounts: [Int]) -> Bool {
        // 3 + 2
        let jokerCount = cardCounts[0]
        var cardsWithoutJoker = cardCounts
        cardsWithoutJoker.removeFirst()
        for (iA, cardA) in cardsWithoutJoker.enumerated() {
            for (iB, cardB) in cardsWithoutJoker.enumerated() {
                if iA == iB { continue }
                for jokerC in (0...jokerCount) {
                    if cardA + jokerC == 3 && cardB + jokerCount - jokerC == 2 {
                        return true
                    }
                }
            }
        }
        
        switch jokerCount {
        case 0:
            return false
        case 1:
            return false
        case 2:
            if cardsWithoutJoker.contains(3) {
                return true
            }
        case 3:
            if cardsWithoutJoker.contains(2) {
                return true
            }
        case 4:
            return true
        default:
            return false
        }
        
        return false
    }
    
    func isTwoPair(cardCounts: [Int]) -> Bool {
        // TODO: joker as a card on its own!
        let jokerCount = cardCounts[0]
        for (iA, cardA) in cardCounts.enumerated() {
            if iA == 0 { continue } // joker
            for (iB, cardB) in cardCounts.enumerated() {
                if (iB == 0) { continue }
                if (iA == iB) {
                    for jokerC in (0...jokerCount) {
                        if cardA + jokerC == 2 && cardB + jokerCount - jokerC == 2 {
                            return true
                        }
                    }
                }
            }
        }
        
        switch jokerCount {
        case 0:
            return false
        case 1:
            return false
        case 2:
            if cardCounts.filter({ $0 == 2 }).count == 2 {
                return true
            }
        default: return false
        }
        
        return false
    }
    
    public enum HandType: Int {
        case fiveOfAKind
        case fourOfAKind
        case fullHouse
        case threeOfAKind
        case twoPair
        case onePair
        case highCard
    }
    
    public  func isHigher(than other: Hand) -> Bool {
        switch (self.type.rawValue) {
        case let x where x < other.type.rawValue:
            return true
        case let x where x == other.type.rawValue:
            return self.isHigherOrder(than: other)
        case let x where x > other.type.rawValue:
            return false
        default: fatalError("unreachable")
        }
    }
    
    /// Compare 2 hands of the same type
    func isHigherOrder(than other: Hand) -> Bool {
        for i in 0..<other.cards.count {
            if self.cards[i].strength > other.cards[i].strength {
                return true
            } else if self.cards[i].strength < other.cards[i].strength {
                return false
            } else {
                continue
            }
        }
        fatalError("unreachable: same hand")
    }
}

public struct Card {
    public let strength: Int
    
    public static var T: Card { Card(strength: 10) }
    public static var J: Card { Card(strength: 1) }
    public static var Q: Card { Card(strength: 11) }
    public static var K: Card { Card(strength: 12) }
    public static var A: Card { Card(strength: 13) }
    
    public static func from(character c: Character) -> Card {
        if let i = Int(String(c)) {
            return Card(strength: i)
        }
        switch c {
        case "T": return Card.T
        case "J": return Card.J
        case "Q": return Card.Q
        case "K": return Card.K
        case "A": return Card.A
        default: fatalError("Wrong character: \(c)")
        }
    }
}

extension Card: CustomStringConvertible {
    public var description: String {
        switch (self.strength) {
        case 1...9:
            return "\(self.strength)"
        case Card.T.strength: return "T"
        case Card.J.strength: return "J"
        case Card.Q.strength: return "Q"
        case Card.K.strength: return "K"
        case Card.A.strength: return "A"
        default:
            fatalError("Unreachable")
        }
    }
}
