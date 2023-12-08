import Foundation

@main
public struct day03 {
    public static func main() throws {
        let input = try String(contentsOfFile: "input.txt")
       // let input = """
       // 467..114..
       // ...*......
       // ..35..633.
       // ......#...
       // 617*......
       // .....+.58.
       // ..592.....
       // ......755.
       // ...$.*....
       // .664.598..
       // """
        
        let schematic = Schematic.parse(input)

        // to debug:
        print(schematic)

        let partNums = schematic.partNumbersAndCoordinates
        print("part 1:",
              partNums.map{$1}.reduce(0, +)
        )
        print("part 2:",
            schematic.gears(withPartNumbers: partNums)
                .map { $0.ratio }
                .reduce(0, +)
        )
    }
}

struct Coordinate: Hashable {
    let x: Int
    let y: Int
}

typealias Number = (location: [Coordinate], value: Int)

struct Gear {
    let location: Coordinate
    let numbers: [Number]
    var ratio: Int {
        let values = self.numbers.map { $1 }
        return values[0] * values[1]
    }
}

struct Schematic {
    var symbols: [Coordinate: Character] = [:]
    // should be sorted like this: top to bottom, left to right
    var numbers: [Number] = []
    let width: Int
    let height: Int
    
    mutating func add(symbol: Character, at coordinate: Coordinate) {
        self.symbols[coordinate] = symbol
    }
    
    mutating func add(number: Int, at location: [Coordinate]) {
        self.numbers.append((location: location, value: number))
    }
    
    mutating func add(numberAsString str: String, withEndLocation endCoordinate: Coordinate) {
        let number = Int(str)!
        self.add(number: number, at: (0..<str.count)
            .map { i in
                Coordinate(x: endCoordinate.x - i, y: endCoordinate.y)
            }
            .sorted(by: { co1, co2 in
                co1.x < co2.x
            })
        )
    }

    static func parse(_ input: String) -> Self {
        let lines = input.split(whereSeparator: \.isNewline)
        var schematic = Schematic(width: lines.first!.count, height: lines.count)

        var num = String()
        for (row, line) in lines.enumerated() {
            for (col, c) in line.enumerated() {
                if !c.isNumber && num.count != 0 {
                    schematic.add(
                        numberAsString: num,
                        withEndLocation: Coordinate(x: col - 1, y: row)
                    )
                    if c != "." {
                        schematic.add(symbol: c, at: Coordinate(x: col, y: row))
                    }
                    num = String()
                } else if c == "." {
                    continue
                } else if c.isNumber {
                    num.append(c)
                } else {
                    schematic.add(symbol: c, at: Coordinate(x: col, y: row))
                }
            }
            if num.count != 0 {
                schematic.add(
                    numberAsString: num,
                    withEndLocation: Coordinate(x: line.count - 1, y: row)
                )
                num = String()
            }
        }

        return schematic
    }
    
    var nonPartNumbers: [Int] {
        self.nonPartNumbersAndCoordinates
            .map { $0.value }
    }

    var nonPartNumbersAndCoordinates: [(Number)] {
        self.numbers
            .filter { num in
                !self.isPartNumber(num)
            }
    }
    
    var partNumbers: [Int] {
        self.partNumbersAndCoordinates
            .map { $0.value }
    }

    var partNumbersAndCoordinates: [(Number)] {
        self.numbers
            .filter { num in
                self.isPartNumber(num)
            }
    }

    //xxyzz
    //x123z
    //xxyzz
    func isPartNumber(_ num: Number) -> Bool {
        func checkLeftMost(_ co: Coordinate) -> Bool {
            // left
            self.isSymbol(at: Coordinate(x: co.x - 1, y: co.y)) ||
            // top left
            self.isSymbol(at: Coordinate(x: co.x - 1, y: co.y - 1)) ||
            // bottom left
            self.isSymbol(at: Coordinate(x: co.x - 1, y: co.y + 1)) ||
            // up
            self.isSymbol(at: Coordinate(x: co.x, y: co.y - 1)) ||
            // down
            self.isSymbol(at: Coordinate(x: co.x, y: co.y + 1))
        }
        func checkRightMost(_ co: Coordinate) -> Bool {
            // top
            self.isSymbol(at: Coordinate(x: co.x, y: co.y - 1)) ||
            // bottom
            self.isSymbol(at: Coordinate(x: co.x, y: co.y + 1)) ||
            // right
            self.isSymbol(at: Coordinate(x: co.x + 1, y: co.y)) ||
            // top right
            self.isSymbol(at: Coordinate(x: co.x + 1, y: co.y - 1)) ||
            // bottom right
            self.isSymbol(at: Coordinate(x: co.x + 1, y: co.y + 1))
        }

        for (i, co) in num.location.enumerated() {
            let isPartNumber: Bool
            if i == 0 && num.location.count == 1 {
                isPartNumber = checkLeftMost(co) || checkRightMost(co)
            } else if i == 0 {
                isPartNumber = checkLeftMost(co)
            } else if i == num.location.count - 1 {
                isPartNumber = checkRightMost(co)
            } else {
                isPartNumber =
                    // top
                    self.isSymbol(at: Coordinate(x: co.x, y: co.y - 1)) ||
                    // bottom
                    self.isSymbol(at: Coordinate(x: co.x, y: co.y + 1))
            }
            if isPartNumber {
                return true
            }
        }
        return false
    }
    
    func isSymbol(at coordinate: Coordinate) -> Bool {
        return self.symbols[coordinate] != nil
    }

    static func isGear(withGears gears: [Gear], at location: Coordinate) -> Bool {
        gears.contains(where: { gear in gear.location == location })
    }

    func gears(withPartNumbers partNumbers: [Number]) -> [Gear] {
        self.symbols
            .filter { (co: Coordinate, sym: Character) in
                sym == "*"
            }
            .map { (co: Coordinate, sym: Character) in
                Gear(
                    location: co,
                    numbers: partNumbers
                        .filter { (cos, num) in
                            for numco in cos {
                                if (
                                    [-1, 0, 1].map { numco.x + $0 }.contains(co.x) &&
                                    [-1, 0, 1].map { numco.y + $0 }.contains(co.y)
                                ) {
                                    return true
                                }
                            }
                            return false
                        }
                )
            }.filter { (gear: Gear) in
                gear.numbers.count == 2
            }
    }

    var gears: [Gear] {
        self.gears(withPartNumbers: self.partNumbersAndCoordinates)
    }
}

extension Schematic: CustomStringConvertible {
    enum DescriptionPoint {
        case dot
        case symbol(Character)
        case gear(Character)
        case partNumberPart(Character)
        case nonPartNumberPart(Character)
    }

    var description: String {
        var grid: [[DescriptionPoint]] = [[DescriptionPoint]](repeating: [DescriptionPoint](repeating: .dot, count: self.width), count: self.height)
        let gears = self.gears
        for (co, sym) in self.symbols {
            grid[co.y][co.x] = Self.isGear(withGears: gears, at: co) ? .gear(sym) : .symbol(sym)
        }
        for (cos, num) in self.partNumbersAndCoordinates {
            let numS = String(num)
            for (i, co) in cos.enumerated() {
                grid[co.y][co.x] = .partNumberPart(numS[numS.index(numS.startIndex, offsetBy: i)])
            }
        }
        for (cos, num) in self.nonPartNumbersAndCoordinates {
            let numS = String(num)
            for (i, co) in cos.enumerated() {
                grid[co.y][co.x] = .nonPartNumberPart(numS[numS.index(numS.startIndex, offsetBy: i)])
            }
        }
        return grid
            .map { row in
                row
                    .map { c in
                        switch (c) {
                        case .dot:
                            return "."
                        case .gear(let sym):
                            return "\u{001B}[0;36m\(sym)\u{001B}[0;0m"
                        case .symbol(let sym):
                            return String(sym)
                        case .partNumberPart(let num):
                            return String(num)
                        case .nonPartNumberPart(let num):
                            return "\u{001B}[0;31m\(num)\u{001B}[0;0m"
                        }
                    }
                    .joined(separator: "")
            }
            .joined(separator: "\n")
    }
}

