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
//    var placeHolderText = "What do you want to remember and share today?"
    
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
        
        self.textView.editable = false
        self.textView.dataDetectorTypes = UIDataDetectorTypes.All

//        // A color gradient to Detail View
//        let colors = Colors()
//        
//        textView.backgroundColor = UIColor.clearColor()
//        var backgroundLayer = colors.gl
//        backgroundLayer.frame = view.frame
//        textView.layer.insertSublayer(backgroundLayer, atIndex: 0)
        
        // Make Bottom Toolbar transparent ------------------------------------------ I want to make the toolbar transparent with white tint!
        self.navigationController?.setToolbarHidden(false, animated: false)      // Unhide bottom toolbar for DetailVC
    

        self.navigationController?.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        self.navigationController?.toolbar.setShadowImage(UIImage(), forToolbarPosition: UIBarPosition.Any)

        // Make links this color #03AFFF
        self.textView.linkTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 3.0/255.0, green: 175.0/255.0, blue: 255.0/255.0, alpha: 1.0),
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]

        if let detail: Note = self.detailItem {
            self.textView.text = detail.noteText
           
            // MARK: - TODO - Add placeholder
//            if detail.noteText == placeHolderText {
//                textView.textColor == UIColor.lightGrayColor()
//            } else {
//                self.textView.textColor = UIColor.blackColor()
//            }
        }

    }
    
    // Clear the placeholder text and set the text color to black to accommodate the user's entry.
    
//    func textViewDidBeginEditing(textView: UITextView) {
//        if let detail: Note = self.detailItem {
//            
//            if detail.noteText == placeHolderText {
//                detail.noteText = ""
//                textView.text = ""
//                self.textView.textColor = UIColor.blackColor()
//            }
//        }
//    }
//
//    // Reset its placeholder by re-adding the placeholder text and setting its color to light gray.
//    
//    func textViewDidEndEditing(textView: UITextView) {
//        if textView.text.isEmpty {
//            textView.text = "What did you want to remember and share today?"
//            textView.textColor = UIColor.lightGrayColor()
//        }
//    }
    
    // Add sharing functionality
    
    
    @IBAction func shareNote(sender: UIBarButtonItem) {
        let activityViewController = UIActivityViewController(
            activityItems: [textView.text as NSString],
            applicationActivities: nil)
        
        presentViewController(activityViewController, animated: true, completion: nil)
        
    }
    
    // Saving and resigning keyboard

    @IBAction func didTapToEdit(sender: UITapGestureRecognizer) {
        
        self.textView.dataDetectorTypes = UIDataDetectorTypes.None
        self.textView.editable = true
        [self.textView .becomeFirstResponder()]
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "DismissKeyboard:")
        self.navigationItem.rightBarButtonItem = doneButton
        
    }
    
    func textViewDidEndEditing(textView: UITextView) {
         self.navigationItem.rightBarButtonItem = nil
        
         self.textView.editable = false
         self.textView.dataDetectorTypes = UIDataDetectorTypes.All

    }
    
    @IBAction func DismissKeyboard(UIBarButtonItem) {
        self.view.endEditing(true)
        
        // Done button pressed will activate UIDataDetectors
        // Find actionable text and format

    }
    

    // Attempting to get rid of the first tap to activate the Textview then the second tap to start editing
    
//    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
//        self.textView.editable = true
//        return true
//    }
    
//    // Tap anywhere in the textView to trigger this UITapGestureRecognizer
//    
//    @IBAction func tapToEdit(UITapGestureRecognizer) {
//        self.textViewShouldBeginEditing(textView)
//    }
   

    override func viewWillDisappear(animated: Bool) {
        detailItem!.noteText = self.textView.text
        

        if !self.textView.text.isEmpty {
            var textViewString:String = self.textView.text
            
            if let range = self.textView.text.rangeOfString("\n") {  // Save a title after hitting return/enter
                let rangeOfString = self.textView.text.startIndex ..< range.endIndex
                let firstLine = self.textView.text.substringWithRange(rangeOfString)
                
                detailItem?.noteTitle = firstLine
            } else {
                let length = count(self.textView.text)
                if length > 30 {
                    let firstLine = (textView.text as NSString).substringToIndex(30) // first 30 characters as the title

                    detailItem?.noteTitle = firstLine
                } else {
                    let firstLine = (textView.text as NSString).substringToIndex(length)  // else any characters with a total length < 30
                    detailItem?.noteTitle = firstLine
                }
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

