//
//  SoundManager.swift
//  Smack
//
//  Created by Ghadeer Fallatah on 18/12/1447 AH.
//
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    private var soundEffectPlayer: AVAudioPlayer?
    private var backgroundMusicPlayer: AVAudioPlayer?
    
    func playImportedSound(named soundName: String) {
        if let url = Bundle.main.url(forResource: soundName, withExtension: ".mp3") {
            do {
                soundEffectPlayer = try AVAudioPlayer(contentsOf: url)
                soundEffectPlayer?.numberOfLoops = -1
                soundEffectPlayer?.play()
            } catch {
                print("Error playing sound: \(error.localizedDescription)")
            }
            
        } else {
            print ("Error loading sound: \(soundName)")
        }
        
    }
    func toggleBackgroundMusic(isOn: Bool) {
        if isOn {
            if let url = Bundle.main.url(forResource: "background-music", withExtension: ".mp3") {
                do{
                    backgroundMusicPlayer =  try AVAudioPlayer(contentsOf: url)
                    backgroundMusicPlayer?.numberOfLoops = -1
                    backgroundMusicPlayer? .volume = 0.5
                    backgroundMusicPlayer? .play()
                }catch {
                    print ("Error playing BGM:  \(error.localizedDescription)")
                }
            }
            else {
                backgroundMusicPlayer?.stop()
            }
            
        }
        
    }
    
    func stopImportedSound() {
        soundEffectPlayer?.stop()
    }
    
    
    
    func pauseImportedSound() {
        soundEffectPlayer?.pause()
    }
    
    func resumeImportedSound() {
        soundEffectPlayer?.play()
    }
    
}

