//
//  FileManger.swift
//  March3FinalPhotoJournal
//
//  Created by Margiett Gil on 3/3/20.
//  Copyright © 2020 Margiett Gil. All rights reserved.
//

import Foundation

extension FileManager {
  // returns a URL to the documents directory for the app
  static func getDocumentsDirectory() -> URL  {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  }
  
  // function takes a filename as a parameter, appends to the document directory's URL and returns that path
  // this path will be used to write (save) date or read (retrieve) data
  static func pathToDocumentsDirectory(with filename: String) -> URL {
    return getDocumentsDirectory().appendingPathComponent(filename)
  }
}

