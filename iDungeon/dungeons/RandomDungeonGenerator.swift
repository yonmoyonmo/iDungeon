import Foundation

final class RandomDungeonGenerator {
    private let wall = 0
    private let floor = 1
    private let maxAttempts = 20
    private let roomAttempts = 40
    private let roomMin = 3
    private let roomMax = 7

    func generate(width: Int, height: Int, seed: Int, corridorDensity: Double) -> DungeonMap {
        var adjustedWidth = max(width, 7)
        var adjustedHeight = max(height, 7)
        if adjustedWidth.isMultiple(of: 2) { adjustedWidth += 1 }
        if adjustedHeight.isMultiple(of: 2) { adjustedHeight += 1 }

        let density = max(0.2, min(1.0, corridorDensity))
        var paletteRNG = SeededGenerator(seed: UInt64(seed) ^ 0xA5A5_A5A5_A5A5_A5A5)
        let palette = DungeonPalette.random(using: &paletteRNG)

        for attempt in 0..<maxAttempts {
            var rng = SeededGenerator(seed: UInt64(seed + attempt * 991))
            var grid = Array(repeating: Array(repeating: wall, count: adjustedWidth), count: adjustedHeight)
            var rooms: [RectRoom] = []
            let attempts = Int(ceil(Double(roomAttempts) * density))

            attemptRooms(grid: &grid, rooms: &rooms, rng: &rng, attempts: attempts)
            guard !rooms.isEmpty else { continue }

            connectRooms(grid: &grid, rooms: rooms, rng: &rng)

            let start = rooms[0].center
            guard let exit = farthestFloor(in: grid, from: start) else { continue }
            guard isValid(grid: grid, start: start, exit: exit) else { continue }

            return DungeonMap(
                width: adjustedWidth,
                height: adjustedHeight,
                grid: grid,
                start: start,
                exit: exit,
                palette: palette
            )
        }

        var fallback = Array(repeating: Array(repeating: wall, count: 7), count: 7)
        carve(room: RectRoom(x: 2, y: 2, width: 3, height: 3), in: &fallback)
        return DungeonMap(
            width: 7,
            height: 7,
            grid: fallback,
            start: GridPoint(x: 3, y: 3),
            exit: GridPoint(x: 4, y: 3),
            palette: palette
        )
    }

    private func attemptRooms(
        grid: inout [[Int]],
        rooms: inout [RectRoom],
        rng: inout SeededGenerator,
        attempts: Int
    ) {
        let width = grid[0].count
        let height = grid.count

        for _ in 0..<attempts {
            let roomWidth = Int.random(in: roomMin...roomMax, using: &rng)
            let roomHeight = Int.random(in: roomMin...roomMax, using: &rng)
            let roomX = Int.random(in: 1...(width - roomWidth - 2), using: &rng)
            let roomY = Int.random(in: 1...(height - roomHeight - 2), using: &rng)
            let candidate = RectRoom(x: roomX, y: roomY, width: roomWidth, height: roomHeight)

            guard rooms.allSatisfy({ !candidate.intersects($0) }) else { continue }
            carve(room: candidate, in: &grid)
            rooms.append(candidate)
        }
    }

    private func carve(room: RectRoom, in grid: inout [[Int]]) {
        for y in room.y..<(room.y + room.height) {
            for x in room.x..<(room.x + room.width) {
                grid[y][x] = floor
            }
        }
    }

    private func connectRooms(grid: inout [[Int]], rooms: [RectRoom], rng: inout SeededGenerator) {
        guard rooms.count > 1 else { return }

        for index in 1..<rooms.count {
            let a = rooms[index - 1].center
            let b = rooms[index].center
            if Bool.random(using: &rng) {
                digHorizontal(grid: &grid, from: a.x, to: b.x, y: a.y)
                digVertical(grid: &grid, from: a.y, to: b.y, x: b.x)
            } else {
                digVertical(grid: &grid, from: a.y, to: b.y, x: a.x)
                digHorizontal(grid: &grid, from: a.x, to: b.x, y: b.y)
            }
        }
    }

    private func digHorizontal(grid: inout [[Int]], from x1: Int, to x2: Int, y: Int) {
        for x in min(x1, x2)...max(x1, x2) {
            if inBounds(grid: grid, point: GridPoint(x: x, y: y)) {
                grid[y][x] = floor
            }
        }
    }

    private func digVertical(grid: inout [[Int]], from y1: Int, to y2: Int, x: Int) {
        for y in min(y1, y2)...max(y1, y2) {
            if inBounds(grid: grid, point: GridPoint(x: x, y: y)) {
                grid[y][x] = floor
            }
        }
    }

    private func isValid(grid: [[Int]], start: GridPoint, exit: GridPoint) -> Bool {
        let width = grid[0].count
        let height = grid.count

        for x in 0..<width {
            if grid[0][x] != wall || grid[height - 1][x] != wall {
                return false
            }
        }

        for y in 0..<height {
            if grid[y][0] != wall || grid[y][width - 1] != wall {
                return false
            }
        }

        guard inBounds(grid: grid, point: start), grid[start.y][start.x] == floor else { return false }
        guard inBounds(grid: grid, point: exit), grid[exit.y][exit.x] == floor else { return false }
        return bfsDistance(grid: grid, from: start, to: exit) != nil
    }

    private func farthestFloor(in grid: [[Int]], from start: GridPoint) -> GridPoint? {
        guard inBounds(grid: grid, point: start), grid[start.y][start.x] == floor else { return nil }

        var queue = [start]
        var visited: [GridPoint: Int] = [start: 0]
        var index = 0
        var farthest = start
        var farthestDistance = 0

        while index < queue.count {
            let current = queue[index]
            index += 1
            let distance = visited[current] ?? 0

            if distance > farthestDistance {
                farthestDistance = distance
                farthest = current
            }

            for neighbor in neighbors(of: current) where inBounds(grid: grid, point: neighbor) && grid[neighbor.y][neighbor.x] == floor {
                guard visited[neighbor] == nil else { continue }
                visited[neighbor] = distance + 1
                queue.append(neighbor)
            }
        }

        return farthest
    }

    private func bfsDistance(grid: [[Int]], from start: GridPoint, to goal: GridPoint) -> Int? {
        var queue = [start]
        var visited: [GridPoint: Int] = [start: 0]
        var index = 0

        while index < queue.count {
            let current = queue[index]
            index += 1

            if current == goal {
                return visited[current]
            }

            let distance = visited[current] ?? 0
            for neighbor in neighbors(of: current) where inBounds(grid: grid, point: neighbor) && grid[neighbor.y][neighbor.x] == floor {
                guard visited[neighbor] == nil else { continue }
                visited[neighbor] = distance + 1
                queue.append(neighbor)
            }
        }

        return nil
    }

    private func neighbors(of point: GridPoint) -> [GridPoint] {
        [
            GridPoint(x: point.x + 1, y: point.y),
            GridPoint(x: point.x - 1, y: point.y),
            GridPoint(x: point.x, y: point.y + 1),
            GridPoint(x: point.x, y: point.y - 1)
        ]
    }

    private func inBounds(grid: [[Int]], point: GridPoint) -> Bool {
        point.y >= 0 && point.y < grid.count && point.x >= 0 && point.x < grid[0].count
    }
}
