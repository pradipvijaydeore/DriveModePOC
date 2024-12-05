//
//  DriveModeView.swift
//  DriveModePOC
//
//  Created by Pradip on 26/11/24.
//

import SwiftUI

struct DriveModeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Drive Mode Enabled")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            HStack(spacing: 40) {
                Button(action: { /* Previous Track */ }) {
                    Image(systemName: "backward.fill")
                        .font(.largeTitle)
                }
                
                Button(action: { /* Play/Pause */ }) {
                    Image(systemName: "playpause.fill")
                        .font(.largeTitle)
                }
                
                Button(action: { /* Next Track */ }) {
                    Image(systemName: "forward.fill")
                        .font(.largeTitle)
                }
            }
            
            Slider(value: .constant(0.5)) { /* Volume Control */ }
                .padding()
        }
        .padding()
    }
}
