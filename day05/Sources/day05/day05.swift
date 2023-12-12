import Foundation

@main
struct day05 {
    static func main() throws {
		let input = try String(contentsOfFile: "input.txt")
        // let input = ""
        let almanac = Almanac.parse(input)
		print("part 1:", almanac.initialSeeds.map { seed in almanac.locationValue(for: seed) }.min()!)

		var seedGroups: [(Int, Int)] = Array(repeating: (-1, -1), count: almanac.initialSeeds.count / 2)
		for (i, seed) in almanac.initialSeeds.enumerated() {
			if i % 2 == 0 {
				seedGroups[i / 2].0 = seed
			} else {
				seedGroups[i / 2].1 = seed
			}
		}

		let part2 = seedGroups.flatMap { (group: (Int, Int)) in
			almanac.locationValues(for: group.0..<(group.0+group.1)).map { $0.lowerBound }
		}.min()!
		print("part 2:", part2)
		//almanac.locationValues(for: seedGroups[0]..<(seedGroups[0].0 + seedGroups[0].1))
    }
}

struct CategoryMap<Str: StringProtocol> {
    let source: Str
    let destination: Str

    init(from source: Str, to destination: Str) {
        self.source = source
        self.destination = destination
    }
}

extension CategoryMap: Hashable {}

struct MappedValues {
	let sourceRange: Range<Int>
    let destinationRange: Range<Int>

	static func parse(_ input: some StringProtocol) -> Self {
		let numbers = input.split(separator: " ").map { Int($0)! }
		return MappedValues(
			sourceRange: (numbers[1]..<(numbers[1]+numbers[2])),
			destinationRange: (numbers[0]..<(numbers[0]+numbers[2])) 
		)
	}

	func convert(_ value: Int) -> Int {
		return value + self.shiftValue
	}

	var shiftValue: Int {
		(self.destinationRange.lowerBound - self.sourceRange.lowerBound)
	}
}

extension MappedValues: Equatable {}

struct Almanac {
    let initialSeeds: [Int]
    let maps: [CategoryMap<Substring>:[MappedValues]]

    static func parse(_ input: some StringProtocol) -> Almanac {
		var initialSeeds: [Int]? = nil
		var currentCategoryMap: CategoryMap<Substring>? = nil
		var maps: [CategoryMap<Substring>:[MappedValues]] = [:]
		for line in input.split(whereSeparator: \.isNewline) {
			if line.starts(with: "seeds: ") {
				initialSeeds = (line as! Substring)
					.split(separator: ": ")[1]
					.split(separator: " ")
					.map { Int($0)! }
			} else if line.contains("map:") {
				let mapSplit = line.split(separator: "-to-")
				let source = mapSplit[0]
				let destination = mapSplit[1][mapSplit[1].startIndex..<mapSplit[1].firstIndex(of: " ")!]
				currentCategoryMap = CategoryMap(from: source as! Substring, to: destination as! Substring)
				maps[currentCategoryMap!] = []
			} else if line == "" {
				currentCategoryMap = nil
			} else {
				maps[currentCategoryMap!]!.append(MappedValues.parse(line))
			}
		}
		return Almanac(
			initialSeeds: initialSeeds!,
			maps: maps
		)
    }

	func convert(from source: Substring, to destination: Substring, value: Int) -> Int {
		let key = self.maps.keys.first(where: { catMap in
			catMap.source == source
		})!
		let mappedValues = self.maps[key]!
		if key.destination == destination {
			return (mappedValues
				.first(where: { $0.sourceRange.contains(value) })
				.map { $0.convert(value) }
			) ?? value
		} else {
			let convertedValue = (mappedValues
				.first(where: { $0.sourceRange.contains(value) })?.convert(value)
			) ?? value
			return self.convert(from: key.destination, to: destination, value: convertedValue)
		}
	}

	func locationValue(for seed: Int) -> Int {
		return self.convert(
			from: "seed",
			to: "location",
			value: seed
		)
	}

	func convert(from source: Substring, to destination: Substring, values: Range<Int>) -> [Range<Int>] {
		let key = self.maps.keys.first(where: { catMap in
			catMap.source == source
		})!
		let mappedValues = self.maps[key]!
		let mappedRanges: (mapped: [(Range<Int>, MappedValues)], unmapped: [Range<Int>]) = mappedValues
			.filter { $0.sourceRange.overlaps(values) }
			.reduce((mapped: [], unmapped: [values]) as (mapped: [(Range<Int>, MappedValues)], unmapped: [Range<Int>]),
				{ (_acc, mappedVal) in
					var acc = _acc
					let slices = acc.unmapped.map { $0.slice(with: mappedVal.sourceRange) }
					acc.unmapped = []
					for sliced in slices {
						acc.unmapped.append(contentsOf: sliced.excluded)
						if let included = sliced.included {
							acc.mapped.append((included, mappedVal))
						}
					}
					return acc
				}
			)
			// TODO: shift ranges
		if key.destination == destination {
			var convertedRanges: [Range<Int>] = []
			convertedRanges.append(contentsOf: mappedRanges.mapped
				.map { mappedRange in
					mappedRange.0.shift(by: mappedRange.1.shiftValue)
				})
			convertedRanges.append(contentsOf: mappedRanges.unmapped)
			return convertedRanges
		} else {
			var convertedRanges: [Range<Int>] = []
			convertedRanges.append(contentsOf: mappedRanges.mapped
				.flatMap { (mappedRange: (Range<Int>, MappedValues)) in
					self.convert(
						from: key.destination,
						to: destination,
						values: mappedRange.0.shift(by: mappedRange.1.shiftValue)
					)
				})
			convertedRanges.append(contentsOf: mappedRanges.unmapped.flatMap { self.convert(from: key.destination, to: destination, values: $0)})
			return convertedRanges
		}
	}

	func locationValues(for seeds: Range<Int>) -> [Range<Int>] {
		self.convert(from: "seed", to: "location", values: seeds)
	}
}

extension Range {
	func slice(with other: Self) -> (included: Self?, excluded: [Self]) {
		if !other.overlaps(self) {
			return (included: nil, excluded: [self])
		}

		if self.lowerBound >= other.lowerBound {
			if self.upperBound <= other.upperBound {
				return (included: self, excluded: [])
			} else {
				return (included: (self.lowerBound..<other.upperBound), excluded: [(other.upperBound..<self.upperBound)])
			}
		} else {
			if self.upperBound <= other.upperBound {
				return (included: (other.lowerBound..<self.upperBound), excluded: [(self.lowerBound..<other.lowerBound)])
			} else {
				return (included: other, [(self.lowerBound..<other.lowerBound), (other.upperBound..<self.upperBound)])
			}
		}
	}
}

extension Range where Element == Int {
	func shift(by val: Int) -> Self {
		return (self.lowerBound+val)..<(self.upperBound+val)
	}
}
