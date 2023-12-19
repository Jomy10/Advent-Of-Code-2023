// start: 0mm/ms
// hold down for 1ms: speed increases by 1mm per ms

import Foundation

let input = try String(contentsOfFile: Bundle.module.url(forResource: "input", withExtension: "txt")!.path)
//let input = """
//Time:      7  15   30
//Distance:  9  40  200
//"""

let races = Races.parse(input)

print("part 1:", (0..<races.count).map { i in
    races.margin(for: i)
}.reduce(1, *))

let race = Race.parse(input)

print("part 2: ", race.margin)

/// Part 1
struct Races {
    let times: [Int]
    let distances: [Int]
    
    var count: Int {
        self.times.count
    }
    
    static func parse(_ input: String) -> Self {
        let s = input.split(whereSeparator: \.isNewline)
        return Races(
            times: s[0].split(separator: ":")[1].split(separator: " ")
                .map { num in num.trimmingCharacters(in: .whitespacesAndNewlines) }
                .map { Int($0)! },
            distances: s[1].split(separator: ":")[1].split(separator: " ")
                .map { num in num.trimmingCharacters(in: .whitespacesAndNewlines) }
                .map { Int($0)! }
        )
    }
    
    /// Amount of ways you can beat a race
    func margin(for race: Int) -> Int {
        let time = self.times[race]
        let distanceRecord = self.distances[race]
        
        let distancesTravelled = (0...time).map { msHeldDown in
            (
                timeLeft: time - msHeldDown,
                speed: msHeldDown
            )
        }.map { (timeLeft, speed) in
            timeLeft * speed
        }
        
        return distancesTravelled.filter { $0 > distanceRecord }.count
    }
}

/// Part2
struct Race {
    let time: Int
    let distanceRecord: Int
    
    static func parse(_ input: String) -> Self {
        let s = input.split(whereSeparator: \.isNewline)
        return Race(
            time: Int(s[0].split(separator: ":")[1].replacing(" ", with: ""))!,
            distanceRecord: Int(s[1].split(separator: ":")[1].replacing(" ", with: ""))!
        )
    }
    
    var margin: Int {
        let minDistance: Int = self.distanceRecord + 1
        let maxTimeToPress: Double = ((Double(self.time) + sqrt(Double(self.time * self.time) - 4.0 * Double(minDistance))) / 2.0)
        let minTimeToPress: Double = ((Double(self.time) - sqrt(Double(self.time * self.time) - 4.0 * Double(minDistance))) / 2.0)
        
        let minTime = Int(minTimeToPress.rounded(.up))
        let maxTime = Int(maxTimeToPress.rounded(.down))
        
        return (minTime...maxTime).count
    }
}
