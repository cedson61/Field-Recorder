//
//  audioRecorder.swift
//  Field Recorder
//
//  Created by Chase Edson on 6/10/22.
//

import Foundation
import AVFoundation


class audioRecorder: NSObject, AVAudioRecorderDelegate {
    var recordingSession: AVAudioSession!
    var mainRecorder: AVAudioRecorder!
    var currentRandom = ""
    
    
    
    //rand name logic
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    
    
    //record logic
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getFileURL() -> URL {
        return getDocumentsDirectory().appendingPathComponent("recording-" + currentRandom + ".wav")
    }
    
    
    func checkRecordingPerms(){
        recordingSession = AVAudioSession.sharedInstance()

            do {
                try recordingSession.setCategory(.playAndRecord, mode: .default)
                try recordingSession.setActive(true)
                recordingSession.requestRecordPermission() { [unowned self] allowed in
                    DispatchQueue.main.async {
                        if allowed {
                            print("recording enabled... doing nothing")
                        } else {
                            print("error with permies!")
                        }
                    }
                }
            } catch {
                print("error with permissions!")
            }
    }
    
    
    
    
    func startRecording(sampleRateIndex: Int) {
        var selectedSampleRate: Int
        
        currentRandom = randomString(length: 6)
        let audioURL = getFileURL()
        print(audioURL.absoluteString)
        
        switch sampleRateIndex{
        case 0:
            selectedSampleRate = 44100
            
        case 1:
            selectedSampleRate = 48000
            
        case 2:
            selectedSampleRate = 96000
            
        default:
            selectedSampleRate = 44100
            
        }
        
        

        

        // 4
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: selectedSampleRate,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            // 5
            mainRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            mainRecorder.delegate = self
            mainRecorder.record()
        } catch {
            finishRecording(success: false)
        }
    }
    
    
    func finishRecording(success: Bool) {

        mainRecorder.stop()
        mainRecorder = nil

        if success {
            print("recording saved.")
        } else {
            print("recording failed...")
        }
    }
    

    
    
}
