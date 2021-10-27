//
//  NoteViewController.swift
//  JournalApp
//
//  Created by Michael Shustov on 25.10.2021.
//

import UIKit

class NoteViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var bodyTextView: UITextView!
    
    @IBOutlet weak var starButton: UIButton!
    
    var note: Note?
    var notesModel: NotesModel?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        if note != nil {
            
            titleTextField.text = note?.title
            
            bodyTextView.text = note?.body
            
            // Set the status of the star button
            setStarButton()
        }
        else {
            // Create a new note
            let n = Note(docId: UUID().uuidString, title: titleTextField.text ?? "", body: bodyTextView.text ?? "", isStarred: false, createdAt: Date(), lastUpdatedAt: Date())
            
            self.note = n
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        // Clear the fields
        note = nil
        titleTextField.text = ""
        bodyTextView.text = ""
    }
    
    func setStarButton() {
        
        let imageName = note!.isStarred ? "star.fill" : "star"
        
        starButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        if note != nil {
            notesModel?.deleteNote(note!)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
     
        // This is the update to the existing note
        self.note!.title = titleTextField.text ?? ""
        self.note!.body = bodyTextView.text ?? ""
        self.note!.lastUpdatedAt = Date()
        
        // Save it to the notes model
        self.notesModel?.saveNote(self.note!)
        
        UIView.animate(withDuration: 3, delay: 0, options: .curveLinear, animations: {
            
            self.dismiss(animated: true, completion: nil)
            
        }, completion: nil)
    }
    
    @IBAction func starTapped(_ sender: Any) {
        
        // Change the property in the note
        note?.isStarred.toggle()
        
        // Update the database
        notesModel?.updateFaveStatus(note!.docId, note!.isStarred)
        
        // Update the button
        setStarButton()
        
    }
    
}
