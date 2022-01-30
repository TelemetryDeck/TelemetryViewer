//
//  Animated Circle.swift
//  Landmarks
//
//  Created by Charlotte Böhm on 19.06.21.
//

import SwiftUI

struct AnimatedCircle: View {
    @State var isAtMaxScale = false
    let delay: CGFloat
    let scale: Double
 
    private let maxScale: CGFloat = 1
    private let animation = Animation.easeInOut(duration: 3).repeatForever(autoreverses: false)
    
    var body: some View {
        Circle()
            .stroke(Color.gray, lineWidth: 10*scale/200)
//            .padding(60)
            .scaleEffect(isAtMaxScale ? maxScale*scale/200 : 0.005)
            .opacity(isAtMaxScale ? 0 : 0.75)
            .onAppear {
                withAnimation(self.animation.delay(delay), {
                    self.isAtMaxScale.toggle()
                })
            }
    }
}

struct Animated_Circle_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedCircle(delay: 0.5, scale: 200)
    }
}
