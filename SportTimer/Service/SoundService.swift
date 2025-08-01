//
//  SoundService.swift
//  SportTimer
//
//  Created by Алексей Авер on 09.07.2025.
//


import Foundation
import AVFoundation

final class SoundPlayer {
    static let shared = SoundPlayer()
    private var player: AVAudioPlayer?

    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ Audio session error: \(error)")
        }
    }

    func playSound(named name: String) {
        guard UserDefaults.standard.bool(forKey: "isSoundEnabled") else {
            print("🔇 Sound is disabled")
            return
        }

        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("❌ Sound file not found: \(name).mp3")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
            print("🔊 Playing sound: \(name)")
        } catch {
            print("❌ AVAudioPlayer error: \(error)")
        }
    }
}
