//
//  AudioPlayer.swift
//  VoiceRecorder
//
//  Created by Ilya Rudometov on 02/10/2017.
//  Copyright © 2017 Ilya Rudometov. All rights reserved.
//

import AVFoundation

typealias AudioPlayerBlock = (_ audioPlayer: AudioPlayer) -> Void
typealias AudioPlayerErrorBlock = (_ audioPlayer: AudioPlayer, _ error: Error) -> Void

enum AudioPlayerError: Error
{
    case failToPlay
    case failToPrepareToPlay
    case unknownError
}

// A wrapper class for AVAudioPlayer.

class AudioPlayer: NSObject, AVAudioPlayerDelegate
{
    private var player: AVAudioPlayer?
    private (set) public var audioFileURL: URL!
    
    var didStartPlay: AudioPlayerBlock?
    var didPausePlay: AudioPlayerBlock?
    var didStopPlay: AudioPlayerBlock?
    var didFailWithError: AudioPlayerErrorBlock?
    
    // MARK: - init / deinit
    
    init(audioFileURL: URL)
    {
        super.init()
        self.audioFileURL = audioFileURL
    }
    
    deinit
    {
        if let player = self.player
        {
            player.delegate = nil
            player.stop()
        
            try? AVAudioSession.sharedInstance().setActive(false)
        }
    }
    
    // MARK: - Error
    
    private func failWithError(_ error: Error)
    {
        didFailWithError?(self, error)
    }
    
    // MARK: - Control panel
    
    var isPlaying: Bool
    {
        return (self.player?.isPlaying ?? false)
    }
    
    func stop()
    {
        self.player?.stop()
    }
    
    func play()
    {
        if isPlaying
        {
           return
        }
        
        if prepareToPlay()
        {
            assert(player != nil, "A player should be initialized to play an audio file.")
            player?.play()
            didStartPlay?(self)
        }
    }
    
    func pause()
    {
        if isPlaying
        {
            player?.pause()
            didPausePlay?(self)
        }
    }
    
    private class func createPlayer(audioFileURL: URL) throws -> AVAudioPlayer?
    {
        return try AVAudioPlayer(contentsOf: audioFileURL)
    }
    
    private func prepareToPlay() -> Bool
    {
        do
        {
            // Configure the current audio session to play audio.
            
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try audioSession.setActive(true)
            
            // Create audio player if required.
            
            if player == nil
            {
                player = try AudioPlayer.createPlayer(audioFileURL: audioFileURL)
                player?.delegate = self
                
                if !player!.prepareToPlay()
                {
                    print("fail to prepare to play an audio from file at url \(String(describing: player!.url))")
                    didFailWithError?(self, AudioRecorderError.failPrepareToRecord)
                    return false
                }
            }
            
            return true
        }
        catch
        {
            print("Fail to configure the audio session to play audio: \(error.localizedDescription)")
            try? AVAudioSession.sharedInstance().setActive(false)
            player = nil
            
            failWithError(error)
        }
        
        return false
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        if (flag)
        {
            didStopPlay?(self)
        }
        else {
            failWithError(AudioPlayerError.unknownError)
        }
    }
}
