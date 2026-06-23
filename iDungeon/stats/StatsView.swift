import SwiftUI

struct StatsView: View {
    var body: some View {
        FeatureShell(
            title: "Stats",
            subtitle: "캐릭터 코어 스탯과 장비 반영 결과를 보여준다.",
            symbol: "chart.bar.fill",
            tint: Color(red: 0.53, green: 0.88, blue: 0.60)
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Layout")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("HP, MP, 공격력, 방어력, 민첩 같은 속성을 카드형으로 나누기 좋다.")
                    .foregroundStyle(.white.opacity(0.75))
            }
        }
        .navigationTitle("Stats")
    }
}
