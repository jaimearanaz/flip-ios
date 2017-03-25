//
//  UIView+Constraints.swift
//  BaseProject
//
//  Created by Jaime Aranaz on 13/03/2017.
//  Copyright © 2017 Jaime Aranaz. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    // MARK: Public methods
    
    @discardableResult
    func addWidthConstraint(_ width: CGFloat, withIdentifier identifier: String? = nil) -> NSLayoutConstraint {
        
        let widthConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.width,
            relatedBy: NSLayoutRelation.equal,
            toItem: nil,
            attribute: NSLayoutAttribute.notAnAttribute,
            multiplier: 1.0,
            constant: width)
        
        setIdentifier(identifier, toConstraint: widthConstraint)
        addConstraint(widthConstraint)
        
        return widthConstraint
    }
    
    @discardableResult
    func addHeightConstraint(_ height: CGFloat, withIdentifier identifier: String? = nil) -> NSLayoutConstraint {
        
        let heightConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.height,
            relatedBy: NSLayoutRelation.equal,
            toItem: nil,
            attribute: NSLayoutAttribute.notAnAttribute,
            multiplier: 1.0,
            constant: height)
        
        setIdentifier(identifier, toConstraint: heightConstraint)
        addConstraint(heightConstraint)
        
        return heightConstraint
    }
    
    @discardableResult
    func addAnchorToSuperviewConstraints(toTop: Bool,
                                         toTrailing: Bool,
                                         toBottom: Bool,
                                         toLeading: Bool,
                                         withIdentifier identifier: String? = nil) -> [NSLayoutConstraint] {
        
        var constraints = [NSLayoutConstraint]()
        
        guard let _ = superview else {
            NSLog("error adding constraint \(identifier), there is no superview")
            return constraints
        }
        
        if (toTop) {
           constraints.append(addAnchorConstraintToSuperview(withAttribute: .top, identifier: identifier))
        }
        
        if (toTrailing) {
            constraints.append(addAnchorConstraintToSuperview(withAttribute: .trailing, identifier: identifier))
        }
        
        if (toBottom) {
            constraints.append(addAnchorConstraintToSuperview(withAttribute: .bottom, identifier: identifier))
        }
        
        if (toLeading) {
            constraints.append(addAnchorConstraintToSuperview(withAttribute: .leading, identifier: identifier))
        }
        
        return constraints
    }
    
    @discardableResult
    func addCenterInSuperviewConstraints(withIdentifier identifier: String? = nil) -> [NSLayoutConstraint] {

        let verticalConstraint = addCenterVerticallyInSuperviewConstraint(withIdentifier: identifier)
        let horizontalConstraint = addCenterHorizontallyInSuperviewConstraint(withIdentifier: identifier)
        
        return [verticalConstraint, horizontalConstraint]
    }
    
    @discardableResult
    func addCenterVerticallyInSuperviewConstraint(withIdentifier identifier: String? = nil) -> NSLayoutConstraint {
        
        guard let superview = superview else {
            NSLog("error adding constraint \(identifier), there is no superview")
            return NSLayoutConstraint()
        }
        
        let verticalConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.centerY,
            relatedBy: NSLayoutRelation.equal,
            toItem: superview,
            attribute: NSLayoutAttribute.centerY,
            multiplier: 1,
            constant: 0)
        
        setIdentifier(identifier, toConstraint: verticalConstraint)
        superview.addConstraint(verticalConstraint)
        
        return verticalConstraint
    }
    
    @discardableResult
    func addCenterHorizontallyInSuperviewConstraint(withIdentifier identifier: String? = nil) -> NSLayoutConstraint {
        
        guard let superview = superview else {
            NSLog("error adding constraint \(identifier), there is no superview")
            return NSLayoutConstraint()
        }
        
        let horizontalConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.centerX,
            relatedBy: NSLayoutRelation.equal,
            toItem: superview,
            attribute: NSLayoutAttribute.centerX,
            multiplier: 1,
            constant: 0)
        
        setIdentifier(identifier, toConstraint: horizontalConstraint)
        superview.addConstraint(horizontalConstraint)
        
        return horizontalConstraint
    }
    
    @discardableResult
    func addTopSpaceToSuperviewConstraint(topSpace: CGFloat, withIdentifier identifier: String? = nil)  -> NSLayoutConstraint {
        
        guard let superview = superview else {
            NSLog("error adding constraint \(identifier), there is no superview")
            return NSLayoutConstraint()
        }
        
        let topSpaceConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.top,
            relatedBy: NSLayoutRelation.equal,
            toItem: superview,
            attribute: NSLayoutAttribute.top,
            multiplier: 1.0,
            constant: topSpace)
        
        setIdentifier(identifier, toConstraint: topSpaceConstraint)
        superview.addConstraint(topSpaceConstraint)
        
        return topSpaceConstraint
    }
    
    @discardableResult
    func addBottomSpaceToSuperviewConstraint(bottomSpace: CGFloat, withIdentifier identifier: String? = nil) -> NSLayoutConstraint {
        
        guard let superview = superview else {
            NSLog("error adding constraint \(identifier), there is no superview")
            return NSLayoutConstraint()
        }
        
        let bottomSpaceConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.bottom,
            relatedBy: NSLayoutRelation.equal,
            toItem: superview,
            attribute: NSLayoutAttribute.bottom,
            multiplier: 1.0,
            constant: bottomSpace)
        
        setIdentifier(identifier, toConstraint: bottomSpaceConstraint)
        superview.addConstraint(bottomSpaceConstraint)
        
        return bottomSpaceConstraint
    }
    
    @discardableResult
    func addLeadingSpaceToSuperviewConstraint(leadingSpace: CGFloat, withIdentifier identifier: String? = nil) -> NSLayoutConstraint {
        
        guard let superview = superview else {
            NSLog("error adding constraint \(identifier), there is no superview")
            return NSLayoutConstraint()
        }
        
        let leadingConstraint = NSLayoutConstraint(
            item: superview,
            attribute: NSLayoutAttribute.leading,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.leading,
            multiplier: 1,
            constant: leadingSpace)
        
        setIdentifier(identifier, toConstraint: leadingConstraint)
        superview.addConstraint(leadingConstraint)
        
        return leadingConstraint
    }
    
    @discardableResult
    func addTrailingSpaceToSuperviewConstraint(trailingSpace: CGFloat, withIdentifier identifier: String? = nil) -> NSLayoutConstraint {
        
        guard let superview = superview else {
            NSLog("error adding constraint \(identifier), there is no superview")
            return NSLayoutConstraint()
        }
        
        let trailingConstraint = NSLayoutConstraint(
            item: superview,
            attribute: NSLayoutAttribute.trailing,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.trailing,
            multiplier: 1,
            constant: trailingSpace)
        
        setIdentifier(identifier, toConstraint: trailingConstraint)
        superview.addConstraint(trailingConstraint)
        
        return trailingConstraint
    }
    
    @discardableResult
    func addVerticalSpaceConstraint(verticalSpace: CGFloat, toBelowView belowView: UIView, withIdentifier identifier: String? = nil) -> NSLayoutConstraint {
        
        guard let superview = superview else {
            NSLog("error adding constraint \(identifier), there is no superview")
            return NSLayoutConstraint()
        }
        
        let verticalSpaceConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.bottom,
            relatedBy: NSLayoutRelation.equal,
            toItem: belowView,
            attribute: NSLayoutAttribute.top,
            multiplier: 1,
            constant: -verticalSpace)
        
        setIdentifier(identifier, toConstraint: verticalSpaceConstraint)
        superview.addConstraint(verticalSpaceConstraint)
        
        return verticalSpaceConstraint
    }
    
    @discardableResult
    func addHotizontalSpaceConstraint(horizontalSpace: CGFloat, toLeftView leftView: UIView, withIdentifier identifier: String? = nil) -> NSLayoutConstraint {
        
        guard let superview = superview else {
            NSLog("error adding constraint \(identifier), there is no superview")
            return NSLayoutConstraint()
        }
        
        let horizontalSpaceConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.left,
            relatedBy: NSLayoutRelation.equal,
            toItem: leftView,
            attribute: NSLayoutAttribute.right,
            multiplier: 1,
            constant: horizontalSpace)
        
        setIdentifier(identifier, toConstraint: horizontalSpaceConstraint)
        superview.addConstraint(horizontalSpaceConstraint)
        
        return horizontalSpaceConstraint
    }
    
    // MARK: Private methods
    
    fileprivate func setIdentifier(_ identifier: String?, toConstraint constraint: NSLayoutConstraint) {
        
        if let identifier = identifier {
            constraint.identifier = identifier
        }
    }
    
    fileprivate func addAnchorConstraintToSuperview(withAttribute attribute: NSLayoutAttribute, identifier: String? = nil) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: attribute,
                                            relatedBy: .equal,
                                            toItem: superview,
                                            attribute: attribute,
                                            multiplier: 1,
                                            constant: 0)
        
        setIdentifier(identifier, toConstraint: constraint)
        superview?.addConstraint(constraint)
        
        return constraint
    }
}
