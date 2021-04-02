//
//  ViewController.swift
//  AudioRecorder
//
//  Created by MD Tanvir Alam on 1/4/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var recordBTN: UIButton!
    var recordingSession:AVAudioSession!
    var audioRecorder:AVAudioRecorder!
    var sound:SoundModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        recordBTN.isEnabled = false
    }
    
    //MARK:- IBActions
    @IBAction func recordBTNClicked(_ sender: UIButton) {
        if self.audioRecorder == nil {
            alertForAudioname()
        }
        else {
            self.finishRecording(success: true)
        }
        
    }
    
    //MARK:- functions
    func alertForAudioname(){
        let alert = UIAlertController(title: "Name of your sound", message: "What is the name of your sound?", preferredStyle: .alert)
        alert.addTextField()
        let saveNameAction = UIAlertAction(title: "Save Name", style: .default) { (action) in
            let fileName = alert.textFields![0].text
            if let fileName = fileName{
                self.sound  = SoundModel(uniqueName: UUID().uuidString, name: fileName)
                // start recording
                
                self.startRecording()
            }
        }
        alert.addAction(saveNameAction)
        present(alert,animated: true)
    }
    
    func configure(){
        recordingSession = AVAudioSession.sharedInstance()
        do{
            try recordingSession.setCategory(.playAndRecord, mode:.default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed{
                        self.recordBTN.isEnabled = true
                    }else{
                        //Alert
                        print("Recording is not allowed")
                    }
                }
            }
        }catch{
            print("Recording Error: \(error)")
        }
    }
    
    func startRecording() {
        guard let sound = sound else {
            return
        }
        let audioFilename = getDocumentsDirectory().appendingPathComponent(sound.uniqueName)
        print(audioFilename)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            recordBTN.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            recordBTN.setTitle("Tap to Record", for: .normal)
            //save name and Unique name to coredata
            if let sound = self.sound{
                CoreDataManager.shared.saveSound(sound: sound)
            }
            
            showAlert(title: "Success", message: "Recording Finish")
        } else {
            recordBTN.setTitle("Tap to Record", for: .normal)
            showAlert(title: "Failure", message: "Not Recorder")
            // recording failed :(
        }
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func showAlert(title:String, message:String){
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Delegate Methods
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
}

