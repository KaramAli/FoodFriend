//
//  Extension.swift
//  FoodFriend
//
//  Created by Karam Ali.
//

import Foundation
import UIKit

extension UIView {
    public var right: CGFloat {
        return self.frame.size.width + self.frame.origin.x
    }
    public var left: CGFloat {
        return self.frame.origin.x
    }
    public var top: CGFloat {
        return self.frame.origin.y
    }
    public var height: CGFloat {
        return self.frame.size.height
    }
    public var bottom: CGFloat {
        return self.frame.size.height + self.frame.origin.y
    }
    public var width: CGFloat {
        return self.frame.size.width
    }
    
}
