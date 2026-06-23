import SwiftUI

struct DungeonMap {
    let width: Int
    let height: Int
    let grid: [[Int]]
    let start: GridPoint
    let exit: GridPoint
    let palette: DungeonPalette

    func isWalkable(_ point: GridPoint) -> Bool {
        guard point.y >= 0, point.y < height, point.x >= 0, point.x < width else {
            return false
        }
        return grid[point.y][point.x] == 1
    }
}

struct GridPoint: Equatable, Hashable {
    let x: Int
    let y: Int

    static func + (lhs: GridPoint, rhs: GridPoint) -> GridPoint {
        GridPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (lhs: GridPoint, rhs: GridPoint) -> GridPoint {
        GridPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

enum Facing: Int {
    case north = 0
    case east = 1
    case south = 2
    case west = 3

    var label: String {
        switch self {
        case .north: "N"
        case .east: "E"
        case .south: "S"
        case .west: "W"
        }
    }

    var vector: GridPoint {
        switch self {
        case .north: GridPoint(x: 0, y: -1)
        case .east: GridPoint(x: 1, y: 0)
        case .south: GridPoint(x: 0, y: 1)
        case .west: GridPoint(x: -1, y: 0)
        }
    }

    var leftVector: GridPoint {
        switch self {
        case .north: GridPoint(x: -1, y: 0)
        case .east: GridPoint(x: 0, y: -1)
        case .south: GridPoint(x: 1, y: 0)
        case .west: GridPoint(x: 0, y: 1)
        }
    }

    var rightVector: GridPoint {
        switch self {
        case .north: GridPoint(x: 1, y: 0)
        case .east: GridPoint(x: 0, y: 1)
        case .south: GridPoint(x: -1, y: 0)
        case .west: GridPoint(x: 0, y: -1)
        }
    }

    var angle: CGFloat {
        switch self {
        case .north: -.pi * 0.5
        case .east: 0
        case .south: .pi * 0.5
        case .west: .pi
        }
    }

    func turnLeft() -> Facing {
        Facing(rawValue: (rawValue + 3) % 4) ?? .north
    }

    func turnRight() -> Facing {
        Facing(rawValue: (rawValue + 1) % 4) ?? .north
    }
}

struct RectRoom {
    let x: Int
    let y: Int
    let width: Int
    let height: Int

    var center: GridPoint {
        GridPoint(x: x + width / 2, y: y + height / 2)
    }

    func intersects(_ other: RectRoom, padding: Int = 1) -> Bool {
        let expandedX = x - padding
        let expandedY = y - padding
        let expandedWidth = width + padding * 2
        let expandedHeight = height + padding * 2

        return expandedX < other.x + other.width &&
            expandedX + expandedWidth > other.x &&
            expandedY < other.y + other.height &&
            expandedY + expandedHeight > other.y
    }
}

struct RaycastHit {
    enum HitSide {
        case vertical
        case horizontal
    }

    let distance: CGFloat
    let side: HitSide
    let cell: GridPoint
}

struct DungeonPalette {
    let name: String
    let ceilingTop: Color
    let ceilingBottom: Color
    let floorTop: Color
    let floorBottom: Color
    let wall: Color
    let wallComponents: (red: CGFloat, green: CGFloat, blue: CGFloat)

    static let all: [DungeonPalette] = [
        DungeonPalette(
            name: "Abyss Blue",
            ceilingTop: Color(red: 0.05, green: 0.07, blue: 0.11),
            ceilingBottom: Color(red: 0.09, green: 0.12, blue: 0.18),
            floorTop: Color(red: 0.04, green: 0.05, blue: 0.07),
            floorBottom: Color(red: 0.07, green: 0.09, blue: 0.11),
            wall: Color(red: 0.22, green: 0.84, blue: 0.98),
            wallComponents: (0.22, 0.84, 0.98)
        ),
        DungeonPalette(
            name: "Ember Hall",
            ceilingTop: Color(red: 0.10, green: 0.06, blue: 0.05),
            ceilingBottom: Color(red: 0.15, green: 0.10, blue: 0.08),
            floorTop: Color(red: 0.07, green: 0.04, blue: 0.03),
            floorBottom: Color(red: 0.10, green: 0.07, blue: 0.05),
            wall: Color(red: 0.95, green: 0.48, blue: 0.20),
            wallComponents: (0.95, 0.48, 0.20)
        ),
        DungeonPalette(
            name: "Verdigris Vault",
            ceilingTop: Color(red: 0.04, green: 0.08, blue: 0.07),
            ceilingBottom: Color(red: 0.08, green: 0.13, blue: 0.11),
            floorTop: Color(red: 0.03, green: 0.05, blue: 0.05),
            floorBottom: Color(red: 0.06, green: 0.09, blue: 0.08),
            wall: Color(red: 0.31, green: 0.91, blue: 0.69),
            wallComponents: (0.31, 0.91, 0.69)
        ),
        DungeonPalette(
            name: "Royal Gloom",
            ceilingTop: Color(red: 0.07, green: 0.05, blue: 0.11),
            ceilingBottom: Color(red: 0.11, green: 0.09, blue: 0.17),
            floorTop: Color(red: 0.05, green: 0.03, blue: 0.08),
            floorBottom: Color(red: 0.08, green: 0.06, blue: 0.12),
            wall: Color(red: 0.74, green: 0.56, blue: 0.99),
            wallComponents: (0.74, 0.56, 0.99)
        ),
        DungeonPalette(
            name: "Moonstone",
            ceilingTop: Color(red: 0.08, green: 0.09, blue: 0.10),
            ceilingBottom: Color(red: 0.13, green: 0.14, blue: 0.16),
            floorTop: Color(red: 0.05, green: 0.06, blue: 0.06),
            floorBottom: Color(red: 0.09, green: 0.10, blue: 0.10),
            wall: Color(red: 0.86, green: 0.90, blue: 0.97),
            wallComponents: (0.86, 0.90, 0.97)
        ),
        DungeonPalette(
            name: "Sunken Gold",
            ceilingTop: Color(red: 0.07, green: 0.06, blue: 0.03),
            ceilingBottom: Color(red: 0.11, green: 0.09, blue: 0.05),
            floorTop: Color(red: 0.05, green: 0.04, blue: 0.02),
            floorBottom: Color(red: 0.08, green: 0.07, blue: 0.03),
            wall: Color(red: 0.94, green: 0.77, blue: 0.27),
            wallComponents: (0.94, 0.77, 0.27)
        ),
        DungeonPalette(
            name: "Crimson Keep",
            ceilingTop: Color(red: 0.10, green: 0.03, blue: 0.04),
            ceilingBottom: Color(red: 0.15, green: 0.06, blue: 0.07),
            floorTop: Color(red: 0.06, green: 0.02, blue: 0.03),
            floorBottom: Color(red: 0.09, green: 0.04, blue: 0.05),
            wall: Color(red: 0.92, green: 0.20, blue: 0.30),
            wallComponents: (0.92, 0.20, 0.30)
        ),
        DungeonPalette(
            name: "Toxic Bloom",
            ceilingTop: Color(red: 0.04, green: 0.07, blue: 0.03),
            ceilingBottom: Color(red: 0.07, green: 0.11, blue: 0.05),
            floorTop: Color(red: 0.03, green: 0.05, blue: 0.02),
            floorBottom: Color(red: 0.06, green: 0.08, blue: 0.04),
            wall: Color(red: 0.72, green: 0.93, blue: 0.18),
            wallComponents: (0.72, 0.93, 0.18)
        ),
        DungeonPalette(
            name: "Neon Shrine",
            ceilingTop: Color(red: 0.05, green: 0.03, blue: 0.08),
            ceilingBottom: Color(red: 0.09, green: 0.06, blue: 0.13),
            floorTop: Color(red: 0.04, green: 0.02, blue: 0.06),
            floorBottom: Color(red: 0.07, green: 0.04, blue: 0.10),
            wall: Color(red: 0.98, green: 0.29, blue: 0.84),
            wallComponents: (0.98, 0.29, 0.84)
        ),
        DungeonPalette(
            name: "Coral Crypt",
            ceilingTop: Color(red: 0.09, green: 0.05, blue: 0.05),
            ceilingBottom: Color(red: 0.13, green: 0.08, blue: 0.08),
            floorTop: Color(red: 0.06, green: 0.03, blue: 0.03),
            floorBottom: Color(red: 0.09, green: 0.06, blue: 0.05),
            wall: Color(red: 0.99, green: 0.56, blue: 0.44),
            wallComponents: (0.99, 0.56, 0.44)
        )
    ]

    static func random(using rng: inout SeededGenerator) -> DungeonPalette {
        let index = Int.random(in: 0..<all.count, using: &rng)
        return all[index]
    }
}

struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 0x9E37_79B9_7F4A_7C15 : seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

func safeComponent(_ value: CGFloat) -> CGFloat {
    if abs(value) >= 0.0001 {
        return value
    }
    return value < 0 ? -0.0001 : 0.0001
}
