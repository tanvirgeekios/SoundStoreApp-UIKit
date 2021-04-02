//
//  PlaySoundViewController.swift
//  AudioRecorder
//
//  Created by MD Tanvir Alam on 2/4/21.
//

import UIKit
import AVFoundation

class PlaySoundViewController: UIViewController {
    var sounds = [Sound]()
    var soundIndex:Int?
    var player : AVAudioPlayer?
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    func getDocumentDirectiory()->URL{
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        }
    func configure(){
        print("In configure")
        //set up player
        guard let index = soundIndex else{return}
        let sound = sounds[index]
        let url = getDocumentDirectiory().appendingPathComponent(sound.uniqueName!)
        
        do{
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            player = try AVAudioPlayer(contentsOf: url)
            
            guard let player = player else {
                return
            }
            player.volume = 0.5
            player.play()
            
        }catch{
            print(error)
        }
    }
}
