//
//  AVAudioPlayerPool.swift
//  Smulle
//
//  Created by Mattias Almén on 2017-01-19.
//  Copyright © 2017 pixlig.se. All rights reserved.
//
//  This is a modified version of a code example from the book "iOS Swift Game Development Cookbook", 2nd Edition, written by Jonathon Manning
//  and published by O'Reilly Media, Inc

import Foundation
import AVFoundation

// An array of all players stored in the pool; not accessible
// outside this file
private var audioPlayers : [AVAudioPlayer] = []
private var newPlayer: AVAudioPlayer?

class AVAudioPlayerPool: NSObject {
    
    // Given the URL of a sound file, either create or reuse an audio player
    class func playerWithURL(url : URL) -> AVAudioPlayer? {
        
        // Try to find a player that can be reused and is not playing
        let availablePlayers = audioPlayers.filter { (player) -> Bool in
            return player.isPlaying == false && player.url == url
        }
        
        // If we found one, return it
        if let playerToUse = availablePlayers.first {
            print("Reusing player for \(url.lastPathComponent)")
            return playerToUse
        } else {
            
            // Didn't find one? Create a new one
            do {
                newPlayer = try AVAudioPlayer(contentsOf: url)
                print("Creating new player for url \(url.lastPathComponent)")
                audioPlayers.append(newPlayer!)
                
            } catch let error {
                print(error.localizedDescription)
            }
        }
        return newPlayer
    }
    
}
