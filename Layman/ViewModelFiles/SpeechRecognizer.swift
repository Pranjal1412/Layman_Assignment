//
//  SpeechRecognizer.swift
//  Layman
//
//  Created by Pranjal   on 02/04/26.
//

import Foundation
import Speech
import AVFoundation
import Combine

class SpeechRecognizer: ObservableObject {
    
    private let recognizer = SFSpeechRecognizer()
    private let audioEngine = AVAudioEngine()
    
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    
    @Published var transcript: String = ""
    @Published var isRecording = false
    
    init() {
        requestPermission()
    }
    
    private func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                if status != .authorized {
                    print("Speech permission not granted")
                }
            }
        }
    }
    
    func startRecording() {
        guard !audioEngine.isRunning else { return }
        
        transcript = ""
        isRecording = true
        
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request = request else { return }
        
        let inputNode = audioEngine.inputNode
        
        request.shouldReportPartialResults = true
        
        task = recognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                }
            }
            
            if error != nil {
                DispatchQueue.main.async {
                    self.stopRecording()
                }
            }
        }
        
        let format = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
    }
    
    func stopRecording() {
        guard audioEngine.isRunning else { return }
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        request?.endAudio()
        task?.cancel()
        
        isRecording = false
    }
}
