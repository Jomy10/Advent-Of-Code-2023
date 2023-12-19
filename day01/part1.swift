import Foundation

public func part1() throws {
    let input = try String(contentsOfFile: Bundle.module.url(forResource: "input", withExtension: "txt")!.path)

    let calibrationValue = input.split(whereSeparator: \.isNewline).map { line in
        getDigit(in: line)
    }.reduce(0, +)

    print("CalibrationValue =", calibrationValue)
}

func getDigit(in line: Substring) -> Int {
    let first = line.first(where: { c in c.isNumber })!.wholeNumberValue!
    let last = line.reversed().first(where: { c in c.isNumber })!.wholeNumberValue!
    return first * 10 + last
}

