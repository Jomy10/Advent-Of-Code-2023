import Foundation

public func part2() throws {
    let input = try String(contentsOfFile: Bundle.module.url(forResource: "input", withExtension: "txt")!.path)
    let digits = Digits()

    let calibrationValue = input.split(whereSeparator: \.isNewline).map { line in
        Digits.formDigit(for: digits.getDigits(in: line))
    }.reduce(0, +)

    print("CalibrationValue =", calibrationValue)
}

class NumberTree: CustomStringConvertible {
    let id = UUID()
    var value: Int?
    var next: [Character: NumberTree]

    init() {
        self.next = [:]
    }
    
    func add(wholeNumber: String, value: Int) {
        if wholeNumber.count == 0 {
            self.value = value
            return
        }
        let c = wholeNumber.first!
        if self.next[c] == nil {
            self.next[c] = NumberTree()
        }
        self.next[c]!.add(
            wholeNumber: String(wholeNumber[wholeNumber.index(wholeNumber.startIndex, offsetBy: 1)...]),
            value: value)
    }

    var description: String {
        return "NumberTree { value: \(String(describing: self.value)), next: \(self.next) }"
    }
}

extension NumberTree: Equatable {
    static func ==(lhs: NumberTree, rhs: NumberTree) -> Bool {
        lhs.id == rhs.id
    }
}

struct Digits {
    let digits: NumberTree

    init() {
        self.digits = NumberTree()
        ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
            .enumerated()
            .forEach { (numI, numS) in
                self.digits.add(wholeNumber: numS, value: numI + 1)
            }
    }

    func getDigits(in line: Substring) -> [Int] {
        var result: [Int] = []
        var trees: [NumberTree] = []
        for c in line {
            if let i = c.wholeNumberValue {
                result.append(i)
            } else {
                for tree in trees {
                    if let ntree = tree.next[c] {
                        if let val = ntree.value {
                            result.append(val)
                        } else {
                            trees.append(ntree)
                        }
                    }
                    trees.remove(at: trees.firstIndex(of: tree)!)
                }
                if let tree = self.digits.next[c] {
                    trees.append(tree)
                }
            }
        }
        return result
    }

    static func formDigit(for digits: [Int]) -> Int {
        digits.first! * 10 + digits.last!
    }
}

