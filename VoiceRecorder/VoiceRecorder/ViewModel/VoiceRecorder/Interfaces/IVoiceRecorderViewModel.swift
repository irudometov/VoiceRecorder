//
//  IVoiceRecorderViewModel.swift
//  VoiceRecorder
//
//  Created by Ilya Rudometov on 02/10/2017.
//  Copyright © 2017 Ilya Rudometov. All rights reserved.
//

import Foundation

// An interface for player-recorder view model.

protocol IVoiceRecorderViewModel
{
    var audioFileURL: URL? { get }
    
    // Recording
    
    var isRecordPermissionGranted: Bool { get }
    
    func startRecording()
    func stopRecording()
    
    var didStartRecording: ((IVoiceRecorderViewModel) -> ())? { get set }
    var didFinishRecording: ((IVoiceRecorderViewModel) -> ())? { get set }
    
    // Save file
    
    var willSaveFile: ((IVoiceRecorderViewModel) -> ())? { get set }
    var didSaveFile: ((IVoiceRecorderViewModel) -> ())? { get set }
    
    // Playing
    
    func playAudioFromFile(withURL url: URL)
    func pausePlay()
    func stopPlaying()
    
    var didStartPlay: ((IVoiceRecorderViewModel) -> ())? { get set }
    var didPausePlay: ((IVoiceRecorderViewModel) -> ())? { get set }
    var didStopPlay: ((IVoiceRecorderViewModel) -> ())? { get set }
    
    // Reset state
    
    func resetState()
    
    var didResetState: ((IVoiceRecorderViewModel) -> ())? { get set }
    
    // Error
    
    var didFailWithError: ((IVoiceRecorderViewModel, Error) -> ())? { get set }
}
