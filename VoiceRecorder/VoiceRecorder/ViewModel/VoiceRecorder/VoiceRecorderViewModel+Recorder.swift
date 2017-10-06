//
//  VoiceRecorderViewModel+Recorder.swift
//  VoiceRecorder
//
//  Created by Ilya Rudometov on 03/10/2017.
//  Copyright © 2017 Ilya Rudometov. All rights reserved.
//

import Foundation

// An extension of VoiceRecorderViewModel to incapsulate Recorder functionality.

extension VoiceRecorderViewModel
{
    func startRecording()
    {
        self.stopPlaying()
        
        if recorder == nil
        {
            // Generate a new file url.
            
            let url = fileStorage.newTempFileURL()
            fileStorage.createDirectoriesForFile(atPath: url.path)
            
            recorder = AudioRecorder(outputFileURL: url)
            subscribeForRecorderEvents(recorder!)
        }
        
        // Start recording...
        
        recorder?.startRecording()
    }
    
    func stopRecording()
    {
        recorder?.stop()
    }
    
    private func subscribeForRecorderEvents(_ recorder: AudioRecorder)
    {
        recorder.didStartRecording = { [unowned self] (audioRecorder) in
            
            DispatchQueue.main.async {
                
                self.didStartRecording?(self)
            }
        }
        
        recorder.didFinishRecording = { [unowned self] (audioRecorder) in
            
            // Remember this file url to be able to play the audio later.
            
            self.audioFileURL = audioRecorder.outputFileURL
            self.cleanUpRecorder()
            
            // Save this audio file on the server.
            
            self.uploadFileToServer()
            
            /*
            DispatchQueue.main.async {
                
                self.didFinishRecording?(self)
            }
             */
        }
        
        recorder.didFailWithError = { [unowned self] (audioRecorder, error) in
            
            DispatchQueue.main.async {
                
                self.cleanUpRecorder()
                self.failWithError(error)
            }
        }
    }
    
    private func cleanUpRecorder()
    {
        if let recorder = self.recorder
        {
            recorder.didStartRecording = nil
            recorder.didFinishRecording = nil
            recorder.didFailWithError = nil
            self.recorder = nil
        }
    }
}
