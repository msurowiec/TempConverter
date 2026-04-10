//
//  ContentView.swift
//  TempConverter
//
//  Created by Matthew Surowiec on 4/10/26.
//

import SwiftUI

struct ContentView: View {
    @State private var inputText = ""
    @AppStorage("isFtoC") private var isFtoC = true
    @FocusState private var isInputFocused: Bool
    @State private var weather = WeatherService()
    @State private var weatherError: String?
    @State private var isHovering = false

    private var fromUnit: String { isFtoC ? "°F" : "°C" }
    private var toUnit: String   { isFtoC ? "°C" : "°F" }

    private var result: Double? {
        guard let v = Double(inputText) else { return nil }
        return isFtoC ? (v - 32) * 5 / 9 : v * 9 / 5 + 32
    }

    private var resultString: String {
        guard let r = result else { return "–" }
        return String(format: "%.2f", r)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.08, green: 0.08, blue: 0.14),
                         Color(red: 0.11, green: 0.11, blue: 0.20)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            HStack(spacing: 0) {
                // Location button
                Button {
                    weatherError = nil
                    Task {
                        do {
                            let temp = try await weather.fetchTemperature(inFahrenheit: isFtoC)
                            inputText = String(format: "%.1f", temp)
                        } catch {
                            weatherError = error.localizedDescription
                        }
                    }
                } label: {
                    Group {
                        if weather.isLoading {
                            ProgressView()
                                .controlSize(.small)
                                .tint(.white.opacity(0.4))
                        } else {
                            Image(systemName: weatherError != nil ? "exclamationmark.triangle" : "location.fill")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(weatherError != nil ? Color.orange.opacity(0.7) : .white.opacity(0.4))
                        }
                    }
                    .frame(width: 28, height: 28)
                    .background(.white.opacity(0.08), in: Circle())
                }
                .buttonStyle(.plain)
                .padding(.leading, 14)
                .help(weatherError ?? "Fill with current local temperature")

                // Input side
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    ZStack(alignment: .trailing) {
                        if inputText.isEmpty {
                            Text("0")
                                .font(.system(size: 36, weight: .thin, design: .rounded))
                                .foregroundStyle(.white.opacity(0.25))
                                .allowsHitTesting(false)
                        }
                        TextField("", text: $inputText)
                            .font(.system(size: 36, weight: .thin, design: .rounded))
                            .foregroundStyle(.white)
                            .textFieldStyle(.plain)
                            .multilineTextAlignment(.trailing)
                            .focused($isInputFocused)
                            .onChange(of: inputText) { _, newValue in
                                inputText = newValue.filter { $0.isNumber || $0 == "." || $0 == "-" }
                            }
                    }
                    .padding(.bottom, 4)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(.white.opacity(isInputFocused ? 0.4 : 0.15))
                            .frame(height: 1)
                    }

                    Text(fromUnit)
                        .font(.system(size: 20, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.leading, 20)

                // Swap button
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        isFtoC.toggle()
                        inputText = ""
                    }
                } label: {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.4))
                        .frame(width: 28, height: 28)
                        .background(.white.opacity(0.08), in: Circle())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 12)

                // Result side
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(resultString)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(result != nil
                            ? LinearGradient(colors: [Color(red: 0.4, green: 0.8, blue: 1.0),
                                                      Color(red: 0.3, green: 0.6, blue: 0.9)],
                                             startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [.white.opacity(0.35), .white.opacity(0.35)],
                                             startPoint: .leading, endPoint: .trailing))
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.2), value: resultString)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    Text(toUnit)
                        .font(.system(size: 20, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.bottom, 2)
                }
                .frame(maxWidth: .infinity)
                .padding(.trailing, 20)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(alignment: .topLeading) {
            if isHovering {
                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.15))
                            .frame(width: 22, height: 22)
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .buttonStyle(.plain)
                .padding(2)
                .transition(.opacity.animation(.easeInOut(duration: 0.15)))
            }
        }
        .onHover { isHovering = $0 }
        .frame(width: 460, height: 90)
        .onAppear {
            isInputFocused = true
            if let window = NSApplication.shared.windows.first {
                window.styleMask.remove(.titled)
                window.isMovableByWindowBackground = true
                window.hasShadow = true
                window.backgroundColor = .clear
                window.isOpaque = false
            }
        }
    }
}

#Preview {
    ContentView()
}
