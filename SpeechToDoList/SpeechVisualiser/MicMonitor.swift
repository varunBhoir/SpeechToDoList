//
//  MicManager.swift
//  SpeechToDoList
//
//  Created by varun bhoir on 19/03/21.
//

import Foundation
import AVFoundation

class MicMonitor: ObservableObject {
    private var audioRecorder: AVAudioRecorder
    private var timer: Timer?
    
    private let noOfSamples: Int
    private var currentSample: Int
    
    @Published public var soundSamples: [Float]
    
    init(numberOfSamples: Int) {
        noOfSamples = numberOfSamples > 0 ? numberOfSamples : 10
        soundSamples = [Float](repeating: .zero, count: noOfSamples)
        currentSample = 0
        
        let audioSession = AVAudioSession.sharedInstance()
        if audioSession.recordPermission != .granted {
            audioSession.requestRecordPermission { (success) in
                if success == false {
                    fatalError("We need audio recording for visualization")
                }
            }
        }
        
        let url = URL(fileURLWithPath: "/varun/null", isDirectory: true)
        let recorderSettings: [String: Any] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: recorderSettings)
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [])
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    public func startMonitoring() {
        audioRecorder.isMeteringEnabled = true
        audioRecorder.record()
        
        timer = Timer(timeInterval: 0.01, repeats: true, block: { (timer) in
            self.audioRecorder.updateMeters()
            self.soundSamples[self.currentSample] = self.audioRecorder.averagePower(forChannel: 0)
            self.currentSample = (self.currentSample + 1) % self.noOfSamples
        })
    }
    
    public func stopMonitoring() {
        audioRecorder.stop()
    }
    
    deinit {
        audioRecorder.stop()
        timer?.invalidate()
    }
    
}
