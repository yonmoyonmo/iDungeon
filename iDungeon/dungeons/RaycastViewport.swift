import SwiftUI

struct RaycastViewport: View {
    @ObservedObject var runtime: DungeonRuntime

    private let rayCount = 180
    private let fov: CGFloat = 70 * .pi / 180
    private let maxDepth = 32

    var body: some View {
        Canvas { context, size in
            drawBackground(in: context, size: size)
            drawWalls(in: context, size: size)
            drawHUD(in: context, size: size)
        }
        .background(Color.black)
        .drawingGroup()
        .accessibilityLabel("Raycast dungeon viewport")
    }

    private func drawBackground(in context: GraphicsContext, size: CGSize) {
        let palette = runtime.map.palette
        let top = Path(CGRect(origin: .zero, size: CGSize(width: size.width, height: size.height * 0.48)))
        context.fill(top, with: .linearGradient(
            Gradient(colors: [palette.ceilingTop, palette.ceilingBottom]),
            startPoint: .zero,
            endPoint: CGPoint(x: 0, y: size.height * 0.48)
        ))

        let bottom = Path(CGRect(x: 0, y: size.height * 0.48, width: size.width, height: size.height * 0.52))
        context.fill(bottom, with: .linearGradient(
            Gradient(colors: [palette.floorTop, palette.floorBottom]),
            startPoint: CGPoint(x: 0, y: size.height * 0.48),
            endPoint: CGPoint(x: 0, y: size.height)
        ))
    }

    private func drawWalls(in context: GraphicsContext, size: CGSize) {
        let palette = runtime.map.palette
        let position = runtime.viewPosition
        let baseAngle = runtime.viewAngle
        let plane = (size.width * 0.5) / tan(fov * 0.5)

        for rayIndex in 0..<rayCount {
            let fraction = CGFloat(rayIndex) / CGFloat(max(rayCount - 1, 1))
            let normalized = fraction * 2 - 1
            let angle = baseAngle + normalized * (fov * 0.5)
            let direction = CGPoint(x: cos(angle), y: sin(angle))

            let hit = castRay(from: position, direction: direction)
            var corrected = Swift.max(hit.distance * cos(angle - baseAngle), 0.0001)
            if corrected.isNaN || corrected.isInfinite {
                corrected = CGFloat(maxDepth)
            }

            let wallHeight = min((1 / corrected) * plane, size.height * 1.2)
            let x = CGFloat(rayIndex) / CGFloat(rayCount) * size.width
            let rect = CGRect(
                x: floor(x),
                y: size.height * 0.5 - wallHeight * 0.5,
                width: size.width / CGFloat(rayCount) + 1.2,
                height: wallHeight
            )

            let sideShade: CGFloat = hit.side == .horizontal ? 0.72 : 1.0
            let distanceShade = max(0.15, min(1.0, 1.15 - corrected * 0.10))
            let brightness = distanceShade * sideShade * cellBrightness(hit.cell)
            let color = Color(
                red: palette.wallComponents.red * brightness,
                green: palette.wallComponents.green * brightness,
                blue: palette.wallComponents.blue * brightness
            )

            context.fill(Path(rect), with: .color(color))
        }
    }

    private func drawHUD(in context: GraphicsContext, size: CGSize) {
        let caption = Text("START \(runtime.map.start.x),\(runtime.map.start.y)  EXIT \(runtime.map.exit.x),\(runtime.map.exit.y)")
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(.white.opacity(0.7))
        context.draw(caption, at: CGPoint(x: size.width * 0.5, y: size.height - 18))
    }

    private func castRay(from position: CGPoint, direction: CGPoint) -> RaycastHit {
        var mapX = Int(floor(position.x))
        var mapY = Int(floor(position.y))

        let deltaX = direction.x == 0 ? CGFloat.greatestFiniteMagnitude : abs(1 / direction.x)
        let deltaY = direction.y == 0 ? CGFloat.greatestFiniteMagnitude : abs(1 / direction.y)

        let stepX = direction.x < 0 ? -1 : 1
        let stepY = direction.y < 0 ? -1 : 1

        var sideDistX: CGFloat
        var sideDistY: CGFloat

        if direction.x < 0 {
            sideDistX = (position.x - CGFloat(mapX)) * deltaX
        } else {
            sideDistX = (CGFloat(mapX + 1) - position.x) * deltaX
        }

        if direction.y < 0 {
            sideDistY = (position.y - CGFloat(mapY)) * deltaY
        } else {
            sideDistY = (CGFloat(mapY + 1) - position.y) * deltaY
        }

        var hitSide: RaycastHit.HitSide = .vertical

        for _ in 0..<maxDepth {
            if sideDistX < sideDistY {
                sideDistX += deltaX
                mapX += stepX
                hitSide = .vertical
            } else {
                sideDistY += deltaY
                mapY += stepY
                hitSide = .horizontal
            }

            let cell = GridPoint(x: mapX, y: mapY)
            if !runtime.map.isWalkable(cell) {
                let distance: CGFloat
                if hitSide == .vertical {
                    distance = (CGFloat(mapX) - position.x + (1 - CGFloat(stepX)) * 0.5) / safeComponent(direction.x)
                } else {
                    distance = (CGFloat(mapY) - position.y + (1 - CGFloat(stepY)) * 0.5) / safeComponent(direction.y)
                }
                return RaycastHit(distance: abs(distance), side: hitSide, cell: cell)
            }
        }

        return RaycastHit(distance: CGFloat(maxDepth), side: hitSide, cell: GridPoint(x: mapX, y: mapY))
    }

    private func cellBrightness(_ cell: GridPoint) -> CGFloat {
        let hash = abs((cell.x * 73_856_093) ^ (cell.y * 19_349_663))
        let normalized = CGFloat(hash % 1000) / 1000
        return 0.90 + normalized * 0.15
    }
}
