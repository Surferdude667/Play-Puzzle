//
//  ViewController.swift
//  Gridly
//
//  Created by Bjørn Lau Jørgensen on 09/12/2019.
//  Copyright © 2019 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit

class GameController: UIViewController, UIGestureRecognizerDelegate {
    
    let preGameControlsView = UIView()
    let maskOverlayView = UIView()
    let gameControlsView = UIView()
    var contentImageOffset = CGPoint()
    var squarePath = UIBezierPath()
    let gridLayer = CALayer()
    var moveCount = 0
    
    @IBOutlet weak var contentImage: UIImageView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet var puzzleDestinations: [UIImageView]!
    @IBOutlet var puzzleTiles: [UIImageView]!
    @IBOutlet var puzzleStacks: [UIImageView]!
    
    @IBOutlet weak var labelMoveCount: UILabel!
    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet weak var buttonStartGame: UIButton!
    @IBOutlet weak var buttonNewGame: UIButton!
    @IBOutlet weak var buttonPreview: UIButton!
    @IBOutlet weak var buttonExit: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func configure() {
        if let gameImage = Tile.originalImage {
            contentImage.image = gameImage
        }
        
        blurView.effect = nil
        Tile.shared.removeAll()
        configureTapGestures()
        addGameControls()
        gameControlsView.isHidden = true
        buttonNewGame.imageView?.contentMode = .scaleAspectFit
        buttonPreview.imageView?.contentMode = .scaleAspectFit
        
        for element in puzzleStacks {
            element.alpha = 0.0
        }
    }
    
    override func viewDidLayoutSubviews() {
        drawMask()
        drawGrid()
        updateViewPositions()
    }
    
    
    func drawMask() {
        maskOverlayView.frame = view.frame
        maskOverlayView.backgroundColor =  UIColor.black.withAlphaComponent(0.6)
        
        self.view.insertSubview(maskOverlayView, at: 1)
        
        var squareSize = CGFloat()
        let maskLayer = CALayer()
        let squareLayer = CAShapeLayer()
        
        //  Check device and orintation to adjust mask size
        //  All other UI elements adjusts itself based on maske size
        if UIDevice.current.userInterfaceIdiom == .phone {
            if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
                squareSize = maskOverlayView.bounds.width - 50.0
            } else {
                squareSize = maskOverlayView.bounds.height - 50.0
            }
            
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
                squareSize = maskOverlayView.bounds.width - 200.0
            } else {
                squareSize = maskOverlayView.bounds.height - 250.0
            }
        }
        
        squareLayer.frame = CGRect(x: 0, y: 0, width: maskOverlayView.frame.size.width, height: maskOverlayView.frame.size.height)
        
        let overlay = UIBezierPath(rect: CGRect(x: 0, y: 0, width: maskOverlayView.frame.size.width, height: maskOverlayView.frame.size.height))
        
        squarePath = UIBezierPath(rect: CGRect(x: maskOverlayView.center.x - squareSize / 2, y: maskOverlayView.center.y - squareSize / 2, width: squareSize, height: squareSize))
        
        overlay.append(squarePath.reversing())
        squareLayer.path = overlay.cgPath
        maskLayer.addSublayer(squareLayer)
        
        maskOverlayView.layer.mask = maskLayer
    }
    
    func drawGrid() {
        var horizontalOffset: CGFloat = 0.0
        var verticalOffset: CGFloat = 0.0
        let offsetCalculation: CGFloat = squarePath.bounds.width / 4
        gridLayer.sublayers?.removeAll()
        
        for _ in 0..<5 {
            let x = CGPoint(x: squarePath.bounds.origin.x, y: squarePath.bounds.origin.y + horizontalOffset)
            let y = CGPoint(x: squarePath.bounds.origin.x + squarePath.bounds.width, y: squarePath.bounds.origin.y + horizontalOffset)
            drawLine(fromPoint: x, toPoint: y)
            horizontalOffset = horizontalOffset + offsetCalculation
        }
        
        for _ in 0..<5 {
            let x = CGPoint(x: squarePath.bounds.origin.x + verticalOffset, y: squarePath.bounds.origin.y)
            let y = CGPoint(x: squarePath.bounds.origin.x + verticalOffset, y: squarePath.bounds.origin.y + squarePath.bounds.width)
            drawLine(fromPoint: x, toPoint: y)
            verticalOffset = verticalOffset + offsetCalculation
        }
    }
    
    func drawLine(fromPoint start: CGPoint, toPoint end:CGPoint) {
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: start)
        linePath.addLine(to: end)
        line.path = linePath.cgPath
        line.strokeColor = UIColor.white.cgColor
        line.lineWidth = 1
        line.lineJoin = CAShapeLayerLineJoin.round
        
        gridLayer.addSublayer(line)
        self.view.layer.addSublayer(gridLayer)
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer || otherGestureRecognizer is UITapGestureRecognizer || gestureRecognizer is UIPanGestureRecognizer || otherGestureRecognizer is UIPanGestureRecognizer {
            return false
        }
        return true
    }
    
    
    func createPuzzle() {
        labelInfo.text = "Loading puzzle 🚀"
        labelInfo.textColor = UIColor.yellow
        buttonStartGame.alpha = 0.2
        buttonStartGame.isUserInteractionEnabled = false
        
        //  TODO: This should use a completion handler instead...
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.renderPuzzleImage()
            self.renderPuzzleTiles()
            self.addTilesToViews()
            GameHelper.fitViews(views: self.puzzleTiles, startPosition: CGPoint(x: self.squarePath.bounds.origin.x, y: self.squarePath.bounds.origin.y), offset: self.squarePath.bounds.width / 4)
            self.animateTilesToStack()
        }
    }
    
    
    @objc func moveImage(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: contentImage.superview)
        
        //  Saves the position of the background image before pan.
        if sender.state == .began {
            contentImageOffset = contentImage.frame.origin
        }
        
        let position = CGPoint(x: translation.x + contentImageOffset.x - contentImage.frame.origin.x, y: translation.y + contentImageOffset.y - contentImage.frame.origin.y)
        
        contentImage.transform = contentImage.transform.translatedBy(x: position.x, y: position.y)
    }
    
    @objc func rotateImage(_ sender: UIRotationGestureRecognizer) {
        contentImage.transform = contentImage.transform.rotated(by: sender.rotation)
        sender.rotation = 0
    }
    
    @objc func scaleImage(_ sender: UIPinchGestureRecognizer) {
        contentImage.transform = contentImage.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
    }
    
    
    func configureTapGestures() {
        //  MARK: Pan Gesture
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveImage(_:)))
        preGameControlsView.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
        
        // MARK: Rotation Gesture
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateImage(_:)))
        preGameControlsView.addGestureRecognizer(rotationGestureRecognizer)
        rotationGestureRecognizer.delegate = self
        
        //  MARK: Pinch Gesture
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(scaleImage(_:)))
        preGameControlsView.addGestureRecognizer(pinchGestureRecognizer)
        pinchGestureRecognizer.delegate = self
    }
    
    
    func addGameControls() {
        //  Add Pre Game Controls to view hierarchy
        preGameControlsView.frame = view.frame
        view.insertSubview(preGameControlsView, at: 2)
        preGameControlsView.addSubview(buttonStartGame)
        preGameControlsView.addSubview(labelInfo)
        preGameControlsView.addSubview(buttonExit)
        
        //  Add Game Controls to view hierarchy
        gameControlsView.frame = view.frame
        view.insertSubview(gameControlsView, at: 3)
        gameControlsView.addSubview(buttonNewGame)
        gameControlsView.addSubview(labelMoveCount)
        gameControlsView.addSubview(buttonPreview)
    }
    
    
    func renderPuzzleImage() {
        let renderer = UIGraphicsImageRenderer(bounds: squarePath.bounds)
        let image = renderer.image { (context) in
            gridLayer.isHidden = true
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        Tile.croppedImage = image
        gridLayer.isHidden = false
    }
    
    
    func renderPuzzleTiles() {
        var tileId = 0
        var yOffset: CGFloat = 0.0
        var xOffset: CGFloat = 0.0
        let offsetCalculation = squarePath.bounds.width / 4
        
        for _ in 0..<4 {
            for _ in 0..<4 {
                print("Rendering tile: \(tileId)")
                let tileSize = CGRect(x: squarePath.bounds.origin.x + xOffset, y: squarePath.bounds.origin.y + yOffset, width: squarePath.bounds.width / 4, height: squarePath.bounds.height / 4)
                let tileRendere = UIGraphicsImageRenderer(bounds: tileSize)
                
                let tile = tileRendere.image { (contex) in
                    view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
                }
                
                Tile.shared.append(Tile(id: tileId, tileImage: tile, correctlyPlaced: false, puzzlePosition: nil, oldTag: nil))
                xOffset += offsetCalculation
                tileId += 1
            }
            xOffset = 0.0
            yOffset += offsetCalculation
        }
        print("DONE!")
    }
    
    
    func animateToGame() {
        UIView.animate(withDuration: 1.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: [], animations: {
            self.maskOverlayView.alpha = 0.0
            self.gridLayer.opacity = 0.0
            self.preGameControlsView.alpha = 0.0
            
            for element in self.puzzleStacks {
                element.alpha = 0.5
            }
            
        }) { (success) in
            UIView.animate(withDuration: 1.0) {
                self.blurView.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
                self.gridLayer.opacity = 0.5
                self.gridLayer.frame.origin = CGPoint(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y)
                self.maskOverlayView.isHidden = true
                self.preGameControlsView.isHidden = true
                self.gameControlsView.isHidden = false
                
                for element in self.puzzleDestinations {
                    element.backgroundColor = UIColor.black
                    element.alpha = 0.5
                }
                
                //  Add the tiles to the game controls view
                for elemets in self.puzzleTiles {
                    self.gameControlsView.addSubview(elemets)
                }
            }
        }
    }
    
    func addTilesToViews() {
        //  Assign tags to puzzleStacks
        for i in 0..<puzzleTiles.count {
            puzzleStacks[i].tag = i
        }
        
        puzzleStacks.shuffle()
        
        for i in 0..<puzzleTiles.count {
            puzzleTiles[i].image = Tile.shared[i].renderedTileImage
            puzzleTiles[i].tag = Tile.shared[i].id
            Tile.shared[i].stackPairID = puzzleStacks[i].tag
        }
    }
    
    
    func animateTilesToStack() {
        for i in 0..<puzzleTiles.count {
            UIView.animate(withDuration: 1.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2.0, options: [], animations: {
                self.puzzleTiles[i].bounds.size = self.puzzleStacks[i].bounds.size
                GameHelper.moveView(view: self.puzzleTiles[i], to: self.puzzleStacks[i].frame.origin)
            }) { (success) in
                self.updateViewPositions()
            }
        }
        animateToGame()
    }
    
    
    func validatePlacement(viewID: Int, positionID: Int?) {
        
        //  Checks if tiles is placed on top of another tile
        for position in Tile.shared {
            if positionID == position.puzzlePositionInGrid {
                Tile.shared[viewID].correctlyPlaced = false
                Tile.shared[viewID].puzzlePositionInGrid = nil
                
                if let originalPosition = Tile.shared[viewID].stackPairID {
                    puzzleTiles[viewID].bounds.size = puzzleStacks[0].bounds.size
                    GameHelper.moveView(view: puzzleTiles[viewID], to: puzzleStacks[originalPosition].frame.origin)
                    return
                }
            }
        }
        
        //  Tile placed correctley
        if viewID == positionID {
            GameHelper.moveView(view: puzzleTiles[viewID], to: puzzleDestinations[positionID!].frame.origin)
            Tile.shared[viewID].correctlyPlaced = true
            Tile.shared[viewID].puzzlePositionInGrid = positionID
            moveCount += 1
            labelMoveCount.text = "MOVES \(moveCount)"
        } else {
            //  Tile placed wrong
            if positionID != nil {
                Tile.shared[viewID].correctlyPlaced = false
                Tile.shared[viewID].puzzlePositionInGrid = positionID
                GameHelper.moveView(view: puzzleTiles[viewID], to: puzzleDestinations[positionID!].frame.origin)
                moveCount += 1
                labelMoveCount.text = "MOVES \(moveCount)"
            } else {
                //  Tile is not placed near any position
                Tile.shared[viewID].correctlyPlaced = false
                Tile.shared[viewID].puzzlePositionInGrid = nil
                
                if let originalPosition = Tile.shared[viewID].stackPairID {
                    puzzleTiles[viewID].bounds.size = puzzleStacks[0].bounds.size
                    GameHelper.moveView(view: puzzleTiles[viewID], to: puzzleStacks[originalPosition].frame.origin)
                }
            }
        }
        checkGameStatus()
    }
    
    
    
    func updateViewPositions() {
        //  Update destination positions.
        GameHelper.fitViews(views: puzzleDestinations, startPosition: CGPoint(x: squarePath.bounds.origin.x, y: squarePath.bounds.origin.y), offset: squarePath.bounds.width / 4)
        
        //  Update stack positions.
        //  Landscape
        if UIScreen.main.bounds.height < UIScreen.main.bounds.width {
            positionPuzzleStacks(rows: 8.0, startPosition: CGPoint(x: squarePath.bounds.origin.x + squarePath.bounds.width + 20, y: squarePath.bounds.origin.y))
            //  Portrait
        } else {
            positionPuzzleStacks(rows: 2.0, startPosition: CGPoint(x: squarePath.bounds.origin.x, y: squarePath.bounds.origin.y + squarePath.bounds.height + 20))
        }
        
        //  Update tiles positions.
        updateTilePositions()
        
        //  Update Game Controls and Pre-Game controls.
        gameControlsView.frame = view.frame
        preGameControlsView.frame = view.frame
        positionPreGameElements()
        positionGameElements()
    }
    
    func updateTilePositions() {
        for i in 0..<Tile.shared.count {
            if Tile.shared[i].puzzlePositionInGrid != nil {
                let ID = Tile.shared[i].puzzlePositionInGrid
                puzzleTiles[i].bounds.size = CGSize(width: squarePath.bounds.width / 4, height: squarePath.bounds.height / 4)
                GameHelper.moveView(view: puzzleTiles[i], to: puzzleDestinations[ID!].frame.origin)
            } else {
                puzzleTiles[i].bounds.size = puzzleStacks[i].bounds.size
                
                if let originalPosition = Tile.shared[i].stackPairID {
                    GameHelper.moveView(view: puzzleTiles[i], to: puzzleStacks![originalPosition].frame.origin)
                }
            }
        }
    }
    
    func positionPuzzleStacks(rows: CGFloat, startPosition: CGPoint) {
        let seats: CGFloat = CGFloat(Int(puzzleStacks.count))
        var spacing: CGFloat = 5.0
        let calculatedSpacing = (spacing * (seats / 2 - 1) / (seats / 2))
        var xOffset: CGFloat = 0.0
        var yOffset: CGFloat = 0.0
        
        let size = CGSize(width: squarePath.bounds.width / (seats / 2) - calculatedSpacing, height: squarePath.bounds.height / (seats / 2) - calculatedSpacing)
        
        var i = 0
        for _ in 0..<Int(CGFloat(rows)) {
            spacing = 0.0
            for _ in 0..<Int(CGFloat(seats / rows)) {
                puzzleStacks[i].bounds.size = size
                puzzleStacks[i].frame.origin = CGPoint(x: startPosition.x + xOffset + spacing, y: startPosition.y + yOffset)
                
                xOffset += puzzleStacks[i].bounds.width + spacing
                spacing = 5.0
                i += 1
            }
            xOffset = 0.0
            yOffset += puzzleStacks[0].bounds.height + spacing
        }
    }
    
    func positionPreGameElements() {
        if UIScreen.main.bounds.height < UIScreen.main.bounds.width {
            
            //  iPad Landscape
            if UIDevice.current.userInterfaceIdiom == .pad {
                labelInfo.frame.origin.x = view.bounds.origin.x + view.bounds.width / 2 - labelInfo.bounds.width / 2
                labelInfo.frame.origin.y = squarePath.bounds.origin.y - 50
                
                buttonStartGame.frame.origin.x = view.bounds.origin.x + view.bounds.width / 2 - buttonStartGame.bounds.width / 2
                buttonStartGame.frame.origin.y = squarePath.bounds.origin.y + squarePath.bounds.height + 30
            }
            
            //  iPhone Landscape
            if UIDevice.current.userInterfaceIdiom == .phone {
                labelInfo.frame.origin.x = squarePath.bounds.origin.x - labelInfo.bounds.width - 30
                labelInfo.frame.origin.y = squarePath.bounds.origin.y + squarePath.bounds.height / 2 + 10
                
                buttonStartGame.frame.origin.x = squarePath.bounds.origin.x + squarePath.bounds.width + 30
                buttonStartGame.frame.origin.y = squarePath.bounds.origin.y + squarePath.bounds.height / 2 - buttonStartGame.bounds.height / 2
            }
            
            //  iPhone and iPad Portrait
        } else if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
            labelInfo.frame.origin.x = view.bounds.origin.x + view.bounds.width / 2 - labelInfo.bounds.width / 2
            labelInfo.frame.origin.y = squarePath.bounds.origin.y - 50
            
            buttonStartGame.frame.origin.x = view.bounds.origin.x + view.bounds.width / 2 - buttonStartGame.bounds.width / 2
            buttonStartGame.frame.origin.y = squarePath.bounds.origin.y + squarePath.bounds.height + 30
        }
        
        buttonExit.frame.origin.x = labelInfo.frame.origin.x + labelInfo.bounds.width / 2 - buttonExit.bounds.width / 2
        buttonExit.frame.origin.y = labelInfo.frame.origin.y - 40
    }
    
    
    
    func positionGameElements() {
        
        //  Landscape
        if UIScreen.main.bounds.height < UIScreen.main.bounds.width {
            buttonNewGame.frame.origin.x = squarePath.bounds.origin.x - buttonNewGame.bounds.width - 20
            buttonNewGame.frame.origin.y = squarePath.bounds.origin.y + squarePath.bounds.height / 4
            
            labelMoveCount.frame.origin.x = squarePath.bounds.origin.x - 110
            labelMoveCount.frame.origin.y = squarePath.bounds.origin.y + squarePath.bounds.height / 2 - labelMoveCount.bounds.height / 2
            
            buttonPreview.frame.origin.x = squarePath.bounds.origin.x - buttonPreview.bounds.width - 20
            buttonPreview.frame.origin.y = squarePath.bounds.origin.y + squarePath.bounds.height / 4 * 3 - buttonPreview.bounds.height
            
            //  Portrait
        } else if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
            buttonNewGame.frame.origin.x = squarePath.bounds.origin.x
            buttonNewGame.frame.origin.y = squarePath.bounds.origin.y - 65
            
            labelMoveCount.frame.origin.x = squarePath.bounds.origin.x + squarePath.bounds.width / 2 - labelMoveCount.bounds.width / 2
            labelMoveCount.frame.origin.y = squarePath.bounds.origin.y - 65
            
            buttonPreview.frame.origin.x = squarePath.bounds.origin.x + squarePath.bounds.width - buttonPreview.bounds.width
            buttonPreview.frame.origin.y = squarePath.bounds.origin.y - 65
        }
    }
    
    
    func preview() {
        buttonPreview.alpha = 0.2
        buttonPreview.isUserInteractionEnabled = false
        for i in 0..<Tile.shared.count {
            
            //  Move pieces to correct place
            if Tile.shared[i].correctlyPlaced == false && Tile.shared[i].puzzlePositionInGrid != nil {
                GameHelper.moveView(view: puzzleTiles[i], to: puzzleDestinations[i].frame.origin)
            } else if Tile.shared[i].puzzlePositionInGrid == nil {
                puzzleTiles[i].bounds.size = puzzleDestinations[i].bounds.size
                GameHelper.moveView(view: puzzleTiles[i], to: puzzleDestinations[i].frame.origin)
            }
            
            //  Move pieces back after 2 sec
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.buttonPreview.alpha = 1.0
                self.buttonPreview.isUserInteractionEnabled = true
                
                if Tile.shared[i].correctlyPlaced == false && Tile.shared[i].puzzlePositionInGrid != nil {
                    GameHelper.moveView(view: self.puzzleTiles[i], to: self.puzzleDestinations[Tile.shared[i].puzzlePositionInGrid!].frame.origin)
                } else if Tile.shared[i].puzzlePositionInGrid == nil {
                    self.puzzleTiles[i].bounds.size = self.puzzleStacks[i].bounds.size
                    GameHelper.moveView(view: self.puzzleTiles[i], to: self.puzzleStacks[Tile.shared[i].stackPairID!].frame.origin)
                }
            }
        }
    }
    
    func animateResult() {
        UIView.animate(withDuration: 2.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: [], animations: {
            for element in Tile.shared {
                self.puzzleTiles[element.id].alpha = 0.5
                self.puzzleDestinations[element.id].backgroundColor = UIColor.green
            }
        }) { (success) in
            self.performSegue(withIdentifier: "resultSegue", sender: self)
        }
    }
    
    func checkGameStatus() {
        var correctAnswers = 0
        
        for element in Tile.shared {
            if element.correctlyPlaced {
                correctAnswers += 1
            }
        }
        
        if correctAnswers == Tile.shared.count {
            animateResult()
        }
    }
    
    //  TODO: Pass image with segue insted of Singlton approach.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ResultController {
            let vc = segue.destination as? ResultController
            vc?.score = "Score: \(moveCount)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    
    @IBAction func moveTileWithPan(_ recognizer: UIPanGestureRecognizer) {
        
        guard let recognizerView = recognizer.view else {
            return
        }
        
        let translation = recognizer.translation(in: view)
        recognizerView.center.x += translation.x
        recognizerView.center.y += translation.y
        recognizer.setTranslation(.zero, in: view)
        
        var positionID: Int?
        
        for position in puzzleDestinations {
            let tileDistance = GameHelper.calculateDistance(recognizerView.frame.origin, position.frame.origin)
            
            if 0...40 ~= tileDistance {
                position.backgroundColor = UIColor.white
                position.alpha = 0.8
                positionID = puzzleDestinations.firstIndex(of: position)
            } else {
                position.backgroundColor = UIColor.black
                position.alpha = 0.5
            }
        }
        
        switch recognizer.state {
        case .ended:
            validatePlacement(viewID: recognizerView.tag, positionID: positionID)
        case .began:
            gameControlsView.bringSubviewToFront(recognizerView)
            UIView.animate(withDuration: 0.3) {
                recognizerView.bounds.size = CGSize(width: self.squarePath.bounds.width / 4, height: self.squarePath.bounds.height / 4)
            }
        default:
            return
        }
    }
    
    @IBAction func buttonPreview(_ sender: Any) {
        preview()
        //self.performSegue(withIdentifier: "resultSegue", sender: self)
    }
    
    @IBAction func buttonNewGame(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonStartGame(_ sender: Any) {
        createPuzzle()
    }
    
    @IBAction func buttonExit(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
