//
//  ContentView.swift
//  Field Recorder
//
//  Created by Chase Edson on 4/2/22.
//

import SwiftUI
import AVFoundation




struct ContentView: View {
    //variables here!
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    let mainRecorder = audioRecorder()
    

    //define UI option arrays
    
    private var microphoneOptionArray = ["Front", "Back", "Mono"]
    @State private var microphoneOptionArrayIndex = 0
    
    private var frequencyArray = ["44.1khz", "48khz", "96khz"]
    @State private var frequencyArrayIndex = 0
    
    private var pickupPatternArray = ["Cartioid", "Subcartioid", "Omni"]
    @State private var pickupPatternArrayIndex = 0
    
    
    @State var isRecordingToggled : Bool = false
    @State var timerRunning : Bool = false
    @State var timerHours: Int = 0
    @State var timerMinutes: Int = 0
    @State var timerSeconds: Int = 0
    
    @State var meteringRunning: Bool = false
    @State var inputVolumeLevel: Float = 0.1
    
    func meteringToggle(){
        if(!meteringRunning){
            _ = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
                if(isRecordingToggled){
                    var currentFloatValue = abs(mainRecorder.getCurrentVolume())
                    if(currentFloatValue > 40){
                        currentFloatValue = 40
                    }
                    inputVolumeLevel = round((1 - (currentFloatValue / 40)) * 100) / 100.0
                    
                    
                }
            }
            meteringRunning = true
        }
        
    }
    
    func timerStart(){
        timerHours = 0
        timerMinutes = 0
        timerSeconds = 0
        if (timerRunning == false){
            _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                
                if (timerHours == 23 && timerMinutes == 59 && timerSeconds == 59){
                    isRecordingToggled = false;
                }
                else if (timerMinutes == 59 && timerSeconds == 59){
                    timerHours = timerHours + 1
                    timerMinutes = 0
                    timerSeconds = 0
                } else if timerSeconds == 59{
                    timerMinutes = timerMinutes + 1
                    timerSeconds = 0
                }
                
                if (inputVolumeLevel == 0.4){
                    inputVolumeLevel = 0.1
                    
                }
                
                timerSeconds = timerSeconds + 1
            }
        }
        
        timerRunning = true

        
    }
    
    func issueHapticFeedback() {
        let impactMed = UIImpactFeedbackGenerator(style: .heavy)
        impactMed.impactOccurred()
    }
    
    //record code
    //check for perms
    
    func shareRecording(){
        let urlShare = mainRecorder.getFileURL()
        let activityVC = UIActivityViewController(activityItems: [urlShare], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
    
    
    
    
    
    
    

    var body: some View {
        NavigationView{
        
            ZStack {
                VStack(spacing: 15) {
                    Text("Field Recorder")
                        .font(.largeTitle)
                        .padding([.top], 50)
                    Text("Maximum recording time is 24 hours.")
                        .font(.system(size: 10, weight: .light, design: .default))
                    if !isRecordingToggled{
                    Group{
                            Text("Microphone Mode")
                            Picker(selection: $microphoneOptionArrayIndex, label: Text("Microphone Mode")) {
                                            ForEach(0 ..< microphoneOptionArray.count) {
                                                Text(self.microphoneOptionArray[$0])
                                            }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .onChange(of: microphoneOptionArrayIndex) { _ in
                                        issueHapticFeedback()
                                    }
                            
                            Text("Frequency Mode")
                            Picker(selection: $frequencyArrayIndex, label: Text("Frequency Mode")) {
                                            ForEach(0 ..< frequencyArray.count) {
                                                Text(self.frequencyArray[$0])
                                            }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .onChange(of: frequencyArrayIndex) { _ in
                                        issueHapticFeedback()
                                    }
                            Text("Pickup Pattern")
                            Picker(selection: $pickupPatternArrayIndex, label: Text("Pickup Pattern")) {
                                            ForEach(0 ..< pickupPatternArray.count) {
                                                Text(self.pickupPatternArray[$0])
                                            }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .onChange(of: pickupPatternArrayIndex) { _ in
                                        issueHapticFeedback()
                                    }
                        }.padding([.leading, .trailing],40)
                    }
                        
                    if isRecordingToggled{
                        Text("\(String(format: "%02d", timerHours)):\(String(format: "%02d", timerMinutes)):\(String(format: "%02d", timerSeconds))").font(.largeTitle).fontWeight(.ultraLight)
                    
                    }
                    
                    Spacer()
                    Button(action: {
                        self.isRecordingToggled.toggle()
                        if(isRecordingToggled){
                            mainRecorder.startRecording(sampleRateIndex: frequencyArrayIndex)
                        } else{
                            mainRecorder.finishRecording(success: true)
                            shareRecording()
                        }
                        timerStart()
                        meteringToggle()
                        
                    }){
                        ZStack{
                            if isRecordingToggled{
                                Rectangle()
                                  .frame(width: 55, height: 55)
                                  .foregroundColor(Color.red.opacity(Double(inputVolumeLevel)))
                            }
                            if !isRecordingToggled{
                                Circle()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.red)
                            }

                            
                            if (colorScheme == .light) {
                                Circle()
                                    .strokeBorder(Color.black.opacity(0.2), lineWidth: 5)
                                    .frame(width: 125, height: 125)
                                
                            } else {
                                Circle()
                                    .strokeBorder(Color.white, lineWidth: 5)
                                    .frame(width: 125, height: 125)
                            }
                            
                                
                        }.padding([.bottom], 50)
                    }
                    
                    NavigationLink(destination: RecordingsView()) {
                        Image(systemName: "folder.fill").foregroundStyle(.white, .blue)
                    }.navigationBarTitle("Back")
                        .navigationBarHidden(true)
                    
                    
                    
                        
                        
                        

                }
                
            }.onAppear {
                mainRecorder.checkRecordingPerms()
            }
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
