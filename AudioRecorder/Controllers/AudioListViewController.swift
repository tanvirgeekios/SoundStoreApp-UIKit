//
//  AudioListViewController.swift
//  AudioRecorder
//
//  Created by MD Tanvir Alam on 2/4/21.
//

import UIKit

class AudioListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var sounds = [Sound]()
    @IBOutlet weak var tableAudioList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableAudioList.delegate = self
        tableAudioList.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        sounds = CoreDataManager.shared.fetchAllSounds()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playSoundSegue"{
            // send sound object so that we can play sound
            print("Prepearing for seuge")
            let vc = segue.destination as! PlaySoundViewController
            vc.sounds = self.sounds
            vc.soundIndex = self.tableAudioList.indexPathForSelectedRow?.row
            //print(self.tableAudioList.indexPathForSelectedRow?.row)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    //MARK:- DelegateMethods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sounds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableAudioList.dequeueReusableCell(withIdentifier: "audioCell", for: indexPath)
        cell.textLabel?.text = sounds[indexPath.row].name
        cell.detailTextLabel?.text = sounds[indexPath.row].uniqueName
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "playSoundSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // delete from core data
            CoreDataManager.shared.deleteSound(sound:sounds[indexPath.row])
            
            // delete from fileManager
            if let fileURL = sounds[indexPath.row].uniqueName{
                let url = getDocumentsDirectory().appendingPathComponent(fileURL)
                do{
                    try FileManager.default.removeItem(at: url)
                    print("Success deleting file")
                }catch{
                    print("Error deleting file")
                }
                
                sounds.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }else if editingStyle == .insert {
            
        }
    }
}
