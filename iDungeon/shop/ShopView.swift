import SwiftUI

struct ShopView: View {
    var body: some View {
        FeatureShell(
            title: "Shop",
            subtitle: "장비, 소비템, 골드 밸런스를 붙일 자리다.",
            symbol: "bag.fill",
            tint: Color(red: 0.99, green: 0.69, blue: 0.34)
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Prototype")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("상점 카테고리, 구매 버튼, 가격 패널을 여기서 정리하면 된다.")
                    .foregroundStyle(.white.opacity(0.75))
            }
        }
        .navigationTitle("Shop")
    }
}
