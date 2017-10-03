//
//  VoiceRecorderViewModel+Player.swift
//  VoiceRecorder
//
//  Created by Ilya Rudometov on 03/10/2017.
//  Copyright © 2017 Ilya Rudometov. All rights reserved.
//

import Foundation

// An extension of VoiceRecorderViewModel to incapsulate Player functionality.

extension VoiceRecorderViewModel
{
    // MARK: - IVoiceRecorderViewModel - Playing
    
    func playAudioFromFile(withURL url: URL)
    {
        stopRecording()
        
        if player == nil
        {
            // Create a new audio player...
            
            player = AudioPlayer(audioFileURL: url)
            subscribeForPlayerEvents(&player!)
        }
        
        // ... and play the audio file.
        
        player?.play()
    }
    
    func pausePlay()
    {
        player?.pause()
    }
    
    func stopPlaying()
    {
        player?.stop()
    }
    
    private func subscribeForPlayerEvents(_ player: inout AudioPlayer)
    {
        player.didStartPlay = { [unowned self] (audioPlayer) in
            
            DispatchQueue.main.async {
                
                self.didStartPlay?(self)
            }
        }
        
        player.didPausePlay = { [unowned self] (audioPlayer) in
            
            DispatchQueue.main.async {
                
                self.didPausePlay?(self)
            }
        }
        
        player.didStopPlay = { [unowned self] (audioPlayer) in
            
            DispatchQueue.main.async {
                
                self.didStopPlay?(self)
            }
        }
        
        player.didFailWithError = { [unowned self] (audioPlayer, error) in
            
            DispatchQueue.main.async {
                
                self.cleanUpPlayer()
                self.failWithError(error)
            }
        }
    }
    
    private func cleanUpPlayer()
    {
        if let player = self.player
        {
            player.didStartPlay = nil
            player.didPausePlay = nil
            player.didStopPlay = nil
            player.didFailWithError = nil
            self.player = nil
        }
    }
}
