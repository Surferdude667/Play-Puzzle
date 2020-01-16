//
//  GameHelper.swift
//  Gridly
//
//  Created by Bjørn Lau Jørgensen on 03/01/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import Foundation
import UIKit

class GameHelper {
    static func calculateDistance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
    
    static func moveView(view: UIImageView, to newPostion: CGPoint) {
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            view.frame.origin = newPostion
        })
    }
    
    static func fitViews(views: [UIImageView], startPosition: CGPoint, offset: CGFloat) {
        var yOffset: CGFloat = 0.0
        var xOffset: CGFloat = 0.0
        var i = 0
        
        for _ in 0..<4 {
            for _ in 0..<4 {
                let position = CGRect(x: startPosition.x + xOffset, y: startPosition.y + yOffset, width: offset, height: offset)
                views[i].frame = position
                
                xOffset += offset
                i += 1
            }
            xOffset = 0.0
            yOffset += offset
        }
    }
}
