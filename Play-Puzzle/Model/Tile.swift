//
//  Tiles.swift
//  Gridly
//
//  Created by Bjørn Lau Jørgensen on 18/12/2019.
//  Copyright © 2019 Bjørn Lau Jørgensen. All rights reserved.
//

import Foundation
import UIKit

class Tile {
    let id: Int
    let renderedTileImage: UIImage
    var correctlyPlaced: Bool
    var puzzlePositionInGrid: Int?
    var stackPairID: Int?
    
    static var originalImage: UIImage?
    static var croppedImage: UIImage?
    static var shared = [Tile]()
    
    init(id: Int, tileImage: UIImage, correctlyPlaced: Bool, puzzlePosition: Int?, oldTag: Int?) {
        self.id = id
        self.renderedTileImage = tileImage
        self.correctlyPlaced = correctlyPlaced
        self.puzzlePositionInGrid = puzzlePosition
        self.stackPairID = oldTag
    }
}
