import SwiftUI

struct HomeRootView: View {
    @State private var path: [AppDestination] = []

    private let columns = [
        GridItem(.flexible(), spacing: 18),
        GridItem(.flexible(), spacing: 18)
    ]

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                HomeBackgroundView()

                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("iDungeon")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Choose your next screen.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.72))
                    }

                    LazyVGrid(columns: columns, spacing: 18) {
                        ForEach(AppDestination.allCases) { destination in
                            Button {
                                path.append(destination)
                            } label: {
                                HomeIconButton(destination: destination)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Spacer()

                    DockCardView()
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 16)
            }
            .navigationBarHidden(true)
            .navigationDestination(for: AppDestination.self) { destination in
                switch destination {
                case .dungeons:
                    DungeonView()
                case .shop:
                    ShopView()
                case .stats:
                    StatsView()
                case .skills:
                    SkillsView()
                }
            }
        }
    }
}

private struct HomeIconButton: View {
    let destination: AppDestination

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.white.opacity(0.14))
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.28), lineWidth: 1)
                    )
                    .frame(height: 112)

                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                destination.tint.opacity(0.95),
                                destination.tint.opacity(0.45)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                    .shadow(color: destination.tint.opacity(0.28), radius: 18, y: 12)
                    .overlay {
                        Image(systemName: destination.symbol)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.white)
                    }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(destination.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(destination.subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.68))
            }
            .padding(.horizontal, 4)
        }
    }
}

private struct DockCardView: View {
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(.white.opacity(0.16), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text("Prototype Hub")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Splash 이후 이 홈이 메인 허브가 된다.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.22), lineWidth: 1)
        )
    }
}

private struct HomeBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.10, blue: 0.20),
                    Color(red: 0.07, green: 0.17, blue: 0.25),
                    Color(red: 0.11, green: 0.11, blue: 0.14)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.18))
                .frame(width: 280, height: 280)
                .blur(radius: 60)
                .offset(x: -120, y: -220)

            Circle()
                .fill(Color(red: 0.38, green: 0.86, blue: 0.98).opacity(0.24))
                .frame(width: 260, height: 260)
                .blur(radius: 48)
                .offset(x: 140, y: -120)

            Circle()
                .fill(Color(red: 1.0, green: 0.49, blue: 0.62).opacity(0.18))
                .frame(width: 300, height: 300)
                .blur(radius: 52)
                .offset(x: 100, y: 280)
        }
    }
}
