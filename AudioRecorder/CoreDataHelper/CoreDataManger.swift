//
//  CoreDataManger.swift
//  AudioRecorder
//
//  Created by MD Tanvir Alam on 2/4/21.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager{
    static let shared = CoreDataManager()
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func saveSound(sound:SoundModel){
        let newSound = Sound(context: context)
        newSound.name = sound.name
        newSound.uniqueName = sound.uniqueName
        do{
            try context.save()
            print ("Success saving data")
        }catch{
            print("Error saving data: \(error)")
        }
    }
    
    func fetchAllSounds()->[Sound]{
        var sounds = [Sound]()
        let request = NSFetchRequest<NSManagedObject>(entityName: "Sound")
        do{
            sounds = try context.fetch(request) as! [Sound]
            print("Success fetching sounds")
        }catch{
            print("Error fetching sounds: \(error)")
        }
        return sounds
    }
    
    func deleteSound(sound:Sound){
        context.delete(sound)
        do{
            try context.save()
            print("Success Deleting sound")
        }catch{
            print("Error deleting sound: \(error)")
        }
    }
}
