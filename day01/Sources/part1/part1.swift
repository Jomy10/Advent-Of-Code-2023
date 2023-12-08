import Foundation

@main
public struct part1 {
    public static func main() throws {
        let input = try String(contentsOfFile: "input.txt")

        let calibrationValue = input.split(whereSeparator: \.isNewline).map { line in
            getDigit(in: line)
        }.reduce(0, +)

        print("CalibrationValue =", calibrationValue)
    }
}

func getDigit(in line: Substring) -> Int {
    let first = line.first(where: { c in c.isNumber })!.wholeNumberValue!
    let last = line.reversed().first(where: { c in c.isNumber })!.wholeNumberValue!
    return first * 10 + last
}

