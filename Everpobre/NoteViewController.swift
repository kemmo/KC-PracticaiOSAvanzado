//
//  NoteViewController.swift
//  Everpobre
//
//  Created by Joaquin Perez on 08/03/2018.
//  Copyright © 2018 Joaquin Perez. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var expirationDate: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    
    var bottomImgConstraint: NSLayoutConstraint!
    var rightImgConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var topImgConstraint: NSLayoutConstraint!
 
    @IBOutlet weak var leftImgConstraint: NSLayoutConstraint!
   
    
    var relativePoint: CGPoint!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // MARK: Constraint by code
        bottomImgConstraint = NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: noteTextView, attribute: .bottom, multiplier: 1, constant: -20)
        rightImgConstraint = NSLayoutConstraint(item: imageView, attribute: .right, relatedBy: .equal, toItem: noteTextView, attribute: .right, multiplier: 1, constant: -20)
        let constArray:[NSLayoutConstraint] = [bottomImgConstraint, rightImgConstraint]
        view.addConstraints(constArray)
        NSLayoutConstraint.deactivate(constArray)
        
        
        // MARK: Navigation Controller
        navigationController?.isToolbarHidden = false
        
        let photoBarButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(catchPhoto))
        
//        let fixSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)  // Ready to use.
        
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let mapBarButton = UIBarButtonItem(title: "Map", style: .done, target: self, action: #selector(addLocation))
        
        self.setToolbarItems([photoBarButton,flexible,mapBarButton], animated: false)
        
        // MARK: Gestures
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(closeKeyboard))
        swipeGesture.direction = .down
        
        view.addGestureRecognizer(swipeGesture)
        
        imageView.isUserInteractionEnabled = true
        
        //        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(moveImage))
        //
        //        doubleTapGesture.numberOfTapsRequired = 2
        //
        //        imageView.addGestureRecognizer(doubleTapGesture)
        
        let moveViewGesture = UILongPressGestureRecognizer(target: self, action: #selector(userMoveImage))
        
        imageView.addGestureRecognizer(moveViewGesture)
        
    }
    
    @objc func userMoveImage(longPressGesture:UILongPressGestureRecognizer)
    {
        switch longPressGesture.state {
        case .began:
            closeKeyboard()
            relativePoint = longPressGesture.location(in: longPressGesture.view)
            UIView.animate(withDuration: 0.1, animations: {
                self.imageView.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
            })
            
        case .changed:
            let location = longPressGesture.location(in: noteTextView)
            
            leftImgConstraint.constant = location.x - relativePoint.x
            topImgConstraint.constant = location.y - relativePoint.y
            
        case .ended, .cancelled:
            
            UIView.animate(withDuration: 0.1, animations: {
                self.imageView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            })
            
        default:
            break
        }
        
    }
    
    
    @objc func moveImage(tapGesture:UITapGestureRecognizer)
    {
        
        if topImgConstraint.isActive
        {
            if leftImgConstraint.isActive
            {
                leftImgConstraint.isActive = false
                rightImgConstraint.isActive = true
            }
            else
            {
                topImgConstraint.isActive = false
                bottomImgConstraint.isActive = true
            }
        }
        else
        {
            if leftImgConstraint.isActive
            {
                bottomImgConstraint.isActive = false
                topImgConstraint.isActive = true
            }
            else
            {
                rightImgConstraint.isActive = false
                leftImgConstraint.isActive = true
            }
        }
        
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    @objc func closeKeyboard()
    {
        
        
        if noteTextView.isFirstResponder
        {
            noteTextView.resignFirstResponder()
        }
        else if titleTextField.isFirstResponder
        {
            titleTextField.resignFirstResponder()
        }
    }
    
    
    override func viewDidLayoutSubviews()
    {
        var rect = view.convert(imageView.frame, to: noteTextView)
        rect = rect.insetBy(dx: -15, dy: -15)
        
        let paths = UIBezierPath(rect: rect)
        noteTextView.textContainer.exclusionPaths = [paths]
    }
    
    // MARK: Toolbar Buttons actions
    
    @objc func catchPhoto()
    {
        let actionSheetAlert = UIAlertController(title: NSLocalizedString("Add photo", comment: "Add photo"), message: nil, preferredStyle: .actionSheet)
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let useCamera = UIAlertAction(title: "Camera", style: .default) { (alertAction) in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let usePhotoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (alertAction) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        
        actionSheetAlert.addAction(useCamera)
        actionSheetAlert.addAction(usePhotoLibrary)
        actionSheetAlert.addAction(cancel)
        
        
        
        present(actionSheetAlert, animated: true, completion: nil)
    }
    
    @objc func addLocation()
    {
        
    }
    
    
    // MARK: Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        imageView.image = image
        
        picker.dismiss(animated: true, completion: nil)
        
    }




}
