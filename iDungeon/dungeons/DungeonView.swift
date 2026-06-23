import SwiftUI

struct DungeonView: View {
    @StateObject private var runtime = DungeonRuntime()

    var body: some View {
        FeatureShell(
            title: "Dungeons",
            subtitle: "방 생성, 복도 연결, 1인칭 레이캐스트 뷰를 SwiftUI로 포팅했다.",
            symbol: "building.columns.fill",
            tint: Color(red: 0.38, green: 0.86, blue: 0.98)
        ) {
            VStack(alignment: .leading, spacing: 16) {
                RaycastViewport(runtime: runtime)
                    .frame(height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(.white.opacity(0.16), lineWidth: 1)
                    )

                HStack(alignment: .top, spacing: 16) {
                    DungeonMiniMap(runtime: runtime)
                        .frame(width: 124, height: 124)
                        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                    VStack(alignment: .leading, spacing: 10) {
                        StatLine(label: "Turn", value: "\(runtime.turn)")
                        StatLine(label: "Dir", value: runtime.playerDirection.label)
                        StatLine(label: "Cell", value: "\(runtime.playerCell.x), \(runtime.playerCell.y)")
                        StatLine(label: "Seed", value: "\(runtime.seed)")
                        StatLine(label: "Status", value: runtime.statusText)
                    }
                }

                DungeonControls(runtime: runtime)
            }
        }
        .navigationTitle("Dungeons")
    }
}
