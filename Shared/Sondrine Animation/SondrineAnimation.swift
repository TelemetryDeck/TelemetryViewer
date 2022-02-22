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
            HStack {
                Spacer()
                
                ZStack {
                    ThreeCirclesInATrenchcode(scale: min(geometry.size.width, geometry.size.height))
                        .scaledToFit()
                        .frame(width: min(geometry.size.width, geometry.size.height), height: min(geometry.size.width, geometry.size.height), alignment: .center)
                        .position(x: 0.305*min(geometry.size.width, geometry.size.height), y: 0.160*min(geometry.size.width, geometry.size.height))
                    ThreeCirclesInATrenchcode(scale: min(geometry.size.width, geometry.size.height))
                        .scaledToFit()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .position(x: 0.163*min(geometry.size.width, geometry.size.height), y: 0.185*min(geometry.size.width, geometry.size.height))
                    Image("sondrine_loading").resizable().scaledToFit().frame(width: min(geometry.size.width, geometry.size.height), height: min(geometry.size.width, geometry.size.height))
                }
                .frame(width: min(geometry.size.width, geometry.size.height), height: min(geometry.size.width, geometry.size.height), alignment: .center)
                Spacer()
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

struct SondrineAnimation_Previews: PreviewProvider {
    static var previews: some View {
        SondrineAnimation()
            .frame(width: 500, height: 200, alignment: .center)
    }
}
