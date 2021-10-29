//
//  NotesModel.swift
//  JournalApp
//
//  Created by Michael Shustov on 27.10.2021.
//

import Foundation
import Firebase

protocol NotesModelProtocol {
    func retriveData(_ notesArray: [Note])
}

class NotesModel {
    
    var delegate: NotesModelProtocol?
    
    var listener: ListenerRegistration?
    
    deinit {
        
        // Unregister listener
        listener?.remove()
    }
    
    func getNotes(_ starredOnly: Bool = false) {
        
        // Detach any listener
        listener?.remove()
        
        // Get a reference to database
        let db = Firestore.firestore()
        
        var query: Query = db.collection("notes")
        
        // Check if we look for only starred notes
        if starredOnly {
            query = query.whereField("isStarred", isEqualTo: true)
        }
        
        // Get all the notes
        
        listener = query.addSnapshotListener { querySnapshot, error in
            
            if error == nil && querySnapshot != nil {
                
                var notes = [Note]()
                
                // Parse documents into notes
                for doc in querySnapshot!.documents {
                    
                    let createdAtDate: Date = Timestamp.dateValue(doc["createdAt"] as! Timestamp)()
                    
                    let lastUpdatedAtDate: Date = Timestamp.dateValue(doc["lastUpdatedAt"] as! Timestamp)()
                    
                    let n = Note(docId: doc["docId"] as! String, title: doc["title"] as! String, body: doc["body"] as! String, isStarred: doc["isStarred"] as! Bool, createdAt: createdAtDate, lastUpdatedAt: lastUpdatedAtDate)
                    
                    notes.append(n)
                }
                
                // Call the delegate and pass back the notes in main thread
                DispatchQueue.main.async {
                    
                    self.delegate?.retriveData(notes)
                }
            }
        }
    }
    
    func deleteNote(_ note: Note) {
        
        let db = Firestore.firestore()
        
        db.collection("notes").document(note.docId).delete()
    }
    
    func saveNote(_ note: Note) {
        
        let db = Firestore.firestore()
        
        db.collection("notes").document(note.docId).setData(noteToDict(note))
    }
    
    func updateFaveStatus(_ docId: String, _ isStarred: Bool) {
        
        let db = Firestore.firestore()
        
        db.collection("notes").document(docId).updateData(["isStarred": isStarred])
    }
    
    func noteToDict(_ note: Note) -> [String:Any] {
        
        var dict = [String:Any]()
        
        dict["docId"] = note.docId
        dict["title"] = note.title
        dict["body"] = note.body
        dict["isStarred"] = note.isStarred
        dict["createdAt"] = note.createdAt
        dict["lastUpdatedAt"] = note.lastUpdatedAt
        
        return dict
    }
}
