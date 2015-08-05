//
//  DetailViewController.swift
//  BlocNotes
//
//  Created by Charles Wesley Cho on 7/27/15.
//  Copyright (c) 2015 Charles Wesley Cho. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UITextViewDelegate, NSFetchedResultsControllerDelegate {

    var managedObjectContext: NSManagedObjectContext? = nil
    var placeHolderText = "What do you want to remember and share today?"
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet var textView: UITextView!
    
    var detailItem: Note? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: Note = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.timeStamp.description
            }
            
            if let textView = self.textView {
                textView.text = detail.noteText
            }
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        textView.delegate = self

        if let detail: Note = self.detailItem {
            
            if detail.noteText == placeHolderText {
                textView.textColor == UIColor.lightGrayColor()
            } else {
                self.textView.text = detail.noteText
                self.textView.textColor = UIColor.blackColor()
            }
        }
        
        
    }
    
    
    
    // Clear the placeholder text and set the text color to black to accommodate the user's entry.
    
    func textViewDidBeginEditing(textView: UITextView) {
        if let detail: Note = self.detailItem {
            
            if detail.noteText == placeHolderText {
                detail.noteText = ""
                textView.text = ""
                self.textView.textColor = UIColor.blackColor()
            }
        }
    }

    // Reset its placeholder by re-adding the placeholder text and setting its color to light gray.
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "What did you want to remember and share today?"
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    // Add sharing functionality
    
    @IBAction func shareNote(sender: UIButton) {
        let activityViewController = UIActivityViewController(
            activityItems: [textView.text as NSString],
            applicationActivities: nil)
        
        presentViewController(activityViewController, animated: true, completion: nil)
        
    }
    
    // Saving and resigning keyboard

    @IBAction func DismissKeyboard(sender: UIButton) {
        self.view .endEditing(true)
        
    }

    override func viewWillDisappear(animated: Bool) {
        detailItem!.noteText = self.textView.text
        

        if !self.textView.text.isEmpty {
            var textViewString:String = self.textView.text
            
            if let range = self.textView.text.rangeOfString("\n") {
                let rangeOfString = self.textView.text.startIndex ..< range.endIndex
                let firstLine = self.textView.text.substringWithRange(rangeOfString)
                
                detailItem?.noteTitle = firstLine
            }
        }
        
        var error: NSError? = nil
        if !self.managedObjectContext!.save(&error) {
            abort()
        }
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

