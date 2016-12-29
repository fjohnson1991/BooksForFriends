//
//  BookDetailsViewController.swift
//  BookClubUpdated
//
//  Created by Felicity Johnson on 11/26/16.
//  Copyright © 2016 FJ. All rights reserved.
//

import UIKit
import CoreData

class BookDetailsViewController: UIViewController {
    
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var bookSynopsis: UITextView!
    
    @IBOutlet weak var synopsisLabel: UILabel!
    @IBOutlet weak var addBookButton: UIButton!
    var passedUniqueID = String()
    var passedImageLink = String()
    var passedTitle = String()
    var noInternetView: NoInternetView!
    var futureRead: FutureRead!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navBarAttributesDictionary = [ NSForegroundColorAttributeName: UIColor.themeDarkBlue,NSFontAttributeName: UIFont.themeMediumThin]
        navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary
        guard let navBarHeight = self.navigationController?.navigationBar.frame.height else { print("no nav bar height"); return }
        self.noInternetView = NoInternetView(frame: CGRect(x: 0, y: -navBarHeight, width: self.view.frame.width, height: self.view.frame.height))
        
        addBookButton.layer.borderColor = UIColor.themeOrange.cgColor
        addBookButton.layer.borderWidth = 4.0
        addBookButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        addBookButton.layer.cornerRadius = 4.0
        addBookButton.setTitleColor(UIColor.themeOrange, for: .normal)
        addBookButton.titleLabel?.font = UIFont.themeSmallBold
        
        synopsisLabel.font = UIFont.themeSmallBold
        synopsisLabel.textColor = UIColor.themeOrange
        
        bookSynopsis.font = UIFont.themeSmallThin
        bookSynopsis.textColor = UIColor.themeDarkBlue
        bookImageView.loadImageUsingCacheWithURLString(urlString: passedImageLink)
        
        if Reachability.isConnectedToNetwork() == true {
            PostsFirebaseMethods.downloadSynopsisAndAuthorOfBookWith(book: passedUniqueID) { (synopsis, author) in
                self.bookSynopsis.text = synopsis
            }
        } else {
            self.view.addSubview(self.noInternetView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Reachability.isConnectedToNetwork() == true {
            if self.view.subviews.contains(self.noInternetView) {
                self.noInternetView.removeFromSuperview()
            }
        }
    }
    
    func addPostToFutureReadCoreData() {
        let managedContext = BFFCoreData.sharedInstance.persistentContainer.viewContext
        print("passedID: \(passedUniqueID)")
            PostsFirebaseMethods.downloadSynopsisAndAuthorOfBookWith(book: passedUniqueID, completion: { (synopsis, author) in
                let newRead = FutureRead(context: managedContext)
                newRead.title = self.passedTitle
                newRead.imageLink = self.passedImageLink
                newRead.bookUniqueID = self.passedUniqueID
//                guard let unwrappedAuthor = author as? String else { return }
//                guard let unwrappedSynopsis = synopsis as? String else { return }
                newRead.author = author
                newRead.synopsis = synopsis
                BFFCoreData.sharedInstance.saveContext()
            })
    }
    
    @IBAction func addToFutureReads(_ sender: Any) {
        
        PostsFirebaseMethods.checkIfFutureReadsIsEmpty { (isEmpty) in
            if isEmpty == true {
                
                PostsFirebaseMethods.addBookToFutureReadsWith(book: self.passedUniqueID, imageLink: self.passedImageLink, completion: {
                    self.addPostToFutureReadCoreData()
                    let alert = UIAlertController(title: "Success!", message: "You have updated your book list", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        //                                self.dismiss(animated: true, completion: nil)
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                })
            } else {
                
                PostsFirebaseMethods.checkIfAlreadyAddedBookToFutureReadsWith(book: self.passedUniqueID, completion: { (doesExist) in
                    if doesExist == false {
                        self.addPostToFutureReadCoreData()
                        PostsFirebaseMethods.addBookToFutureReadsWith(book: self.passedUniqueID, imageLink: self.passedImageLink, completion: {
                            let alert = UIAlertController(title: "Success!", message: "You have updated your book list", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                //                                self.dismiss(animated: true, completion: nil)
                            }))
                            self.present(alert, animated: true, completion: nil)
                        })
                        
                    } else {
                        let alert = UIAlertController(title: "Oops!", message: "You have already added this to your book list", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            //                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
    }
}
