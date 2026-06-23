import SwiftUI

struct SkillsView: View {
    var body: some View {
        FeatureShell(
            title: "Skills",
            subtitle: "액티브/패시브 스킬 트리와 잠금 해제를 붙일 수 있다.",
            symbol: "sparkles",
            tint: Color(red: 1.0, green: 0.49, blue: 0.62)
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Structure")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("스킬 노드, 코스트, 설명 패널을 조합하는 쪽으로 확장하면 된다.")
                    .foregroundStyle(.white.opacity(0.75))
            }
        }
        .navigationTitle("Skills")
    }
}
