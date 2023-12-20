// hands: 5 cards
// Goal: order hands on strength

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
        
        if cardCounts.contains(5) {
            return .fiveOfAKind
        }
        
        if cardCounts.contains(4) {
            return .fourOfAKind
        }
       
        if cardCounts.contains(3) {
            if cardCounts.contains(2) {
                return .fullHouse
            } else {
                return .threeOfAKind
            }
        }
        
        let pairCount = cardCounts.filter { $0 == 2 }.count
        if pairCount == 2 {
            return .twoPair
        } else if pairCount == 1 {
            return .onePair
        }
        
        return .highCard
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

extension Hand: CustomStringConvertible {
    public var description: String {
        self.cards.map { $0.description }.joined()
    }
}

public struct Card {
    public let strength: Int
    
    public static var T: Card { Card(strength: 10) }
    public static var J: Card { Card(strength: 11) }
    public static var Q: Card { Card(strength: 12) }
    public static var K: Card { Card(strength: 13) }
    public static var A: Card { Card(strength: 14) }
    
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
