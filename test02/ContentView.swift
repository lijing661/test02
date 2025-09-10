//
//  ContentView.swift
//  test02
//
//  Created by Jane Lee on 9/2/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showPlayer = false

    var body: some View {
        VStack {
            Button(action: {
                showPlayer = true
            }) {
                Text("Play music")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0, green: 0, blue: 0.8), Color(red: 0, green: 0, blue: 0.6)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black, lineWidth: 1.5)
                    )
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.7), Color.clear]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .mask(RoundedRectangle(cornerRadius: 16))
                    )
                    .scaleEffect(1.05)
            }
            .fullScreenCover(isPresented: $showPlayer) {
                MusicPlayerView(showPlayer: $showPlayer)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
