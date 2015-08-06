//
//  MasterViewController.swift
//  BlocNotes
//
//  Created by Charles Wesley Cho on 7/27/15.
//  Copyright (c) 2015 Charles Wesley Cho. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {

    var detailViewController: DetailViewController? = nil
    
    var managedObjectContext: NSManagedObjectContext? = nil
    // Added search Controller
    var searchController: UISearchController!
    var searchPredicate: NSPredicate?
    
    var filteredNotes: [Note]? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        
        // Setup delegates
        tableView.delegate = self
        
        // UISearchController
        searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController?.searchBar
        self.tableView.delegate = self
        self.definesPresentationContext = true
        
        // Question, what is this for? ------------------------
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadList:",name:"load", object: nil)
    }
    
    func loadList(notification: NSNotification){
        //load data here
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func insertNewObject(sender: UIBarButtonItem) {
        let context = self.fetchedResultsController.managedObjectContext
        let entity = self.fetchedResultsController.fetchRequest.entity!
        let newNote = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: context) as! Note
             
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        
        
//        let dateAsString = "July 28, 2015, 11:14 AM"
//        
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "MMM d, yyyy, h:mm a"
//        let date = dateFormatter.dateFromString(dateAsString)
     
        newNote.setValue(NSDate(), forKey: "timeStamp")
        newNote.setValue("Untitled note", forKey: "noteTitle")
        
        // Adding light grey placeholder text for new notes
                //
        newNote.setValue("What do you want to remember and share today?", forKey: "noteText")
        
        // Save the context.
        var error: NSError? = nil
        if !context.save(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                
                // Added ----------------------- Here
                // All notes displayed
                var note: Note!
                if (self.searchController.active) {  // searchBar active
                    note = filteredNotes![indexPath.row] as Note
                    
                } else {                            // searchBar NOT active
                    note = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Note
                }
                
                (segue.destinationViewController as! DetailViewController).detailItem = note
                (segue.destinationViewController as! DetailViewController).managedObjectContext = self.fetchedResultsController.managedObjectContext

            }
            //self.didDismissSearchController(searchController)
            //searchController.active = false // dismisses searchBar when cell selected
        }
    }
    
    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0

    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Added ----------------------- Here
        if (!self.searchController.active) {  // searchBar active

       // if self.searchPredicate == nil {
            let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
            return sectionInfo.numberOfObjects
        } else {
            return filteredNotes?.count ?? 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        // Added ----------------------- Here
        if (!self.searchController.active) {  // searchBar active

        //if searchPredicate == nil {
            self.configureCell(cell, atIndexPath: indexPath)
            return cell
        } else {
            // configure the cell based on filteredObjects data
            if let note = self.filteredNotes?[indexPath.row] {
                cell.textLabel?.text = note.noteTitle
            }
            return cell
        }
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if searchController.active {
            return false
        }
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            var note: Note
            if (!self.searchController.active) {  // searchBar active

            //if searchPredicate == nil {
                note = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Note
            } else {
                let filteredNotes = self.fetchedResultsController.fetchedObjects?.filter() {
                    return self.searchPredicate!.evaluateWithObject($0)
                }
                note = filteredNotes![indexPath.row] as! Note
            }
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(note)
   
            var error: NSError? = nil
            if !context.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //println("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        cell.textLabel!.text = object.valueForKey("noteTitle")!.description
    }
    
    // MARK: - Table View: Search bar
    
    // UISearchResultsUpdating Delegate Method
    // Called when the search bar's text or scope has changed or when the search bar becomes first responder.
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if (!self.searchController.active) {  // searchBar active

            println("updateSearch called when not active")
        }
        let searchText = self.searchController?.searchBar.text
        println(searchController.searchBar.text)
        if let searchText = searchText {
            
            searchPredicate = NSPredicate(format: "noteText contains[c] %@ OR noteTitle contains[c] %@", searchText, searchText)
            filteredNotes = self.fetchedResultsController.fetchedObjects?.filter() {
                return self.searchPredicate!.evaluateWithObject($0)
                } as! [Note]?
            
            self.tableView.reloadData()
            println(searchPredicate)
        }
    }
    
    
    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Note", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
    	var error: NSError? = nil
    	if !_fetchedResultsController!.performFetch(&error) {
    	     // Replace this implementation with code to handle the error appropriately.
    	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             println("Unresolved error \(error), \(error?.userInfo)")
    	     abort()
    	}
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController? = nil

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        if searchPredicate == nil {
            tableView.beginUpdates()
        } else {
            (searchController.searchResultsUpdater as! MasterViewController).tableView.beginUpdates()
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        // Added ----------------------- Here
        var tableView = UITableView()
        if searchPredicate == nil {
            tableView = self.tableView
        } else {
            tableView = (searchController.searchResultsUpdater as! MasterViewController).tableView
        }
        
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        // Added ----------------------- Here
        var tableView = UITableView()
        
        if self.searchPredicate == nil {
            tableView = self.tableView
        } else {
            tableView = (self.searchController.searchResultsUpdater as! MasterViewController).tableView
        }
        
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                
                // Added ----------------------- Here
                if searchPredicate == nil {
                    self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!) // original code
                } else {
                    println("Didn't update cell")
            }
            
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
        if self.searchPredicate == nil {
            self.tableView.endUpdates()
        } else {
            println("controllerDidChangeContent")
            (self.searchController.searchResultsUpdater as! MasterViewController).tableView.endUpdates()
        }
    }
    
    // MARK: - UISearchBar Delegate methods
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResultsForSearchController(self.searchController)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchController.active = false;
        self.searchPredicate = nil
        self.filteredNotes = nil
        self.tableView.reloadData()
    }
    
    // This resets searchPredicate & filteredObjects when the SearchController is dismissed
    func didDismissSearchController(searchController: UISearchController) {
        println("didDismissSearchController")
        self.searchPredicate = nil
        self.filteredNotes = nil
        self.tableView.reloadData()
    }
    
    // MARK: - UISearchControllerDelegate
    
    func presentSearchController(searchController: UISearchController) {
        println("presentSearchController")
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        println("willPresentSearchController")
    }


}

