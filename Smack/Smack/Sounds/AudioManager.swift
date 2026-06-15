//
//  AudioManager.swift
//  Smack
//
//  Created by Nouf Alshawoosh on 12/06/2026.
//

import SwiftUI
import AVFoundation
internal import Combine


final class AudioManager: ObservableObject {
    static let shared = AudioManager()

    @AppStorage("musicEnabled") var musicEnabled: Bool = true
    @AppStorage("sfxEnabled") var sfxEnabled: Bool = true

    private var musicPlayer: AVAudioPlayer?
    private var sfxPlayers: [AVAudioPlayer] = []

    private init() {}

    // MARK: - Background Music

    func playMusic(_ fileName: String, fileExtension: String = "mp3") {
        guard musicEnabled else { return }

        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("Music file not found: \(fileName).\(fileExtension)")
            return
        }

        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1   // loop forever
            musicPlayer?.prepareToPlay()
            musicPlayer?.play()
        } catch {
            print("Could not play music:", error)
        }
    }

    func stopMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
    }

    func updateMusicSetting() {
        if musicEnabled {
            playMusic("background")
        } else {
            stopMusic()
        }
    }

    // MARK: - Sound Effects

    func playSound(_ fileName: String, fileExtension: String = "wav") {
        guard sfxEnabled else { return }

        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            print("Sound file not found: \(fileName).\(fileExtension)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()

            sfxPlayers.append(player)

            // Remove finished sounds
            sfxPlayers.removeAll { !$0.isPlaying }
        } catch {
            print("Could not play sound:", error)
        }
    }
}
