// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Advent-Of-Code-2023",
    platforms: [.macOS(.v13)],
    products: [],
    dependencies: [],
    targets: [
        .executableTarget(name: "day01", path: "day01", resources: [.process("input.txt")]),
        .executableTarget(name: "day02", path: "day02", resources: [.process("input.txt")]),
        .executableTarget(name: "day03", path: "day03", exclude: ["README.md"], resources: [.process("input.txt")]),
        .executableTarget(name: "day04", path: "day04", resources: [.process("input.txt")]),
        .executableTarget(name: "day05", path: "day05", resources: [.process("input.txt")]),
        .executableTarget(name: "day06", path: "day06", exclude: ["notes.txt"], resources: [.process("input.txt")]),
        .executableTarget(
            name: "day07",
            dependencies: ["day07_part1", "day07_part2"],
            path: "day07",
            exclude: ["part1.swift", "part2.swift"],
            sources: ["main.swift"],
            resources: [.process("input.txt")]),
        .target(name: "day07_part1", path: "day07", exclude: ["main.swift", "input.txt", "part2.swift"], sources: ["part1.swift"]),
        .target(name: "day07_part2", path: "day07", exclude: ["main.swift", "input.txt", "part1.swift"], sources: ["part2.swift"]),
    ]
)
