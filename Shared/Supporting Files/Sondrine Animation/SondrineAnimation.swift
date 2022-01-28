//
//  Sondrine Animation.swift
//  Landmarks
//
//  Created by Charlotte Böhm on 19.06.21.
//

import SwiftUI

struct SondrineAnimation: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ThreeCirclesInATrenchcode(scale:min(geometry.size.width, geometry.size.height))
                    .scaledToFit()
                    .frame(width: min(geometry.size.width, geometry.size.height), height: min(geometry.size.width, geometry.size.height), alignment: .center)
                    .position(x: 0.305*min(geometry.size.width, geometry.size.height), y: 0.165*min(geometry.size.width, geometry.size.height))
                ThreeCirclesInATrenchcode(scale:min(geometry.size.width, geometry.size.height))
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .position(x: 0.163*geometry.size.width, y: 0.175*geometry.size.height)
                Image("sondrine_flat_no_circle").resizable().scaledToFit().frame(width: min(geometry.size.width, geometry.size.height), height: min(geometry.size.width, geometry.size.height), alignment: .center)
            }
            .frame(width: min(geometry.size.width, geometry.size.height), height: min(geometry.size.width, geometry.size.height), alignment: .center)
        }
        .frame(maxHeight: 450)
    }
}

struct SondrineAnimation_Previews: PreviewProvider {
    static var previews: some View {
        SondrineAnimation()
    }
}
