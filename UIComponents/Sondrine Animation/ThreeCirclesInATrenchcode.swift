//
//  Three Circles in a Trenchcode.swift
//  Landmarks
//
//  Created by Charlotte Böhm on 19.06.21.
//

import SwiftUI

struct ThreeCirclesInATrenchcode: View {
    let scale: Double
    var body: some View {
        ZStack{
            AnimatedCircle(delay: 0, scale: scale)
            AnimatedCircle(delay: -0.6, scale: scale)
            AnimatedCircle(delay: -1.2, scale: scale)
            AnimatedCircle(delay: -1.8, scale: scale)
            AnimatedCircle(delay: -2.4, scale: scale)
        }
    }
}

struct ThreeCirclesInATrenchcode_Previews: PreviewProvider {
    static var previews: some View {
        ThreeCirclesInATrenchcode(scale: 100)
    }
}
