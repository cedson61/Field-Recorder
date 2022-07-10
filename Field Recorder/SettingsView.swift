//
//  SettingsView.swift
//  Field Recorder
//
//  Created by Chase Edson on 7/9/22.
//

import SwiftUI

struct SettingsView: View {
    
    @State private var metronomeEnabled = true
    
    var timeSignatures = ["4/4", "3/4", "6/8"]
    @State private var selectedTimeSignature = 0
    @State private var selectedBPM = 120
    @State private var text = ""
    
    var inputDevices = ["Internal Microphone"]
    @State private var selectedInputDevice = 0
    
    
    
    var body: some View {
        NavigationView{
            VStack{
                    Text("Settings")
                        .font(.title)
                        .padding([.top], 50)
                    Form{
                        Section("Tools") {
                            NavigationLink(destination: TunerView()) {
                                    Text("Tuner")
                            }

                            Toggle("Metronome", isOn: $metronomeEnabled).toggleStyle(CheckmarkToggleStyle())
                            if(metronomeEnabled){
                                VStack(alignment: .trailing){
                                    HStack{
                                        Text("Time Signature").font(.subheadline).frame(maxWidth: .infinity, alignment: .leading)
                                        Picker(selection: $selectedTimeSignature, label: Text("Type")) {
                                            ForEach(0 ..< timeSignatures.count) {
                                                Text(self.timeSignatures[$0]).tag($0)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle()).multilineTextAlignment(.trailing)
                                        
                                    }
                                    
                                    HStack {
                                        Text("BPM").font(.subheadline)
                                        TextField("BPM", text: Binding(
                                            get: { String(selectedBPM) },
                                            set: { selectedBPM = Int($0) ?? 0 }
                                        ))
                                        .keyboardType(.numberPad)
                                        .multilineTextAlignment(.trailing)
                                        
                                    }
                                    
                                    
                                }
                            }
                            
                        }
                        Section("Configuration") {
                            VStack(alignment: .trailing){
                                HStack{
                                    Text("Input Device").font(.subheadline).frame(maxWidth: .infinity, alignment: .leading)
                                    Picker(selection: $selectedInputDevice, label: Text("Input Device")) {
                                        ForEach(0 ..< inputDevices.count) {
                                            Text(self.inputDevices[$0]).tag($0)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle()).multilineTextAlignment(.trailing)
                                }
                            }

                        }
                        Section("Information") {
                            NavigationLink(destination: Text("Field Recorder - designed and tested in seattle, wa")) {
                                Text("About")
                            }

                        }
                    }
                    Spacer()
 
                
            }
        }
        
    }
    
    
    
    
    
}

struct CheckmarkToggleStyle: ToggleStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Rectangle()
                .foregroundColor(configuration.isOn ? .green : .red)
                .frame(width: 51, height: 31, alignment: .center)
                .overlay(
                    Circle()
                        .foregroundColor(.white)
                        .padding(.all, 3)
                        .overlay(
                            Image(systemName: configuration.isOn ? "checkmark" : "xmark")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .font(Font.title.weight(.black))
                                .frame(width: 8, height: 8, alignment: .center)
                                .foregroundColor(configuration.isOn ? .green : .red)
                        )
                        .offset(x: configuration.isOn ? 11 : -11, y: 0)
                        .animation(Animation.linear(duration: 0.1))
                        
                ).cornerRadius(20)
                .onTapGesture { configuration.isOn.toggle() }
        }
    }
    
}

extension View {
  
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
