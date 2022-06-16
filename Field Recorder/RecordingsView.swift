//
//  RecordingsView.swift
//  Field Recorder
//
//  Created by Chase Edson on 6/12/22.
//

import SwiftUI



struct RecordingsView: View {
    @State var refresh: Bool = false
    @State private var isPresentingDeleteConfirm: Bool = false
    var body: some View {
        
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
                        }.frame(width: geo.size.width * 0.7)
                        HStack{
                            Spacer()
                            Button(action: {shareFileFromFolder(filename: x)}) {
                            Image(systemName: "square.and.arrow.up").resizable().scaledToFit().frame(width: 20, height: 20, alignment: .trailing).foregroundStyle(.blue, .white)
                            }.buttonStyle(PlainButtonStyle())
                            
                            Button(action: {isPresentingDeleteConfirm = true}) {
                                        Image(systemName: "trash").resizable().scaledToFit().frame(width: 20, height: 20, alignment: .trailing).foregroundStyle(.red, .white).padding(.leading, 15)
                                    }.buttonStyle(PlainButtonStyle()).confirmationDialog("Are you sure you want to delete?",
                                                         isPresented: $isPresentingDeleteConfirm) {
                                                         Button("Confirm deletion: " + x, role: .destructive) {
                                                             deleteFileFromFolder(filename: x)
                                                             refresh.toggle()
                                                          }
                                                        }
                            
                        }.frame(width: geo.size.width * 0.3)
                        
                    }.frame(height:30)
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
    print(finalPath)
    let date = (try? FileManager.default.attributesOfItem(atPath: finalPath.absoluteString))?[.creationDate] as? Date
    // Create Date Formatter
    let dateFormatter = DateFormatter()
    // Set Date Format
    dateFormatter.dateFormat = "YY/MM/dd"
    // Convert Date to String
    return dateFormatter.string(from: date!)
}

func listFilesFromDocumentsFolder() -> [String]?{
    let fileMngr = FileManager.default;

    // Full path to documents directory
    let docs = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0].path

    // List all contents of directory and return as [String] OR nil if failed
    
    print (try? fileMngr.contentsOfDirectory(atPath:docs))
    return try? fileMngr.contentsOfDirectory(atPath:docs)
    
}

func deleteFileFromFolder(filename: String){
    let fileMngr = FileManager.default;
    let finalFilename = getFinalFilePath(filename: filename)
    
    do {
        try fileMngr.removeItem(at: finalFilename)
    } catch let error as NSError {
        print("Error: \(error.description)")

    }
}

func shareFileFromFolder(filename: String){
    let finalFilename = getFinalFilePath(filename: filename)
    let activityVC = UIActivityViewController(activityItems: [finalFilename], applicationActivities: nil)
    UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
}

struct RecordingsView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingsView()
    }
}
