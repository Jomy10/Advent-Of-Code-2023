import Foundation

@main
public struct day02 {
    public static func main() throws {
        let input = try String(contentsOfFile: Bundle.module.url(forResource: "input", withExtension: "txt")!.path)

        let games = try Games.parse(input)
        
        // Part 1
        let cubeCounts = (
            red: 12,
            green: 13,
            blue: 14
        )
        
        var impossibleGames: Set<Int> = Set()
        for game in games {
            for round in game.rounds {
                if !round.isPossible(with: cubeCounts) {
                    impossibleGames.insert(game.id)
                }
            }
        }
        
        let possibleGames = games.filter { game in
            !impossibleGames.contains(game.id)
        }.map { $0.id }
        
        print("part 1:",possibleGames.reduce(0, +))
       
        // Part 2
        let fewest = games.map { $0.fewestCubes() }
        let powers = fewest.map { $0.red * $0.green * $0.blue }
        let part2 = powers.reduce(0, +)
        print("part 2:", part2)
    }
}

typealias Games = [Game]

extension Games {
    static func parse(_ input: String) throws -> Self {
        Games(input.split(whereSeparator: \.isNewline)
            .map { line in
                Game.parse(line)
            }
        )
    }
}

struct Game {
    let id: Int
    
    var rounds: [Round] = []
    
    static func parse<Str: StringProtocol>(_ input: Str) -> Self {
        let s = input.split(whereSeparator: { $0 == ":" })
        let gameSplit = s[0].split(whereSeparator: { $0 == " " })
        let gameID: Int = Int(String(gameSplit[1]))!
        var game: Game = Game(id: gameID)
        
        let rounds = s[1].split(whereSeparator: { $0 == ";" })
        game.rounds = rounds.map { round in
            Round.parse(round)
        }
        
        return game
    }
    
    func fewestCubes() -> (red: Int, green: Int, blue: Int) {
        (
            red: self.rounds.max { round1, round2 in
                round1.red < round2.red
            }!.red,
            green: self.rounds.max { round1, round2 in
                round1.green < round2.green
            }!.green,
            blue: self.rounds.max { round1, round2 in
                round1.blue < round2.blue
            }!.blue
        )
    }
}

struct Round {
    var red: Int
    var green: Int
    var blue: Int

    init(red: Int = 0, green: Int = 0, blue: Int = 0) {
        self.red = red
        self.green = green
        self.blue = blue
    }
    
    static func parse<Str: StringProtocol>(_ input: Str) -> Self {
        let colors = input.split(whereSeparator: { $0 == "," })
            .map { color in
                let c = color.split(whereSeparator: { $0 == " " })
                let colorCountString = String(c[0])
                let colorName = String(c[1])
                let colorCount = Int(colorCountString)!
                return (colorName, colorCount)
            }
        var round = Round()
        for color in colors {
            switch (color.0) {
            case "red":
                round.red = color.1
            case "green":
                round.green = color.1
            case "blue":
                round.blue = color.1
            default:
                fatalError("unreachable")
            }
        }
        return round
    }
    
    func isPossible(with cubes: (red: Int, green: Int, blue: Int)) -> Bool {
        self.red <= cubes.red
            && self.green <= cubes.green
            && self.blue <= cubes.blue
    }
}

