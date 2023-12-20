// hands: 5 cards
// Goal: order hands on strength

import Foundation
import day07_part1
import day07_part2

let input = try String(contentsOfFile: Bundle.module.url(forResource: "input", withExtension: "txt")!.path)
//let input: String = """
//32T3K 765
//T55J5 684
//KK677 28
//KTJJT 220
//QQQJA 483
//"""

let hands1: day07_part1.Hands = day07_part1.Hands.parse(input)

let orderedHands1 = hands1.ordered(by: .lowestToHighest)
print("part 1:", orderedHands1.hands.enumerated().map { (i: Int, hand: day07_part1.Hand) in
    hand.bid * (i + 1)
}.reduce(0, +))

let hands2 = day07_part2.Hands.parse(input)

//for hand in hands2.ordered(by: .lowestToHighest).hands {
//    print("\(hand.cards) - \(hand.type)")
//}
let orderedHands2 = hands2.ordered(by: .lowestToHighest)
print("part 2:", orderedHands2.hands.enumerated().map { (i, hand) in
    hand.bid * (i + 1)
}.reduce(0, +))
