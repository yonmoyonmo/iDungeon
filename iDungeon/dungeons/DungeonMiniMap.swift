import SwiftUI

struct DungeonMiniMap: View {
    @ObservedObject var runtime: DungeonRuntime

    var body: some View {
        Canvas { context, size in
            let cellWidth = size.width / CGFloat(runtime.map.width)
            let cellHeight = size.height / CGFloat(runtime.map.height)

            for y in 0..<runtime.map.height {
                for x in 0..<runtime.map.width {
                    let rect = CGRect(
                        x: CGFloat(x) * cellWidth,
                        y: CGFloat(y) * cellHeight,
                        width: cellWidth,
                        height: cellHeight
                    )

                    let cell = GridPoint(x: x, y: y)
                    let color: Color
                    if cell == runtime.map.start {
                        color = Color(red: 0.27, green: 0.60, blue: 1.0)
                    } else if cell == runtime.map.exit {
                        color = Color(red: 1.0, green: 0.32, blue: 0.28)
                    } else if runtime.map.grid[y][x] == 1 {
                        color = .white.opacity(0.86)
                    } else {
                        color = .black.opacity(0.86)
                    }
                    context.fill(Path(rect), with: .color(color))
                }
            }

            let markerRect = CGRect(
                x: (runtime.viewPosition.x - 0.5) * cellWidth + cellWidth * 0.2,
                y: (runtime.viewPosition.y - 0.5) * cellHeight + cellHeight * 0.2,
                width: cellWidth * 0.6,
                height: cellHeight * 0.6
            )
            context.fill(
                Path(ellipseIn: markerRect),
                with: .color(Color(red: 0.06, green: 0.78, blue: 0.30))
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
    }
}
