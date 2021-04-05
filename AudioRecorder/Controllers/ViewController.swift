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
    var microphonePresent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        recordBTN.isEnabled = false
        checkDeviceOrSimilator()
    }
    
    //MARK:- IBActions
    @IBAction func recordBTNClicked(_ sender: UIButton) {
        
        let isMicAvailable: Bool = AVAudioSession.sharedInstance().availableInputs?.first(where: { $0.portType == AVAudioSession.Port.builtInMic }) != nil
        
        if isMicAvailable{
            print("Microphone available")
            if self.audioRecorder == nil {
                alertForAudioname()
            }
            else {
                self.finishRecording(success: true)
            }
        }else{
            print("Microphone not available")
            showAlert(title: "Hey", message: "Please insert microphone")
        }
        
        
    }
    
    //MARK:- functions
    func checkDeviceOrSimilator(){
        #if targetEnvironment(simulator)
        //Simulator
        print("I am in a simulator")
        showAlert(title: "Hi", message: "You are using XCode simulator. Please Plugin a Microphone to record sound. Checking Microphone availability Feature does not work in Simulator.")
        #else
        //Real device
        print("I am in a real device")
        #endif
    }
    
    func alertForAudioname(){
        let alert = UIAlertController(title: "Name of your sound", message: "What will be the name of your sound?", preferredStyle: .alert)
        alert.addTextField()
        let saveNameAction = UIAlertAction(title: "Save Name", style: .default) { (action) in
            let fileName = alert.textFields![0].text
            if let fileName = fileName{
                
                if self.validateFileName(named:fileName){
                    self.sound  = SoundModel(uniqueName: UUID().uuidString, name: fileName)
                    // start recording
                    self.startRecording()
                }else{
                    self.dismiss(animated: true) {
                        self.present(alert,animated: true)
                    }
                }
                
            }
        }
        alert.addAction(saveNameAction)
        present(alert,animated: true)
    }
    
    func validateFileName(named fileName:String)->Bool{
        if fileName.trimmingCharacters(in: .whitespaces).count == 0{
            return false
        }else{
            return true
        }
        
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

