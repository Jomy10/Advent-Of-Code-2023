//
//  main.swift
//  
//
//  Created by Jonas Everaert on 20/12/2023.
//

import Foundation

let input = try String(contentsOf: Bundle.module.url(forResource: "input", withExtension: "txt")!)

let map = Map.parse(input)

// Part 1
var currentNode: String = "AAA"
var instructionCount = 0
while true {
    switch map.instructions[instructionCount % map.instructions.count] {
    case .left:
        currentNode = map.nodes[currentNode]!.left
    case .right:
        currentNode = map.nodes[currentNode]!.right
    }

    instructionCount += 1
    if currentNode == "ZZZ" {
        break
    }
}

print("part 1:", instructionCount)

// Part 2
var currentNodes = map.nodes.map { (k, v) in k }.filter { (k: String) in k.last == "A" }
instructionCount = 0
while true {
    switch map.instructions[instructionCount % map.instructions.count] {
    case .left:
        currentNodes = currentNodes.map { node in
            map.nodes[node]!.left
        }
    case .right:
        currentNodes = currentNodes.map { node in
            map.nodes[node]!.right
        }
    }
    
    instructionCount += 1
    if currentNodes.filter({ node in node.last == "Z" }).count == currentNodes.count {
        break
    }
}

print("part 2:", instructionCount)

struct Map {
    let instructions: [Instruction]
    let nodes: [String: (left: String, right: String)]
    
    enum Instruction {
        case left
        case right
    }
    
    static func parse(_ input: String) -> Self {
        let split = input.split(whereSeparator: \.isNewline)
        let instructions = split[0].map {
            if ($0 == "R") {
                return Instruction.right
            } else if ($0 == "L") {
                return Instruction.left
            } else {
                fatalError("Unexpected instruction '\($0)'")
            }
        }
        let nodes: [String: (left: String, right: String)] = split[1...].map { line in
            let split = line.split(separator: "=")
            let lr = split[1].split(separator: ",").map { (s: Substring) in
                s.trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacing("(", with: "")
                    .replacing(")", with: "")
            }
            return (
                (split[0] as Substring)
                    .trimmingCharacters(in: .whitespacesAndNewlines),
                (
                    left: lr[0],
                    right: lr[1]
                )
             )
        }.reduce(into: [:], { $0[$1.0] = $1.1 })
        
        return Map(instructions: instructions, nodes: nodes)
    }
}

extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
}
