//
//  WelcomeView.swift
//  greatness
//
//  Created by Сулейман Курбанов on 31.03.2026.
//

import SwiftUI

struct WelcomeView: View {
    @State private var isAnimated = false
    var onStart: () -> Void

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Headline
                VStack(spacing: 16) {
                    Text("Сейчас тебе\nможет быть тяжело")
                        .font(.system(size: 34, weight: .bold, design: .default))
                        .multilineTextAlignment(.center)
                        .opacity(isAnimated ? 1 : 0)
                        .offset(y: isAnimated ? 0 : 20)

                    Text("Иногда человек устаёт, теряет ритм,\nоткладывает важное и не понимает,\nс чего начать.\n\nЭто нормально.")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .opacity(isAnimated ? 1 : 0)
                        .offset(y: isAnimated ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.2), value: isAnimated)
                }
                .padding(.horizontal, 32)

                Spacer()

                // Key insight
                VStack(spacing: 8) {
                    Text("Каждый день можно улучшаться на")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.tertiary)

                    Text("0.25% — 1%")
                        .font(.system(size: 28, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.primary)
                }
                .opacity(isAnimated ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.4), value: isAnimated)

                Spacer()

                // CTA Button
                Button(action: onStart) {
                    Text("Начать путь")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color(.systemBackground))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
                .opacity(isAnimated ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.6), value: isAnimated)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                isAnimated = true
            }
        }
    }
}

#Preview {
    WelcomeView(onStart: {})
}
