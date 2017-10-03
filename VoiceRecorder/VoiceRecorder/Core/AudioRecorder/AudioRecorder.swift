//
//  AudioRecorder.swift
//  VoiceRecorder
//
//  Created by Ilya Rudometov on 02/10/2017.
//  Copyright © 2017 Ilya Rudometov. All rights reserved.
//

import AVFoundation
import FCFileManager

typealias AudioRecorderBlock = (_ audioRecorder: AudioRecorder) -> Void
typealias AudioRecorderErrorBlock = (_ audioRecorder: AudioRecorder, _ error: Error) -> Void

enum AudioRecorderError: Error
{
    case permissionDenied
    case failPrepareToRecord
    case unknownError
}

// A wrapper class for AVAudioRecorder.

class AudioRecorder: NSObject, AVAudioRecorderDelegate
{
    private var recorder: AVAudioRecorder?
    private (set) public var outputFileURL: URL!
    
    private var shouldStop = false
    
    var didStartRecording: AudioRecorderBlock?
    var didFinishRecording: AudioRecorderBlock?
    var didFailWithError: AudioRecorderErrorBlock?
    
    // MARK: - init / deinit
    
    init(outputFileURL: URL)
    {
        super.init()
        self.outputFileURL = outputFileURL
    }
    
    deinit
    {
        if let recorder = self.recorder
        {
            recorder.delegate = nil
            recorder.stop()
            
            try? AVAudioSession.sharedInstance().setActive(false)
        }
    }
    
    // MARK: - Record permission
    
    private var isRecordPermissionGranted: Bool
    {
        return (AVAudioSession.sharedInstance().recordPermission() == AVAudioSessionRecordPermission.granted)
    }
    
    private func checkRecordPremission()
    {
        let recordPermission = AVAudioSession.sharedInstance().recordPermission()
        
        switch recordPermission
        {
        case AVAudioSessionRecordPermission.undetermined:
            requestRecordPermission()
            
        case AVAudioSessionRecordPermission.denied:
            notifyRecordPermissionDenied()
            
        default:
            print("ok, the record permission is granted")
        }
    }
    
    private func requestRecordPermission()
    {
        AVAudioSession.sharedInstance().requestRecordPermission { [unowned self] (granted) in
            
            if (granted)
            {
                self.recordAudio()
            }
            else {
                self.notifyRecordPermissionDenied()
            }
        }
    }
    
    private func failWithError(_ error: Error)
    {
        didFailWithError?(self, error)
    }
    
    private func notifyRecordPermissionDenied()
    {
        print("Fail to record audio becase the record permission is denied.")
        failWithError(AudioRecorderError.permissionDenied)
    }
    
    private class func createRecorder(outputFileURL: URL) throws -> AVAudioRecorder?
    {
        let settings: [String: Any] = [
            
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        return try AVAudioRecorder(url: outputFileURL, settings: settings)
    }
    
    private func prepareToRecord() -> Bool
    {
        do
        {
            // Configure the current audio session to record audio.
            
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try audioSession.setActive(true)
            
            // Create audio recorder if required.
            
            if recorder == nil
            {
                recorder = try AudioRecorder.createRecorder(outputFileURL: outputFileURL)
                recorder?.delegate = self
                
                if !recorder!.prepareToRecord()
                {
                    print("fail to prepare to record to file at url \(String(describing: recorder!.url))")
                    failWithError(AudioRecorderError.failPrepareToRecord)
                    return false
                }
            }
            
            return true
        }
        catch
        {
            print("Fail to configure the audio session to record audio: \(error.localizedDescription)")
            try? AVAudioSession.sharedInstance().setActive(false)
            recorder = nil
            
            failWithError(error)
        }
        
        return false
    }
    
    // MARK: - Control panel
    
    var isRecording: Bool
    {
        return (self.recorder?.isRecording ?? false)
    }
    
    func startRecording()
    {
        if (!isRecordPermissionGranted)
        {
            checkRecordPremission()
            return
        }
        
        recordAudio()
    }
    
    private func recordAudio()
    {
        if shouldStop
        {
            return
        }
        
        if prepareToRecord()
        {
            assert(recorder != nil, "An audio recorder should be initialized.")
            recorder?.record()
            didStartRecording?(self)
        }
    }
    
    func stop()
    {
        shouldStop = !self.isRecordPermissionGranted
        recorder?.stop()
    }
    
    // MARK: - AVAudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool)
    {
        if (flag)
        {
            didFinishRecording?(self)
        }
        else {
            failWithError(AudioRecorderError.unknownError)
        }
    }
}
