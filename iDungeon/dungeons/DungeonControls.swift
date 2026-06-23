import SwiftUI

struct DungeonControls: View {
    @ObservedObject var runtime: DungeonRuntime

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ControlButton("좌회전") { runtime.turnLeft() }
                    .disabled(runtime.isAnimating)
                ControlButton("앞") { runtime.moveForward() }
                    .disabled(runtime.isAnimating)
                ControlButton("우회전") { runtime.turnRight() }
                    .disabled(runtime.isAnimating)
            }

            HStack(spacing: 12) {
                ControlButton("왼") { runtime.strafeLeft() }
                    .disabled(runtime.isAnimating)
                ControlButton("뒤") { runtime.moveBack() }
                    .disabled(runtime.isAnimating)
                ControlButton("오") { runtime.strafeRight() }
                    .disabled(runtime.isAnimating)
            }

            Button {
                runtime.regenerate()
            } label: {
                Text("새 던전 생성")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0.22, green: 0.76, blue: 0.96),
                                Color(red: 0.14, green: 0.40, blue: 0.84)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
            }
            .buttonStyle(.plain)
            .disabled(runtime.isAnimating)
        }
    }
}

struct StatLine: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.56))
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

struct ControlButton: View {
    @Environment(\.isEnabled) private var isEnabled

    let title: String
    let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(.white.opacity(0.14), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1.0 : 0.55)
    }
}
