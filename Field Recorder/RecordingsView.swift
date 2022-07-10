//
//  RecordingsView.swift
//  Field Recorder
//
//  Created by Chase Edson on 6/12/22.
//

import SwiftUI
import BottomSheet
import AVFoundation

struct nameDatePair {
    var name: String
    var date: Date
}



struct RecordingsView: View {
    @State var refresh: Bool = false
    @State var recordingsFound: Bool = true
    @State private var isPresentingDeleteConfirm: Bool = false
    @State var isPresented: Bool = false
    @State var playerFileName: String = ""
    @StateObject var mainHandler = AudioHandler()
    
    var body: some View {
        VStack{
            Text("Saved Recordings")
                .font(.title)
                .padding([.top], 50)
            
            if(!recordingsFound){
                Text("No recordings found.").font(.subheadline)
                Spacer()
            } else{
                List{
                    ForEach(listFilesFromDocumentsFolder()!, id: \.self){ x in
                        GeometryReader { geo in
                            HStack{
                                VStack(alignment: .leading){
                                    //hack to get view to refresh properly
                                    if(refresh){
                                        Text(x)
                                        Text(getDateFromFilePath(filename: x)).font(.footnote)
                                    } else{
                                        Text(x)
                                        Text(getDateFromFilePath(filename: x)).font(.footnote)
                                    }
                                }.frame(width: geo.size.width * 0.7, alignment: .leading)
                                Spacer()
                                HStack{
                                    Spacer()
                                    Button(action: {shareFileFromFolder(filename: x)}) {
                                    Image(systemName: "square.and.arrow.up").resizable().scaledToFit().frame(width: 20, height: 20, alignment: .trailing).foregroundStyle(.blue, .white)
                                    }.buttonStyle(PlainButtonStyle())
                                    
                                    Button(action: {
                                        deleteFileFromFolder(filename: x)
                                        if (listFilesFromDocumentsFolder() == []){
                                            recordingsFound = false;
                                        }
                                        refresh.toggle()
                                    }) {
                                                Image(systemName: "trash").resizable().scaledToFit().frame(width: 20, height: 20, alignment: .trailing).foregroundStyle(.red, .white).padding(.leading, 15)
                                            }.buttonStyle(PlainButtonStyle())
                                    
                                    Spacer()
                                }.frame(width: geo.size.width * 0.3)
                                
                            }.frame(height:60)
                        }.onTapGesture {
                            playerFileName = x
                            isPresented = true
                         }
          
                    }
                }.environment(\.defaultMinListRowHeight, 70).onAppear{
                    if (listFilesFromDocumentsFolder() == []){
                        recordingsFound = false;
                    }
                } .bottomSheet(isPresented: $isPresented, height: 300) {
                    Text(playerFileName)
                    Spacer()
                    if(mainHandler.isPlaying){
                        Button(action: {
                            mainHandler.stopAudio()

                                }) {
                                    Image(systemName: "stop.fill").foregroundStyle(.white).font(.system(size: 40, weight: .light))

                        }
                    } else {
                        Button(action: {
                            mainHandler.fileName = playerFileName
                            mainHandler.isPlaying = true
                                }) {
                                    Image(systemName: "play.fill").foregroundStyle(.white).font(.system(size: 40, weight: .light))
                        }
                    }
                    Spacer()
                    
                }
                
            }
            
        }
    }
}


func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

func getFinalFilePath(filename: String) -> URL{
    let fileMngr = FileManager.default;
    let docsurl = try! fileMngr.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    let finalFilename = docsurl.appendingPathComponent(filename)
    return finalFilename
}

func getDateFromFilePath(filename: String) -> String{
    let finalPath = getFinalFilePath(filename: filename)
    var theCreationDate = Date()
            do{
                let aFileAttributes = try FileManager.default.attributesOfItem(atPath: finalPath.path) as [FileAttributeKey:Any]
                theCreationDate = aFileAttributes[FileAttributeKey.creationDate] as! Date

            } catch let theError {
                print("file not found \(theError)")
            }
    // Create Date Formatter
    let dateFormatter = DateFormatter()
    // Set Date Format
    dateFormatter.dateFormat = "EEEE, MMMM d, yyyy H:mm a"
    // Convert Date to String
    return dateFormatter.string(from: theCreationDate)
}

func getDateFromFilePathDate(filename: String) -> Date{
    let finalPath = getFinalFilePath(filename: filename)
    var theCreationDate = Date()
            do{
                let aFileAttributes = try FileManager.default.attributesOfItem(atPath: finalPath.path) as [FileAttributeKey:Any]
                theCreationDate = aFileAttributes[FileAttributeKey.creationDate] as! Date

            } catch let theError {
                print("file not found \(theError)")
            }
    // Create Date Formatter
    return theCreationDate
}

func listFilesFromDocumentsFolder() -> [String]?{
    let fileMngr = FileManager.default;

    // Full path to documents directory
    let docs = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0].path

    do{
        let mainReturn = try fileMngr.contentsOfDirectory(atPath:docs)
        var nameDateArray = [nameDatePair]()
        for x in mainReturn {
            let curPair = nameDatePair(name: x, date: getDateFromFilePathDate(filename: x))
            nameDateArray.append(curPair)
        }
        //populate list ordered from oldest to newest
        var finalArray = [String]()
        
        if(nameDateArray.count > 0){
            for _ in 1...nameDateArray.count{
                var curSmallestDate = 0
                for x in 0...(nameDateArray.count - 1){
                    if nameDateArray[x].date < nameDateArray[curSmallestDate].date{
                        curSmallestDate = x
                    }
                }
                finalArray.append(nameDateArray[curSmallestDate].name)
                nameDateArray.remove(at: curSmallestDate)
            }
            
            return finalArray.reversed()
        } else{
            return []
        }
        
    } catch let theError{
        print(theError)
    }
    
    
    return []
    
    //sort by date oldest to newest
    
}

func deleteFileFromFolder(filename: String){
    print("delete called")
    let fileMngr = FileManager.default;
    let finalFilename = getFinalFilePath(filename: filename)
    
    do {
        try fileMngr.removeItem(at: finalFilename)
        print("delete called for " + finalFilename.absoluteString)
    } catch let error as NSError {
        print("Error: \(error.description)")

    }
}

func shareFileFromFolder(filename: String){
    let finalFilename = getFinalFilePath(filename: filename)
    let activityVC = UIActivityViewController(activityItems: [finalFilename], applicationActivities: nil)
    UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
}



class AudioHandler: NSObject, ObservableObject, AVAudioPlayerDelegate {

    @Published var isPlaying: Bool = false {
        willSet {
            if newValue == true {
                playAudio()
            }
        }
    }
    
    var myAudioPlayer = AVAudioPlayer()
    var fileName = ""

    override init() {
        super.init()
        myAudioPlayer.delegate = self
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }

    }

    func playAudio() {
        let url = getFinalFilePath(filename: fileName)

        do {
            myAudioPlayer = try AVAudioPlayer(contentsOf: url)
            myAudioPlayer.delegate = self
            myAudioPlayer.play()
            //isPlaying = true
        } catch {
            // couldn't load file :(
        }
    }
    
    func stopAudio(){
        myAudioPlayer.stop()
        isPlaying = false
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Did finish Playing")
        isPlaying = false
    }
}


struct RecordingsView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingsView()
    }
}
