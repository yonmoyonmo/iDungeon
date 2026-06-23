import Combine
import SwiftUI

@MainActor
final class DungeonRuntime: ObservableObject {
    @Published private(set) var map: DungeonMap
    @Published private(set) var playerCell: GridPoint
    @Published private(set) var playerDirection: Facing
    @Published private(set) var viewPosition: CGPoint
    @Published private(set) var viewAngle: CGFloat
    @Published private(set) var isTurning = false
    @Published private(set) var isMoving = false
    @Published private(set) var turn: Int = 0
    @Published private(set) var statusText: String = "Ready"

    private(set) var seed: Int
    private let generator = RandomDungeonGenerator()
    private var rotationTask: Task<Void, Never>?
    private var movementTask: Task<Void, Never>?
    private let turnAnimationDuration: Duration = .milliseconds(220)
    private let turnAnimationSteps = 14
    private let moveAnimationDuration: Duration = .milliseconds(170)
    private let moveAnimationSteps = 10

    var isAnimating: Bool {
        isTurning || isMoving
    }

    init() {
        let freshSeed = Int.random(in: 1...999_999)
        seed = freshSeed
        let initialMap = generator.generate(width: 21, height: 21, seed: freshSeed, corridorDensity: 0.7)
        map = initialMap
        playerCell = initialMap.start
        playerDirection = .north
        viewPosition = DungeonRuntime.centerPoint(for: initialMap.start)
        viewAngle = Facing.north.angle
    }

    func regenerate() {
        guard !isAnimating else { return }
        seed = Int.random(in: 1...999_999)
        let nextMap = generator.generate(width: 21, height: 21, seed: seed, corridorDensity: 0.7)
        map = nextMap
        playerCell = nextMap.start
        playerDirection = .north
        viewPosition = DungeonRuntime.centerPoint(for: nextMap.start)
        viewAngle = Facing.north.angle
        turn = 0
        statusText = "New dungeon"
    }

    func turnLeft() {
        beginTurn(toward: playerDirection.turnLeft(), status: "Turn left")
    }

    func turnRight() {
        beginTurn(toward: playerDirection.turnRight(), status: "Turn right")
    }

    func moveForward() {
        guard !isAnimating else { return }
        attemptMove(to: playerCell + playerDirection.vector, status: "Forward")
    }

    func moveBack() {
        guard !isAnimating else { return }
        attemptMove(to: playerCell - playerDirection.vector, status: "Back")
    }

    func strafeLeft() {
        guard !isAnimating else { return }
        attemptMove(to: playerCell + playerDirection.leftVector, status: "Left")
    }

    func strafeRight() {
        guard !isAnimating else { return }
        attemptMove(to: playerCell + playerDirection.rightVector, status: "Right")
    }

    private func beginTurn(toward targetDirection: Facing, status: String) {
        guard !isAnimating else { return }

        rotationTask?.cancel()
        isTurning = true
        statusText = status

        let startAngle = viewAngle
        let targetAngle = targetDirection.angle
        let delta = shortestAngularDelta(from: startAngle, to: targetAngle)

        rotationTask = Task { [weak self] in
            guard let self else { return }

            for step in 1...self.turnAnimationSteps {
                guard !Task.isCancelled else { return }
                let progress = CGFloat(step) / CGFloat(self.turnAnimationSteps)
                self.viewAngle = normalizeAngle(startAngle + delta * progress)
                try? await Task.sleep(for: self.turnAnimationDuration / self.turnAnimationSteps)
            }

            self.playerDirection = targetDirection
            self.viewAngle = normalizeAngle(targetAngle)
            self.turn += 1
            self.isTurning = false
            self.statusText = status
            self.rotationTask = nil
        }
    }

    private func attemptMove(to cell: GridPoint, status: String) {
        guard map.isWalkable(cell) else {
            statusText = "Bumped into wall"
            turn += 1
            return
        }

        movementTask?.cancel()
        isMoving = true
        statusText = status

        let startPosition = viewPosition
        let targetPosition = DungeonRuntime.centerPoint(for: cell)

        movementTask = Task { [weak self] in
            guard let self else { return }

            for step in 1...self.moveAnimationSteps {
                guard !Task.isCancelled else { return }
                let progress = CGFloat(step) / CGFloat(self.moveAnimationSteps)
                self.viewPosition = CGPoint(
                    x: startPosition.x + (targetPosition.x - startPosition.x) * progress,
                    y: startPosition.y + (targetPosition.y - startPosition.y) * progress
                )
                try? await Task.sleep(for: self.moveAnimationDuration / self.moveAnimationSteps)
            }

            self.playerCell = cell
            self.viewPosition = targetPosition
            self.turn += 1
            self.isMoving = false
            self.statusText = cell == self.map.exit ? "Exit reached" : status
            self.movementTask = nil
        }
    }

    private func shortestAngularDelta(from start: CGFloat, to end: CGFloat) -> CGFloat {
        var delta = normalizeAngle(end) - normalizeAngle(start)
        if delta > .pi {
            delta -= .pi * 2
        } else if delta < -.pi {
            delta += .pi * 2
        }
        return delta
    }

    private func normalizeAngle(_ angle: CGFloat) -> CGFloat {
        var normalized = angle.truncatingRemainder(dividingBy: .pi * 2)
        if normalized <= -.pi {
            normalized += .pi * 2
        } else if normalized > .pi {
            normalized -= .pi * 2
        }
        return normalized
    }

    private static func centerPoint(for cell: GridPoint) -> CGPoint {
        CGPoint(x: CGFloat(cell.x) + 0.5, y: CGFloat(cell.y) + 0.5)
    }
}
