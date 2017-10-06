//
//  FileStorage.swift
//  VoiceRecorder
//
//  Created by Ilya Rudometov on 03/10/2017.
//  Copyright © 2017 Ilya Rudometov. All rights reserved.
//

import FCFileManager

// An implementation of IFileStorage protocol.

class FileStorage: NSObject, IFileStorage
{
    private struct Static
    {
        static let tempDirectoryName = "temp_files"
        static let storageDirectoryName = "audio_records"
        static let audioFileExtension = "m4a"
    }
    
    public let defaultFileExtension: String
    
    // MARK: - init / deinit
    
    init(defaultFileExtension: String = Static.audioFileExtension)
    {
        self.defaultFileExtension = defaultFileExtension
        super.init()
    }
    
    func createDirectoriesForFile(atPath path: String)
    {
        FCFileManager.createDirectoriesForFile(atPath: path)
    }
    
    // MARK: - IFileStorage
    
    var pathToTemporaryDirectory: String
    {
        return FCFileManager.pathForTemporaryDirectory(withPath: Static.tempDirectoryName)
    }
    
    var pathToStorageDirectory: String
    {
        return FCFileManager.pathForDocumentsDirectory(withPath: Static.storageDirectoryName)
    }
    
    func tempPath(for fileName: String) -> String
    {
        let trimmedFileName = Utils.trimSlashPrefix(from: fileName)
        return pathToTemporaryDirectory + "/" + trimmedFileName
    }
    
    func storagePath(for fileName: String) -> String
    {
        let trimmedFileName = Utils.trimSlashPrefix(from: fileName)
        return pathToStorageDirectory + "/" + trimmedFileName
    }
    
    func generateNewFileName() -> String
    {
        let fileExtension = (self.defaultFileExtension ?? Static.audioFileExtension)
        return NSUUID().uuidString + "." + fileExtension
    }
    
    func newTempFileURL() -> URL
    {
        let fileName = generateNewFileName()
        let filePath = tempPath(for: fileName)
        
        return URL(fileURLWithPath: filePath)
    }
    
    func saveFile(_ data: Data, toPath filePath: String) -> Bool
    {
        if !FCFileManager.existsItem(atPath: filePath)
        {
            FCFileManager.createFile(atPath: filePath)
        }
        
        if FCFileManager.isWritableItem(atPath: filePath)
        {
            return FCFileManager.writeFile(atPath: filePath, content: data as NSObject)
        }

        return false
    }
    
    func removeFile(atPath filePath: String)
    {
        if FCFileManager.existsItem(atPath: filePath)
        {
            FCFileManager.removeItem(atPath: filePath)
        }
    }
}
