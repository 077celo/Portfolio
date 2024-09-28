//
//  HeaderView.swift
//  Quake Tracker
//
//  Created by Marcelo on 09/09/24.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack {
            // LOGO
            Image(systemName: "globe")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .padding(.leading)
            
            Spacer()
            
            Image(systemName: "gearshape.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .padding(.trailing)
            
        }
        .frame(height: 40)
        }
    }


#Preview {
    HeaderView()
}
