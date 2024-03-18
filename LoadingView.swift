//
//  LoadingView.swift
//  TYTV.3
//
//  Created by Hayden Hubert on 2/13/24.
//
import SwiftUI

struct LoadingView: View {
    @State private var offsetY: CGFloat = 0
    @State private var offsetY2: CGFloat = 0
    @State private var offsetY3: CGFloat = 0
    @State private var direction: CGFloat = 1
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: 20, height: 20)
                .foregroundColor(.blue)
                .offset(y: offsetY)
            Circle()
                .frame(width: 20, height: 20)
                .foregroundColor(.blue)
                .offset(y: offsetY2)
            Circle()
                .frame(width: 20, height: 20)
                .foregroundColor(.blue)
                .offset(y: offsetY3)
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                self.offsetY = 20 * self.direction
            }
            withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true).delay(0.2)) {
                self.offsetY2 = 20 * -self.direction
            }
            withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true).delay(0.4)) {
                self.offsetY3 = 20 * self.direction
            }
        }
    }
}
