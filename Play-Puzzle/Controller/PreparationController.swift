//
//  PreparationController.swift
//  Gridly
//
//  Created by Bjørn Lau Jørgensen on 07/01/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class PreparationController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var localImages = [UIImage]()
    var buttonWidth: CGFloat = 130.0
    var buttonHeight: CGFloat = 40.0
    var buttonSpacer: CGFloat = 15.0
    
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var sharedConstraints: [NSLayoutConstraint] = []
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private lazy var viewContainer: UIView = {
        let viewContainer = UIView()
        viewContainer.translatesAutoresizingMaskIntoConstraints = false
        return viewContainer
    }()
    
    private lazy var randomButton: UIButton = {
        let randomButton = UIButton(type: .custom)
        randomButton.translatesAutoresizingMaskIntoConstraints = false
        randomButton.addTarget(self, action: #selector(randomImage), for: UIControl.Event.touchUpInside)
        randomButton.setTitle("Random", for: .normal)
        randomButton.titleLabel?.font = UIFont(name: "Obvia-Medium", size: 14.0)
        randomButton.backgroundColor = UIColor.white
        randomButton.imageView?.contentMode = .scaleAspectFit
        randomButton.layer.cornerRadius = 7.0
        randomButton.setTitleColor(UIColor.black, for: .normal)
        randomButton.setTitleColor(UIColor.white, for: .highlighted)
        randomButton.setImage(UIImage(named: "dice_black"), for: .normal)
        randomButton.setImage(UIImage(named: "dice_white"), for: .highlighted)
        randomButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 70)
        randomButton.titleEdgeInsets = UIEdgeInsets(top: 2, left: -30, bottom: 0, right: 0)
        
        return randomButton
    }()
    
    private lazy var libraryButton: UIButton = {
        let libraryButton = UIButton(type: .custom)
        libraryButton.translatesAutoresizingMaskIntoConstraints = false
        libraryButton.addTarget(self, action: #selector(displayLibrary), for: UIControl.Event.touchUpInside)
        libraryButton.setTitle("Library", for: .normal)
        libraryButton.titleLabel?.font = UIFont(name: "Obvia-Medium", size: 14.0)
        libraryButton.backgroundColor = UIColor.white
        libraryButton.imageView?.contentMode = .scaleAspectFit
        libraryButton.layer.cornerRadius = 7.0
        libraryButton.setTitleColor(UIColor.black, for: .normal)
        libraryButton.setTitleColor(UIColor.white, for: .highlighted)
        libraryButton.setImage(UIImage(named: "library_black"), for: .normal)
        libraryButton.setImage(UIImage(named: "library_white"), for: .highlighted)
        libraryButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 60)
        libraryButton.titleEdgeInsets = UIEdgeInsets(top: 2, left: -40, bottom: 0, right: 0)
        
        return libraryButton
    }()
    
    private lazy var cameraButton: UIButton = {
        let cameraButton = UIButton(type: .custom)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.addTarget(self, action: #selector(displayCamera), for: UIControl.Event.touchUpInside)
        cameraButton.setTitle("Camera", for: .normal)
        cameraButton.titleLabel?.font = UIFont(name: "Obvia-Medium", size: 14.0)
        cameraButton.backgroundColor = UIColor.white
        cameraButton.imageView?.contentMode = .scaleAspectFit
        cameraButton.layer.cornerRadius = 7.0
        cameraButton.setTitleColor(UIColor.black, for: .normal)
        cameraButton.setTitleColor(UIColor.white, for: .highlighted)
        cameraButton.setImage(UIImage(named: "camera_black"), for: .normal)
        cameraButton.setImage(UIImage(named: "camera_white"), for: .highlighted)
        cameraButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 60)
        cameraButton.titleEdgeInsets = UIEdgeInsets(top: 2, left: -37, bottom: 0, right: 0)
        
        return cameraButton
    }()
    
    private lazy var infoLabel: UILabel = {
        let infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.font = UIFont(name: "Obvia-Light", size: 14.0)
        infoLabel.text = "-- Or load your own --"
        infoLabel.textColor = UIColor.white
        return infoLabel
    }()
    
    private lazy var logo: UIImageView = {
        let logo = UIImageView()
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.image = UIImage(named: "play_puzzle_logo")
        logo.contentMode = .scaleAspectFit
        
        return logo
    }()
    
    func setupUI() {
        view.addSubview(viewContainer)
        viewContainer.addSubview(randomButton)
        viewContainer.addSubview(libraryButton)
        viewContainer.addSubview(cameraButton)
        viewContainer.addSubview(infoLabel)
        viewContainer.addSubview(logo)
    }
    
    func setupConstraints() {
        sharedConstraints.append(contentsOf: [
            viewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            viewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15),
            viewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            viewContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            
            logo.centerYAnchor.constraint(equalTo: viewContainer.centerYAnchor, constant: -90),
            logo.centerXAnchor.constraint(equalTo: viewContainer.centerXAnchor),
            logo.widthAnchor.constraint(equalTo: viewContainer.widthAnchor, constant: -70),
            logo.heightAnchor.constraint(equalToConstant: 150.0),
            
            randomButton.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 40),
            randomButton.centerXAnchor.constraint(equalTo: viewContainer.centerXAnchor),
            randomButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            randomButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            infoLabel.topAnchor.constraint(equalTo: randomButton.bottomAnchor, constant: buttonSpacer),
            infoLabel.centerXAnchor.constraint(equalTo: viewContainer.centerXAnchor),
            
            libraryButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: buttonSpacer),
            libraryButton.centerXAnchor.constraint(equalTo: viewContainer.centerXAnchor, constant: -buttonWidth / 2 - buttonSpacer / 2 ),
            libraryButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            libraryButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            cameraButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: buttonSpacer),
            cameraButton.leadingAnchor.constraint(equalTo: libraryButton.trailingAnchor, constant: buttonSpacer),
            cameraButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            cameraButton.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])
        
        regularConstraints.append(contentsOf: [
            // Regular constraints
        ])
        
        compactConstraints.append(contentsOf: [
            //  Compact constraints
        ])
    }
    
    
    func layoutTrait(traitCollection:UITraitCollection) {
        if (!sharedConstraints[0].isActive) {
            // activating shared constraints
            NSLayoutConstraint.activate(sharedConstraints)
        }
        if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular {
            if regularConstraints.count > 0 && regularConstraints[0].isActive {
                NSLayoutConstraint.deactivate(regularConstraints)
            }
            // activating compact constraints
            NSLayoutConstraint.activate(compactConstraints)
        } else {
            if compactConstraints.count > 0 && compactConstraints[0].isActive {
                NSLayoutConstraint.deactivate(compactConstraints)
            }
            // activating regular constraints
            NSLayoutConstraint.activate(regularConstraints)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layoutTrait(traitCollection: traitCollection)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        collectLocalImages()
        setupUI()
        setupConstraints()
        NSLayoutConstraint.activate(sharedConstraints)
        layoutTrait(traitCollection: UIScreen.main.traitCollection)
    }
    
    func troubleAlert(errorMessage: String, linkToSettings: Bool) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Oops! 😓", message: errorMessage, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
            alertController.addAction(cancelAction)
            
            if linkToSettings {
                let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (success) in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                })
                
                alertController.addAction(settingsAction)
            }
            self.present(alertController, animated: true)
        }
    }
    
    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let newImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        processedPicked(image: newImage)
    }
    
    @objc func displayCamera() {
        let sourceType = UIImagePickerController.SourceType.camera
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            let noPermissionMessage = "No permission to camera."
            
            switch status {
            case .authorized:
                self.presentImagePicker(sourceType: sourceType)
            case .denied, .restricted:
                troubleAlert(errorMessage: noPermissionMessage, linkToSettings: true)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                    if granted {
                        self.presentImagePicker(sourceType: sourceType)
                    } else {
                        self.troubleAlert(errorMessage: noPermissionMessage, linkToSettings: true)
                    }
                })
            default:
                troubleAlert(errorMessage: "We can't access your camera. Maybe you didn't give us access?", linkToSettings: true)
            }
        } else {
            troubleAlert(errorMessage: "There was a problem with your camera.", linkToSettings: false)
        }
    }
    
    @objc func displayLibrary() {
        
        let photos = UIImagePickerController.SourceType.photoLibrary
        
        if UIImagePickerController.isSourceTypeAvailable(photos) {
            let status = PHPhotoLibrary.authorizationStatus()
            let noPermissionMessage = "We don't have access to your photos."
            
            switch status {
            case .authorized:
                presentImagePicker(sourceType: photos)
            case .denied, .restricted:
                troubleAlert(errorMessage: noPermissionMessage, linkToSettings: true)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({(newStatus) in
                    if newStatus == .authorized {
                        self.presentImagePicker(sourceType: photos)
                    } else {
                        self.troubleAlert(errorMessage: noPermissionMessage, linkToSettings: true)
                    }
                })
            default:
                troubleAlert(errorMessage: "We can't access your photos. Maybe you didn't give us access?", linkToSettings: true)
            }
            
        } else {
            troubleAlert(errorMessage: "You don't seem to have any photos in your library.", linkToSettings: false)
        }
    }
    
    @objc func chooseRandomImage() -> UIImage? {
        let currentImage = Tile.originalImage
        
        if localImages.count > 0 {
            while true {
                
                let randomIndex = Int.random(in: 0..<localImages.count)
                let newImage = localImages[randomIndex]
                
                if newImage != currentImage {
                    return newImage
                }
            }
        }
        return nil
    }
    
    func collectLocalImages() {
        localImages.removeAll()
        let imageNames = ["italy", "waves", "fox", "butterfly", "aurora"]
        
        for name in imageNames {
            if let image = UIImage(named: name) {
                localImages.append(image)
            }
        }
    }
    
    @objc func randomImage() {
        processedPicked(image: chooseRandomImage())
    }
    
    func processedPicked(image: UIImage?) {
        if let newImage = image {
            Tile.originalImage = newImage
            performSegue(withIdentifier: "toGameSegue", sender: self)
        }
    }
    @IBAction func unwindAction(unwindSegue: UIStoryboardSegue) {}
}
