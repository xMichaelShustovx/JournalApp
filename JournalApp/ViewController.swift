//
//  ViewController.swift
//  JournalApp
//
//  Created by Michael Shustov on 25.10.2021.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var starButton: UIBarButtonItem!
    
    private var notesModel = NotesModel()
    private var notes = [Note]()
    
    private var isStarFiltered = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set datasource and delegate for table view
        tableView.dataSource = self
        tableView.delegate = self
        
        // Set self as the delegate for NotesModel
        notesModel.delegate = self
        
        // Set the status of the star filter button
        setStarFilterButton()
        
        // Retrieve all notes according to the filter status
        notesModel.getNotes(isStarFiltered)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let noteViewController = segue.destination as! NoteViewController
        
        if tableView.indexPathForSelectedRow != nil {
            
            noteViewController.note = notes[tableView.indexPathForSelectedRow!.row]
            
            // Deselect the selected table row
            tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: false)
        }
        
        noteViewController.notesModel = self.notesModel
    }
    
    func setStarFilterButton() {
        
        let imageName = isStarFiltered ? "star.fill" : "star"
        starButton.image = UIImage(systemName: imageName)
        
    }
    
    @IBAction func starFilterTapped(_ sender: Any) {
        
        // Change star filter value
        isStarFiltered.toggle()

        // Get notes array according to the current filter
        notesModel.getNotes(isStarFiltered)
        
        // Show the changes
        DispatchQueue.main.async {
            
            // Change star filer button
            self.setStarFilterButton()
            
            // Reload table view data
            self.tableView.reloadData()
        }
    }
}

// MARK: - Table View Delegate Methods
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        
        // Customize cell
        let titleLabel = cell.viewWithTag(1) as? UILabel
        titleLabel?.text = notes[indexPath.row].title
        
        let bodyLabel = cell.viewWithTag(2) as? UILabel
        bodyLabel?.text = notes[indexPath.row].body
        
        return cell
    }
}

// MARK: - Notes Model Delegate Methods
extension ViewController: NotesModelProtocol{
    
    func retriveData(_ notesArray: [Note]) {
        
        // Set notes property and refresh table view
        self.notes = notesArray
        
        tableView.reloadData()
    }
}
