//
//  ResultController.swift
//  Gridly
//
//  Created by Bjørn Lau Jørgensen on 07/01/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class ResultController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    var score = ""
    var buttonWidth: CGFloat = 130.0
    var buttonHeight: CGFloat = 40.0
    var buttonSpacer: CGFloat = 15.0
    
    private var sharedConstraints: [NSLayoutConstraint] = []
    private var iPhonePortraitConstraints: [NSLayoutConstraint] = []
    private var iPhoneLandscapeConstraints: [NSLayoutConstraint] = []
    private var iPadPortraitConstraints: [NSLayoutConstraint] = []
    private var iPadLandscapeConstraints: [NSLayoutConstraint] = []
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private lazy var viewContainer: UIView = {
        let viewContainer = UIView()
        viewContainer.translatesAutoresizingMaskIntoConstraints = false
        return viewContainer
    }()
    
    private lazy var shareButton: UIButton = {
        let shareButton = UIButton(type: .custom)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.addTarget(self, action: #selector(displaySharingOptions), for: UIControl.Event.touchUpInside)
        shareButton.setTitle("Share result", for: .normal)
        shareButton.titleLabel?.font = UIFont(name: "Obvia-Medium", size: 14.0)
        shareButton.backgroundColor = UIColor.white
        shareButton.imageView?.contentMode = .scaleAspectFit
        shareButton.layer.cornerRadius = 7.0
        shareButton.setTitleColor(UIColor.black, for: .normal)
        shareButton.setTitleColor(UIColor.white, for: .highlighted)
        shareButton.setImage(UIImage(named: "share_black"), for: .normal)
        shareButton.setImage(UIImage(named: "share_white"), for: .highlighted)
        shareButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 14, right: 85)
        shareButton.titleEdgeInsets = UIEdgeInsets(top: 2, left: -23, bottom: 0, right: 0)
        return shareButton
    }()
    
    private lazy var newGameButton: UIButton = {
        let libraryButton = UIButton(type: .custom)
        libraryButton.translatesAutoresizingMaskIntoConstraints = false
        libraryButton.addTarget(self, action: #selector(unwindToStart), for: UIControl.Event.touchUpInside)
        libraryButton.setTitle("New game", for: .normal)
        libraryButton.titleLabel?.font = UIFont(name: "Obvia-Medium", size: 14.0)
        libraryButton.backgroundColor = UIColor.white
        libraryButton.imageView?.contentMode = .scaleAspectFit
        libraryButton.layer.cornerRadius = 7.0
        libraryButton.setTitleColor(UIColor.black, for: .normal)
        libraryButton.setTitleColor(UIColor.white, for: .highlighted)
        libraryButton.setImage(UIImage(named: "rocket_black"), for: .normal)
        libraryButton.setImage(UIImage(named: "rocket_white"), for: .highlighted)
        libraryButton.imageEdgeInsets = UIEdgeInsets(top: 11, left: 0, bottom: 12, right: 75)
        libraryButton.titleEdgeInsets = UIEdgeInsets(top: 2, left: -30, bottom: 0, right: 0)
        return libraryButton
    }()
    
    private lazy var scoreLabel: UILabel = {
        let scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.font = UIFont(name: "Obvia-Medium", size: 14.0)
        scoreLabel.text = score
        scoreLabel.textColor = UIColor.white
        scoreLabel.textAlignment = .center
        return scoreLabel
    }()
    
    private lazy var gratzLabel: UILabel = {
        let gratzLabel = UILabel()
        gratzLabel.translatesAutoresizingMaskIntoConstraints = false
        gratzLabel.font = UIFont(name: "Obvia-Bold", size: 22.0)
        gratzLabel.text = "Congratulation! 😍🎉"
        gratzLabel.textColor = UIColor.white
        gratzLabel.textAlignment = .center
        return gratzLabel
    }()
    
    
    private lazy var resultImage: UIImageView = {
        let resultImage = UIImageView()
        resultImage.translatesAutoresizingMaskIntoConstraints = false
        resultImage.contentMode = .scaleAspectFill
        resultImage.layer.borderWidth = 5
        resultImage.layer.borderColor = UIColor.white.cgColor
        return resultImage
    }()
    
    
    func setupConstraints() {
        sharedConstraints.append(contentsOf: [
            viewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            viewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15),
            viewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            viewContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
        ])
        
        iPhonePortraitConstraints.append(contentsOf: [
            gratzLabel.centerXAnchor.constraint(equalTo: viewContainer.centerXAnchor),
            gratzLabel.bottomAnchor.constraint(equalTo: resultImage.topAnchor, constant: -30),
            gratzLabel.widthAnchor.constraint(equalTo: viewContainer.widthAnchor),
            gratzLabel.heightAnchor.constraint(equalToConstant: 40.0),
            
            resultImage.centerXAnchor.constraint(equalTo: viewContainer.centerXAnchor),
            resultImage.centerYAnchor.constraint(equalTo: viewContainer.centerYAnchor),
            resultImage.widthAnchor.constraint(equalTo: viewContainer.widthAnchor, constant: -50),
            resultImage.heightAnchor.constraint(equalTo: viewContainer.widthAnchor, constant: -50),
            
            scoreLabel.centerXAnchor.constraint(equalTo: viewContainer.centerXAnchor),
            scoreLabel.topAnchor.constraint(equalTo: resultImage.bottomAnchor, constant: 20),
            scoreLabel.widthAnchor.constraint(equalTo: viewContainer.widthAnchor),
            scoreLabel.heightAnchor.constraint(equalToConstant: 50.0),
            
            shareButton.centerXAnchor.constraint(equalTo: viewContainer.centerXAnchor, constant: -buttonWidth / 2 - buttonSpacer / 2),
            shareButton.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            shareButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            shareButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            newGameButton.leftAnchor.constraint(equalTo: shareButton.rightAnchor, constant: buttonSpacer),
            newGameButton.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            newGameButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            newGameButton.heightAnchor.constraint(equalToConstant: buttonHeight),
        ])
        
        
        iPhoneLandscapeConstraints.append(contentsOf: [
           gratzLabel.bottomAnchor.constraint(equalTo: resultImage.topAnchor),
           gratzLabel.centerXAnchor.constraint(equalTo: viewContainer.centerXAnchor),
           gratzLabel.widthAnchor.constraint(equalToConstant: 250),
           gratzLabel.heightAnchor.constraint(equalToConstant: 40.0),
           
           resultImage.centerXAnchor.constraint(equalTo: viewContainer.centerXAnchor),
           resultImage.centerYAnchor.constraint(equalTo: viewContainer.centerYAnchor),
           resultImage.widthAnchor.constraint(equalTo: viewContainer.heightAnchor, constant: -100),
           resultImage.heightAnchor.constraint(equalTo: viewContainer.heightAnchor, constant: -100),
           
           scoreLabel.centerXAnchor.constraint(equalTo: viewContainer.centerXAnchor),
           scoreLabel.topAnchor.constraint(equalTo: resultImage.bottomAnchor),
           scoreLabel.widthAnchor.constraint(equalTo: viewContainer.widthAnchor),
           scoreLabel.heightAnchor.constraint(equalToConstant: 50.0),
           
           shareButton.leftAnchor.constraint(equalTo: resultImage.rightAnchor, constant: buttonSpacer),
           shareButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
           shareButton.widthAnchor.constraint(equalToConstant: buttonWidth),
           shareButton.heightAnchor.constraint(equalToConstant: buttonHeight),
           
           newGameButton.rightAnchor.constraint(equalTo: resultImage.leftAnchor, constant: -buttonSpacer),
           newGameButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
           newGameButton.widthAnchor.constraint(equalToConstant: buttonWidth),
           newGameButton.heightAnchor.constraint(equalToConstant: buttonHeight),
        ])
        
        iPadPortraitConstraints.append(contentsOf: iPhonePortraitConstraints)
        
        iPadLandscapeConstraints.append(contentsOf: iPhoneLandscapeConstraints)
    }
    
    func updateConstraints() {
        NSLayoutConstraint.activate(sharedConstraints)
        
        switch UIDevice.current.userInterfaceIdiom {
        
        case .phone:
            //  iPhone Landscape
            if UIScreen.main.bounds.height < UIScreen.main.bounds.width {
                print("iPhone Landscape")
                NSLayoutConstraint.deactivate(iPhonePortraitConstraints)
                NSLayoutConstraint.deactivate(iPadLandscapeConstraints)
                NSLayoutConstraint.deactivate(iPadPortraitConstraints)
                NSLayoutConstraint.activate(iPhoneLandscapeConstraints)
            } else {
                print("iPhone Portrait")
                NSLayoutConstraint.deactivate(iPhoneLandscapeConstraints)
                NSLayoutConstraint.deactivate(iPadPortraitConstraints)
                NSLayoutConstraint.deactivate(iPadLandscapeConstraints)
                NSLayoutConstraint.activate(iPhonePortraitConstraints)
            }
       
        case .pad:
            //  iPad Landscape
            if UIScreen.main.bounds.height < UIScreen.main.bounds.width {
                print("iPad Landscape")
                NSLayoutConstraint.deactivate(iPhonePortraitConstraints)
                NSLayoutConstraint.deactivate(iPhoneLandscapeConstraints)
                NSLayoutConstraint.deactivate(iPadPortraitConstraints)
                NSLayoutConstraint.activate(iPadLandscapeConstraints)
            } else {
                print("iPad Portrait")
                //  iPad Portrait
                NSLayoutConstraint.deactivate(iPadLandscapeConstraints)
                NSLayoutConstraint.deactivate(iPhoneLandscapeConstraints)
                NSLayoutConstraint.deactivate(iPhonePortraitConstraints)
                NSLayoutConstraint.activate(iPadPortraitConstraints)
            }
        default:
            break
        }
    }
    
    func setupUI() {
        view.addSubview(viewContainer)
        viewContainer.addSubview(shareButton)
        viewContainer.addSubview(newGameButton)
        viewContainer.addSubview(scoreLabel)
        viewContainer.addSubview(gratzLabel)
        viewContainer.addSubview(resultImage)
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateConstraints()
    }
    
    func configure() {
        setupUI()
        setupConstraints()
        updateConstraints()
        self.blurView.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        
        if let image = Tile.croppedImage {
            resultImage.image = image
        }
        
        if let backgroundImage = Tile.originalImage {
            backgroundView.image = backgroundImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    

    @objc func displaySharingOptions() {
        let message = score
        let image = Tile.croppedImage!
        let items = [image as Any, message as Any]
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func unwindToStart() {
        performSegue(withIdentifier: "unwindToStart", sender: self)
    }
    
}
