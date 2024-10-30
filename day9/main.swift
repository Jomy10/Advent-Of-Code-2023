let input = """
0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45
"""

var sequences = input.split(separator: "\n")
    .map { line in 
        [line.split(separator: " ").map { Int($0)! }]
    }

func parse(sequence: inout [[Int]]) {
    while !sequence.last!.allSatisfy({ $0 == 0 }) {
        sequence.append(
            zip(
                sequence.last![0..<sequence.last!.count-1],
                sequence.last![1..<sequence.last!.count]
            ).map { a, b in
                b - a
            }
        )
    }
}

func extrapolate(sequence: inout [[Int]]) {
    var value = 0
    for i in (0..<sequence.count).reversed() {
        value = value + sequence[i].last!
        sequence[i].append(value)
    }
}

func extrapolateBack(sequence: inout [[Int]]) {
    var value = 0
    for i in (0..<sequence.count).reversed() {
        value = sequence[i].first! - value
        sequence[i].insert(value, at: 0)
    }
}

var sequences2 = sequences

// Party 1 //
var sumOfExtrapolatedValues = 0
for i in 0..<sequences.count {
    parse(sequence: &sequences[i])
    extrapolate(sequence: &sequences[i])
    sumOfExtrapolatedValues += sequences[i].first!.last!
}

print(sumOfExtrapolatedValues)

// Part 2 //
var sumOfExtrapolatedValues2 = 0
for i in 0..<sequences2.count {
    parse(sequence: &sequences2[i])
    extrapolateBack(sequence: &sequences2[i])
    sumOfExtrapolatedValues2 += sequences2[i].first!.first!
}

print(sumOfExtrapolatedValues2)
