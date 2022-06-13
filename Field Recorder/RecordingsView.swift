//
//  RecordingsView.swift
//  Field Recorder
//
//  Created by Chase Edson on 6/12/22.
//

import SwiftUI

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

func listFilesFromDocumentsFolder() -> [String]?
{
    let fileMngr = FileManager.default;

    // Full path to documents directory
    let docs = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0].path

    // List all contents of directory and return as [String] OR nil if failed
    
    print (try? fileMngr.contentsOfDirectory(atPath:docs))
    return try? fileMngr.contentsOfDirectory(atPath:docs)
    
}

struct RecordingsView: View {
    var body: some View {
        
        List{
            ForEach(listFilesFromDocumentsFolder()!, id: \.self){ x in
                GeometryReader { geo in
                    HStack{
                        VStack(alignment: .leading){
                            Text(x)
                            Text("December 19th, 2022").font(.footnote)
                        }.frame(width: geo.size.width * 0.7)
                        HStack{
                            Spacer()
                            Image(systemName: "square.and.arrow.up").resizable().scaledToFit().frame(width: 20, height: 20, alignment: .trailing).foregroundStyle(.blue, .white)
                            Image(systemName: "trash").resizable().scaledToFit().frame(width: 20, height: 20, alignment: .trailing).foregroundStyle(.red, .white).padding(.leading, 15)
                        }.frame(width: geo.size.width * 0.3)
                        
                    }.frame(height:30)
                }
  
            }
        }
        
    }
}

struct RecordingsView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingsView()
    }
}
