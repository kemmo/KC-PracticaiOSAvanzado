//
//  NoteViewController.swift
//  Everpobre
//
//  Created by Joaquin Perez on 08/03/2018.
//  Copyright © 2018 Joaquin Perez. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class NoteViewController: UIViewController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var expirationDateTextField: UITextField!
    @IBOutlet weak var notebookTextField: UITextField!
    @IBOutlet weak var stackMapView: UIStackView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationView: MKMapView!
    
    private lazy var presenter = NotePresenter(viewController: self, delegate: self)
    
    var imageViews = [UIImageView]()
    var imageConstraints = [Int: (relativePoint: CGPoint, topImgConstraint: NSLayoutConstraint, bottomImgConstraint: NSLayoutConstraint, leftImgConstraint: NSLayoutConstraint, rightImgConstraint: NSLayoutConstraint)]()
    
    var newImageViews = [UIImage]()
    
    var latitude: Double?
    var longitude: Double?
    
    var note: Note?
    var notebook: Notebook?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupToolbar()
        setupGestures()
        
        titleTextField.delegate = self
        contentTextView.delegate = self
        
        presenter.fetchNotebooks(less: note?.notebook?.name ?? "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        setupNote()
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveNote))
        navigationController?.isToolbarHidden = false
        navigationItem.title = "Note"
    }
    
    private func setupToolbar() {
        let photoBarButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(catchPhoto))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let mapBarButton = UIBarButtonItem(title: "Map", style: .done, target: self, action: #selector(addLocation))
        self.setToolbarItems([photoBarButton,flexible,mapBarButton], animated: false)
    }
    
    private func setupNote() {
        for img in imageViews {
            img.removeFromSuperview()
        }
        
        imageViews = [UIImageView]()
        
        if let note = note {
            notebook = note.notebook
            
            if note.hasMap {
                latitude = note.latitude
                longitude = note.longitude
            }
            
            if latitude != nil {
                stackMapView.isHidden = false
                
                locationView.delegate = self
                
                let region = MKCoordinateRegion(center:
                    CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!),
                                                span: MKCoordinateSpan(latitudeDelta: 0.0045, longitudeDelta: 0.0045))
                locationView.setRegion(region, animated: false)
                
            } else {
                stackMapView.isHidden = true
            }
            
            titleTextField.text = note.title
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            dateLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: note.createdAtTI))
            
            if note.expiredAtTI != 0 {
                expirationDateTextField.text = dateFormatter.string(from: Date(timeIntervalSince1970: note.expiredAtTI))
            }
            
            notebookTextField.text = notebook?.name
            contentTextView.text = note.content
            
            if let pictures = note.pictures {
                for imageData in pictures {
                    let p = imageData as! Picture
                    addNewImageView(with: UIImage.init(data: p.picture!)!)
                }
            }
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            dateLabel.text = dateFormatter.string(from: Date())
            
            if latitude != nil {
                stackMapView.isHidden = false
                
                locationView.delegate = self
                
                let region = MKCoordinateRegion(center:
                    CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!),
                                                span: MKCoordinateSpan(latitudeDelta: 0.0045, longitudeDelta: 0.0045))
                locationView.setRegion(region, animated: false)
            } else {
                stackMapView.isHidden = true
            }
        }
        
        for img in newImageViews {
            addNewImageView(with: img)
        }
    }
    
    private func setupGestures() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(closeKeyboard))
        swipeGesture.direction = .down
        view.addGestureRecognizer(swipeGesture)
    
        let tapExpirationGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnExpiration))
        expirationDateTextField.addGestureRecognizer(tapExpirationGesture)
        
        let tapNotebookGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnChangeNotebook))
        notebookTextField.addGestureRecognizer(tapNotebookGesture)
    }
    
    @objc private func saveNote() {
        if notebook == nil {
            let alertController = UIAlertController(title: "Error", message: "You must select notebook", preferredStyle: UIAlertControllerStyle.alert)
            let alertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default, handler: {
                alert -> Void in
                alertController.dismiss(animated: false, completion: nil)
            })
            
            alertController.addAction(alertAction)
            
            self.present(alertController, animated: true)
            
            return
        }
        
        if titleTextField.text == "" {
            let alertController = UIAlertController(title: "Error", message: "You must write a title", preferredStyle: UIAlertControllerStyle.alert)
            let alertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default, handler: {
                alert -> Void in
                alertController.dismiss(animated: false, completion: nil)
            })
            
            alertController.addAction(alertAction)
            
            self.present(alertController, animated: true)
            
            return
        }
        
        if let note = note {
            note.title = titleTextField.text
            note.content = contentTextView.text
            
            if let expiration = expirationDateTextField.text, expiration != "" {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                dateFormatter.timeZone = TimeZone.current
                let expirationDate = dateFormatter.date(from: expiration)
                note.expiredAtTI = (expirationDate?.timeIntervalSince1970)!
            } else {
                note.expiredAtTI = 0
            }
            
            if let latitude = latitude, let longitude = longitude {
                note.hasMap = true
                note.latitude = latitude
                note.longitude = longitude
            }
            
            note.notebook = notebook
            
            for picture in newImageViews {
                let p = NSEntityDescription.insertNewObject(forEntityName: "Picture", into: note.managedObjectContext!) as! Picture
                p.picture = UIImageJPEGRepresentation(picture, 0.0)
                p.note = note
                
                try! note.managedObjectContext?.save()
            }
            
            try! note.managedObjectContext?.save()
            
            newImageViews = [UIImage]()
            
            let alertController = UIAlertController(title: "Saved", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let alertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default, handler: {
                alert -> Void in
                alertController.dismiss(animated: false, completion: nil)
            })
            
            alertController.addAction(alertAction)
            
            self.present(alertController, animated: true)
        } else {
            var expDate: Double = 0
            if let expiration = expirationDateTextField.text, expiration != "" {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                dateFormatter.timeZone = TimeZone.current
                let expirationDate = dateFormatter.date(from: expiration)
                expDate = (expirationDate?.timeIntervalSince1970)!
            }
            
            var lat: Double?
            var long: Double?
            if let latitude = latitude, let longitude = longitude {
                lat = latitude
                long = longitude
            }
            
            NoteManager.createNote(with: titleTextField.text!, createdDate: Date().timeIntervalSince1970, expirationDate: expDate, content: contentTextView.text, latitude: lat, longitude: long, pictures: newImageViews,in: (notebook?.name)!) {
                
                self.newImageViews = [UIImage]()

                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Saved", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    let alertAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default, handler: {
                        alert -> Void in
                        alertController.dismiss(animated: false, completion: nil)
                    })
                    
                    alertController.addAction(alertAction)
                    
                    self.present(alertController, animated: true)
                }
            }
        }
    }

    @objc func userMoveImage(longPressGesture:UILongPressGestureRecognizer) {
        let imgTag = longPressGesture.view!.tag
        
        switch longPressGesture.state {
        case .began:
            closeKeyboard()
            imageConstraints[imgTag]!.relativePoint = longPressGesture.location(in: longPressGesture.view)
            UIView.animate(withDuration: 0.1, animations: {
                self.imageViews[imgTag].transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
            })
        case .changed:
            let location = longPressGesture.location(in: contentTextView)
            
            imageConstraints[imgTag]!.leftImgConstraint.constant = location.x - imageConstraints[imgTag]!.relativePoint.x
            imageConstraints[imgTag]!.topImgConstraint.constant = location.y - imageConstraints[imgTag]!.relativePoint.y
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.1, animations: {
                self.imageViews[imgTag].transform = CGAffineTransform.init(scaleX: 1, y: 1)
            })
        default:
            break
        }
    }
    
    @objc func userScaleImage(scaleGesture:UIPinchGestureRecognizer) {
        let imgTag = scaleGesture.view!.tag
        if scaleGesture.scale > 0.7 && scaleGesture.scale < 1.3 {
            imageViews[imgTag].transform = (imageViews[imgTag].transform).scaledBy(x: scaleGesture.scale, y: scaleGesture.scale)
        }
        
        scaleGesture.scale = 1.0
    }
    
    @objc func userRotateImage(rotateGesture:UIRotationGestureRecognizer) {
        let rotation = rotateGesture.rotation
        let currentTrans = rotateGesture.view?.transform
        let newTrans = currentTrans!.rotated(by: rotation)
        rotateGesture.view?.transform = newTrans
    }
    
    @objc private func closeKeyboard() {
        if contentTextView.isFirstResponder {
            contentTextView.resignFirstResponder()
        } else if titleTextField.isFirstResponder {
            titleTextField.resignFirstResponder()
        }
    }
    
    @objc private func tapOnExpiration() {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250, height: 300)
        
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 250, height: 300))
        datePicker.datePickerMode = .date
        
        let gregorian = Calendar(identifier: .gregorian)
        var maxDateComponents = DateComponents()
        maxDateComponents.year = 100
        let maxDate = gregorian.date(byAdding: maxDateComponents, to: Date())
    
        datePicker.minimumDate = Date()
        datePicker.maximumDate = maxDate

        vc.view.addSubview(datePicker)
        
        let expirationDateAlert = UIAlertController(title: "Choose expiration date", message: "", preferredStyle: UIAlertControllerStyle.alert)
        expirationDateAlert.setValue(vc, forKey: "contentViewController")
        expirationDateAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: { alert -> Void in
            let date = datePicker.date
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            self.expirationDateTextField.text = dateFormatter.string(from: date)
        }))
        
        expirationDateAlert.addAction(UIAlertAction(title: "Delete current expiration date", style: .destructive, handler: { alert -> Void in
            self.expirationDateTextField.text = ""
            expirationDateAlert.dismiss(animated: true, completion: nil)
        }))
        
        expirationDateAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(expirationDateAlert, animated: true)
    }
    
    @objc private func tapOnChangeNotebook() {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 300)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 300))
        pickerView.delegate = self
        pickerView.dataSource = self
        vc.view.addSubview(pickerView)
        
        let selectNotebookAlert = UIAlertController(title: "Choose notebook", message: "", preferredStyle: UIAlertControllerStyle.alert)
        selectNotebookAlert.setValue(vc, forKey: "contentViewController")
        selectNotebookAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: { alert -> Void in
            self.notebook = self.presenter.getNotebook(at: pickerView.selectedRow(inComponent: 0))
            self.notebookTextField.text = self.notebook!.name!
            self.presenter.fetchNotebooks(less: self.notebook!.name!)
        }))
        selectNotebookAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(selectNotebookAlert, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        /*var rect = view.convert(imageView.frame, to: noteTextView)
        rect = rect.insetBy(dx: -15, dy: -15)
        
        let paths = UIBezierPath(rect: rect)
        noteTextView.textContainer.exclusionPaths = [paths]*/
    }
    
    // MARK: Toolbar Buttons actions
    @objc func catchPhoto(_ sender: Any?) {
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
        
        if let popoverController = actionSheetAlert.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        
        present(actionSheetAlert, animated: true, completion: nil)
    }
    
    @objc func addLocation() {
        let selectMap = MapViewController()
        selectMap.delegate = self
        selectMap.initialLongitude = longitude
        selectMap.initialLatitude = latitude
        
        navigationController?.pushViewController(selectMap, animated: true)
    }
    
    // MARK: Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        newImageViews.append(image)
        
        addNewImageView(with: image)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func addNewImageView(with image: UIImage) {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tag = imageViews.count
        imageView.image = image
        
        self.view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        imageView.isUserInteractionEnabled = true
        
        let moveViewGesture = UILongPressGestureRecognizer(target: self, action: #selector(userMoveImage))
        let scaleViewGesture = UIPinchGestureRecognizer(target: self, action: #selector(userScaleImage))
        let rotateViewGesture = UIRotationGestureRecognizer(target: self, action: #selector(userRotateImage))
        
        imageView.addGestureRecognizer(moveViewGesture)
        imageView.addGestureRecognizer(scaleViewGesture)
        imageView.addGestureRecognizer(rotateViewGesture)
        
        // Img View Constraint.
        let topImgConstraint = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: contentTextView, attribute: .top, multiplier: 1, constant: 20)
        let bottomImgConstraint = NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: contentTextView, attribute: .bottom, multiplier: 1, constant: -20)
        let leftImgConstraint = NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .equal, toItem: contentTextView, attribute: .left, multiplier: 1, constant: 20)
        let rightImgConstraint = NSLayoutConstraint(item: imageView, attribute: .right, relatedBy: .equal, toItem: contentTextView, attribute: .right, multiplier: 1, constant: -20)
        
        var imgConstraints = [NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 100)]
        imgConstraints.append(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 100))
        
        imgConstraints.append(contentsOf: [topImgConstraint,bottomImgConstraint,leftImgConstraint,rightImgConstraint])
        
        self.view.addConstraints(imgConstraints)
        
        NSLayoutConstraint.deactivate([bottomImgConstraint,rightImgConstraint])
        
        imageViews.append(imageView)
        imageConstraints[imageView.tag] = (relativePoint: CGPoint(x: 0, y: 0), topImgConstraint: topImgConstraint, bottomImgConstraint: bottomImgConstraint, leftImgConstraint: leftImgConstraint, rightImgConstraint: rightImgConstraint)
    }
}

extension NoteViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return presenter.notebooks.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let notebook = presenter.getNotebook(at: row)
        let text = NSMutableAttributedString(string: notebook.name!)
        if notebook.isDefault {
            text.addAttribute(.foregroundColor, value: UIColor.red, range: NSMakeRange(0, text.length))
        }
        
        return text
    }
}

extension NoteViewController: MapViewControllerDelegate {
    func savedLocation(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension NoteViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let centerCoord = mapView.centerCoordinate
        
        let location = CLLocation(latitude: centerCoord.latitude, longitude: centerCoord.longitude)
        
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { (placeMarkArray, error) in
            if let places = placeMarkArray {
                if let place = places.first {
                    DispatchQueue.main.async {
                        if let postalAdd = place.postalAddress {
                            self.locationLabel.text = "\(postalAdd.street), \(postalAdd.city)"
                        }
                    }
                }
            }
        }
    }
}

extension NoteViewController: NotePresenterDelegate {}
