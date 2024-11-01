//
//  BrandingImage.swift
//  GameMate
//
//  Created by Daniel on 12/21/23.
//

import SwiftUI

struct BrandingImage: View {
    var size: CGFloat = 150
    var body: some View {
        Image("fire")
            .resizable()
            .frame(width: size, height: size)
            .padding()
    }
}

struct BrandingImage_Previews: PreviewProvider {
    static var previews: some View {
        BrandingImage()
    }
}
