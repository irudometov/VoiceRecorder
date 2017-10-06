//
//  VoiceRecorderViewController.swift
//  VoiceRecorder
//
//  Created by Ilya Rudometov on 02/10/2017.
//  Copyright © 2017 Ilya Rudometov. All rights reserved.
//

import UIKit

// The main view controller of the app to record and play audio.

class VoiceRecorderViewController: UIViewController
{
    // Use this enumeration to detect the current display mode.
    
    private enum ViewDisplayMode
    {
        case record
        case recording
        case uploading
        case play
        case playing
    }
    
    private var displayMode = ViewDisplayMode.record
    
    // MARK: - Outlets
    
    @IBOutlet internal weak var statusLabel: UILabel!
    @IBOutlet internal weak var recordButton: TapAndHoldButton!
    @IBOutlet internal weak var resetButton: UIButton!
    @IBOutlet internal weak var playButton: UIButton!
    @IBOutlet internal weak var pauseButton: UIButton!
    
    // MARK: - View's life cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Initialize a new view model object.
        
        let fileStorage = FileStorage()
        let apiClient = NetworkService.sharedInstance
        
        self.viewModel = VoiceRecorderViewModel(fileStorage: fileStorage, apiClient: apiClient)
        self.setDisplayMode(.record, hard: true)
        
        if let button = recordButton
        {
            self.subscribeForRecordButtonEvents(button)
        }
    }
    
    // MARK: - Record button events
    
    private func subscribeForRecordButtonEvents(_ recordButton: TapAndHoldButton)
    {
        recordButton.didReceiveTouch = { [unowned self] (button) in
            
            self.viewModel.startRecording()
        }
        
        recordButton.didReleaseTouch = { [unowned self] (button) in
            
            self.viewModel.stopRecording()
        }
    }
    
    // MARK: - View model
    
    private var viewModel: IVoiceRecorderViewModel!
    {
        didSet
        {
            if var vm = viewModel
            {
                subscribeToRecorderEvents(&vm) // At first we should record an audio...
            }
        }
    }
    
    private func subscribeToRecorderEvents(_ viewModel: inout IVoiceRecorderViewModel)
    {
        // Audio Recorder
        
        viewModel.didStartRecording = { [unowned self] (viewModel) in
            
            self.setDisplayMode(.recording)
        }
        
        viewModel.willSaveFile = { [unowned self] (viewModel) in
            
            self.setDisplayMode(.uploading)
        }
        
        viewModel.didSaveFile = { [unowned self] (viewModel) in
            
            assert(viewModel.audioFileURL != nil, "Audio file should exists when a recording is finished without errorrs.")
            
            self.subscribeToPlayerEvents(&self.viewModel!)
            self.setDisplayMode(.play)
        }
        
        viewModel.didFailWithError = { [unowned self] (viewModel, error) in
            
            self.setDisplayMode(.record)
            self.displayError(error)
        }
    }
    
    private func subscribeToPlayerEvents(_ viewModel: inout IVoiceRecorderViewModel)
    {
        // Audio Recorder
        
        viewModel.didStartPlay = { [unowned self] (viewModel) in
            
            self.setDisplayMode(.playing)
        }
        
        viewModel.didPausePlay = { [unowned self] (viewModel) in
            
            self.setDisplayMode(.play)
        }
        
        viewModel.didStopPlay = { [unowned self] (viewModel) in
            
            self.setDisplayMode(.play)
        }
        
        viewModel.didFailWithError = { [unowned self] (viewModel, error) in
            
            self.setDisplayMode(.record)
            self.displayError(error)
        }
        
        viewModel.didResetState = { [unowned self] (viewModel) in
            
            self.setDisplayMode(.record)
        }
    }
    
    // MARK: - Configure
    
    private func setDisplayMode(_ mode: ViewDisplayMode, hard: Bool = false)
    {
        if (displayMode == mode && !hard)
        {
            return
        }
        
        displayMode = mode
        
        let isRecord = (displayMode == .record)
        let isRecording = (displayMode == .recording)
        let isPlay = (displayMode == .play)
        let isPlaying = (displayMode == .playing)
        
        // Record
        
        recordButton.isEnabled = isRecord || isRecording
        recordButton.isHidden = !isRecord && !isRecording
        
        // Recording
        
        resetButton.isEnabled = isPlay
        resetButton.isHidden = !isPlay
        
        // Play
        
        playButton.isEnabled = isPlay
        playButton.isHidden = !isPlay
        
        // Pause
        
        pauseButton.isEnabled = isPlaying
        pauseButton.isHidden = !isPlaying
        
        // Status
        
        statusLabel.text = VoiceRecorderViewController.localizedStatusForDisplayMode(displayMode)
    }
    
    private class func localizedStatusForDisplayMode(_ displayMode: ViewDisplayMode) -> String?
    {
        var status: String?
        
        switch displayMode
        {
        // Record audio
            
        case .record:
            status = "status_record_voice".localized
            
        case .recording:
            status = "status_recording".localized
            
        // Upload file
            
        case .uploading:
            status = "status_uploading".localized
            
        // Play audio
            
        case .play:
            status = "status_play_audio".localized
            
        case .playing:
            status = "status_playing_audio".localized
        }
        
        return status
    }
    
    private func displayError(_ error: Error)
    {
        self.showAlertWithTitle(title: "alert_title_error".localized, message: error.localizedDescription)
    }
    
    // MARK: - Actions
    
    @IBAction func playTapped(_ sender: UIButton)
    {
        sender.isEnabled = false
        
        // In this case the file must be on the disk.
        assert(viewModel.audioFileURL != nil, "Audio file should exists on the disk to be played.")
        
        viewModel.playAudioFromFile(withURL: viewModel.audioFileURL!)
    }
    
    @IBAction func pauseTapped(_ sender: UIButton)
    {
        sender.isEnabled = false
        viewModel.pausePlay()
    }
    
    @IBAction func resetTapped(_ sender: UIButton)
    {
        sender.isEnabled = false
        viewModel.resetState()
    }
}
