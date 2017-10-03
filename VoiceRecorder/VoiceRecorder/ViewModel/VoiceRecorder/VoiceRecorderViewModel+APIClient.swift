//
//  VoiceRecorderViewModel+APIClient.swift
//  VoiceRecorder
//
//  Created by Ilya Rudometov on 03/10/2017.
//  Copyright © 2017 Ilya Rudometov. All rights reserved.
//

import Foundation
import FCFileManager

// An extension of VoiceRecorderViewModel to incapsulate APIClient functionality.

extension VoiceRecorderViewModel
{
    func uploadFileToServer()
    {
        assert(audioFileURL != nil, "Audio file URL should be set to upload a file to the server.")
        
        willUploadFile()
        
        apiClient.uploadFile(atURL: audioFileURL!, fileName: "file", uploadProgress: fileUploadProgress) { [weak self] (fileData, error) in
            
            // Error
            
            if error != nil || fileData == nil
            {
                if let err = error
                {
                    self?.failWithError(err)
                }
                
                return
            }
            
            // Save this file to the persistent storage and 
            // remove the temporary one.
            
            if let this = self,
                let data = fileData,
                let newFileURL = this.saveFileData(data, toReplaceFile: this.audioFileURL!)
            {
                this.didUploadFile(newFileURL)
            }
        }
    }
    
    private func saveFileData(_ data: Data, toReplaceFile tempURL: URL) -> URL?
    {
        let fileName = (!tempURL.lastPathComponent.isEmpty ? tempURL.lastPathComponent : fileStorage.generateNewFileName())
        let filePath = fileStorage.storagePath(for: fileName)
        
        if (fileStorage.saveFile(data, toPath: filePath))
        {
            // Remove temporary file as well.
            
            FCFileManager.removeItem(atPath: tempURL.path)
            
            return URL(fileURLWithPath: filePath)
        }
        
        return nil
    }
    
    private func willUploadFile()
    {
        // Here we can notify the view we're going to save this file on the server.
        
        DispatchQueue.main.async { [unowned self] in
            
            self.willSaveFile?(self)
        }
    }
    
    private func didUploadFile(_ fileURL: URL)
    {
        // Here we can notify the view we're ready to play this audio.
        
        DispatchQueue.main.async { [unowned self] in
            
            self.audioFileURL = fileURL
            self.didSaveFile?(self)
        }
    }
}
