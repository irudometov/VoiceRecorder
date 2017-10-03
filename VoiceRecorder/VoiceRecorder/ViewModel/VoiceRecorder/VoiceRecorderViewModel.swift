//
//  VoiceRecorderViewModel.swift
//  VoiceRecorder
//
//  Created by Ilya Rudometov on 02/10/2017.
//  Copyright © 2017 Ilya Rudometov. All rights reserved.
//

import AVFoundation

// An implementation of player-recorder view model.

class VoiceRecorderViewModel: IVoiceRecorderViewModel
{
    internal var player: AudioPlayer?
    internal var recorder: AudioRecorder?
    
    internal (set) public var audioFileURL: URL?
    internal (set) public var fileStorage: IFileStorage!
    internal (set) public var apiClient: IAPIClient!
    
    var fileUploadProgress: APIClientProgressBlock?
    
    // MARK: - init / deinit
    
    init(fileStorage: IFileStorage, apiClient: IAPIClient)
    {
        self.fileStorage = fileStorage
        self.apiClient = apiClient
    }
    
    deinit
    {
        // Stop any activity...
        
        self.player?.stop()
        self.recorder?.stop()
    }
    
    // MARK: - IVoiceRecorderViewModel
    
    var isRecordPermissionGranted: Bool
    {
        return (AVAudioSession.sharedInstance().recordPermission() == AVAudioSessionRecordPermission.granted)
    }
    
    var didStartRecording: ((IVoiceRecorderViewModel) -> ())?
    var didFinishRecording: ((IVoiceRecorderViewModel) -> ())?
    
    var willSaveFile: ((IVoiceRecorderViewModel) -> ())?
    var didSaveFile: ((IVoiceRecorderViewModel) -> ())?
    
    var didStartPlay: ((IVoiceRecorderViewModel) -> ())?
    var didPausePlay: ((IVoiceRecorderViewModel) -> ())?
    var didStopPlay: ((IVoiceRecorderViewModel) -> ())?
    
    var didResetState: ((IVoiceRecorderViewModel) -> ())?
    
    var didFailWithError: ((IVoiceRecorderViewModel, Error) -> ())?
    
    // MARK: - Fail with error
    
    internal func failWithError(_ error: Error)
    {
        DispatchQueue.main.async { [weak self] in
            
            if let this = self
            {
                this.didFailWithError?(this, error)
            }
        }
    }
    
    // MARK: - Reset state
    
    func resetState()
    {
        // Stop playing the current audio file, then remove it and 
        // display the interface to record a new audio file.
        
        self.stopPlaying()
        player = nil
        
        if let filePath = audioFileURL?.path
        {
            fileStorage.removeFile(atPath: filePath)
            audioFileURL = nil
        }
        
        didResetState?(self)
    }
}
