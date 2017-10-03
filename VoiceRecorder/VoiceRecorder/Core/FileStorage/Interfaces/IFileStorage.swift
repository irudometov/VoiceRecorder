//
//  IFileStorage.swift
//  VoiceRecorder
//
//  Created by Ilya Rudometov on 03/10/2017.
//  Copyright © 2017 Ilya Rudometov. All rights reserved.
//

import Foundation

// Base interface for any file storage.

protocol IFileStorage
{
    var pathToTemporaryDirectory: String { get }
    var pathToStorageDirectory: String { get }
    
    func tempPath(for fileName: String) -> String
    func storagePath(for fileName: String) -> String

    func generateNewFileName() -> String
    func newTempFileURL() -> URL
    
    func createDirectoriesForFile(atPath path: String)
    
    func saveFile(_ data: Data, toPath filePath: String) -> Bool
    
    func removeFile(atPath filePath: String)
}
