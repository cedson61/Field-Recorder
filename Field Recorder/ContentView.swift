//
//  ContentView.swift
//  Field Recorder
//
//  Created by Chase Edson on 4/2/22.
//

import SwiftUI
import AVFoundation
import Pages




struct ContentView: View {
    //variables here!
        

    //define UI option arrays
    
    @State var pageIndex: Int = 1

    

    

    var body: some View {
        
        Pages(currentPage: $pageIndex, navigationOrientation: .horizontal, hasControl: false) {
            SettingsView()
            RecorderView()
            RecordingsView()
        }
        
    }

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
                .preferredColorScheme(.dark)
    .previewInterfaceOrientation(.portrait)
        }
    }

}
