//
//  AddCommentAndRatingViewController.swift
//  BookClubUpdated
//
//  Created by Felicity Johnson on 11/23/16.
//  Copyright © 2016 FJ. All rights reserved.
//

import UIKit
import Firebase
import Mixpanel

class AddCommentAndRatingViewController: UIViewController {
    
    @IBOutlet weak var addBookButton: UIButton!
    @IBOutlet weak var starView: UIView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var bookCoverImageView: UIImageView!
    @IBOutlet weak var commentsTextField: UITextField!
    
    var passedTitle = String()
    var passedAuthor = String()
    var passedImageLink = String()
    var passedSynopsis = String()
    var star = StarReview()
    weak var searchedBook: SearchedBook!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navBarAttributesDictionary = [ NSForegroundColorAttributeName: UIColor.themeDarkBlue,NSFontAttributeName: UIFont.themeMediumThin]
        navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary
        
        addBookButton.layer.borderColor = UIColor.themeOrange.cgColor
        addBookButton.layer.borderWidth = 4.0
        addBookButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        addBookButton.layer.cornerRadius = 4.0
        addBookButton.setTitleColor(UIColor.themeOrange, for: .normal)
        addBookButton.titleLabel?.font = UIFont.themeSmallBold
        
        ratingLabel.font = UIFont.themeSmallBold
        ratingLabel.textColor = UIColor.themeOrange
        
        commentsLabel.font = UIFont.themeSmallBold
        commentsLabel.textColor = UIColor.themeOrange
        
        commentsTextField.font = UIFont.themeSmallThin
        commentsTextField.textColor = UIColor.themeDarkBlue
        
        print("PASSED BAR CODE IMAGE: \(passedImageLink)")
        
        DispatchQueue.main.async {
            self.bookCoverImageView.loadImageUsingCacheWithURLString(urlString: self.passedImageLink)
        }
        
        
        star = StarReview(frame: CGRect(x: 0, y: 0, width: starView.bounds.width.multiplied(by: 0.8), height: starView.bounds.height))
        star.starCount = 5
        star.value = 1
        star.allowAccruteStars = false
        star.starFillColor = UIColor.themeDarkBlue
        star.starBackgroundColor = UIColor.themeLightBlue
        star.starMarginScale = 0.3
        starView.addSubview(star)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    
    @IBAction func addBookButton(_ sender: Any) {
        
        Mixpanel.mainInstance().track(event: "Post Book")
        let bookToAdd = UserBook(title: passedTitle, author: passedAuthor, synopsis: passedSynopsis, bookUniqueKey: nil, finalBookCoverLink: passedImageLink)
        guard let userUniqueKey = FIRAuth.auth()?.currentUser?.uid else {return}
        let ratingString = String(star.value)
        guard let comment = commentsTextField.text else { print("no comment"); return }
        
        if commentsTextField.text == "" {
            
            let alert = UIAlertController(title: "Oops!", message: "Must write a comment before you can submit a post", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            BooksFirebaseMethods.addToPrevious(userBook: bookToAdd, comment: comment, rating: ratingString, userUniqueID: userUniqueKey, imageLink: passedImageLink, completion: { (doesExist) in
                
                if doesExist == false {
                    let alert = UIAlertController(title: "Success!", message: "You have added \(self.passedTitle) to your previously read list", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                        //self.dismiss(animated: true, completion: nil)
                    }))
                    
                    self.commentsTextField.text = ""
                    self.commentsTextField.resignFirstResponder()
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Oops!", message: "You have already posted \(self.passedTitle)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                        //                                                self.dismiss(animated: true, completion: nil)
                        
                    }))
                    
                    self.commentsTextField.text = ""
                    self.commentsTextField.resignFirstResponder()
                    
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }




/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */

}
