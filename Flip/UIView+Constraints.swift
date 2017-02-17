//
//  UIView+Constraints.swift
//  Mystilo
//
//  Created by Jaime Aranaz on 25/05/16.
//  Copyright © 2016 Corpora360. All rights reserved.
//

import Foundation

extension UIView {
    
    func addConstraintWitdh(_ width: CGFloat) {
        
        addConstraintWitdh(width, constraintId: nil)
    }
    
    func addConstraintWitdh(_ width: CGFloat, constraintId: String?) {
        
        let widthConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.width,
            relatedBy: NSLayoutRelation.equal,
            toItem: nil,
            attribute: NSLayoutAttribute.notAnAttribute,
            multiplier: 1.0,
            constant: width)
        
        setConstraintIdentifier(constraintId, toConstraint: widthConstraint)
        
        addConstraint(widthConstraint)
    }
    
    func addConstraintHeight(_ height: CGFloat) {
        
        addConstraintHeight(height, constraintId: nil)
    }
    
    func addConstraintHeight(_ height: CGFloat, constraintId: String?) {
        
        let heightConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.height,
            relatedBy: NSLayoutRelation.equal,
            toItem: nil,
            attribute: NSLayoutAttribute.notAnAttribute,
            multiplier: 1.0,
            constant: height)
        
        setConstraintIdentifier(constraintId, toConstraint: heightConstraint)
        
        addConstraint(heightConstraint)
    }
    
    func addConstraintsAnchorToSuperview(top: Bool, trailing: Bool, bottom: Bool, leading: Bool) {
        
        addConstraintsAnchorToSuperview(top: top, trailing: trailing, bottom: bottom, leading: leading, constraintId: nil)
    }
    
    func addConstraintsAnchorToSuperview(top: Bool, trailing: Bool, bottom: Bool, leading: Bool, constraintId: String?) {
        
        guard let superview = superview else {
            NSLog("error adding constraint \(constraintId), there is no superview")
            return
        }
        
        if (top) {
            
            let topConstraint = NSLayoutConstraint(item: self,
                                                   attribute: .top,
                                                   relatedBy: .equal,
                                                   toItem: superview,
                                                   attribute: .top,
                                                   multiplier: 1,
                                                   constant: 0)
            
            setConstraintIdentifier(constraintId, toConstraint: topConstraint)
            superview.addConstraint(topConstraint)
        }
        
        if (trailing) {
            
            let trailingConstraint = NSLayoutConstraint(item: self,
                                                        attribute: .trailing,
                                                        relatedBy: .equal,
                                                        toItem: superview,
                                                        attribute: .trailing,
                                                        multiplier: 1,
                                                        constant: 0)
            setConstraintIdentifier(constraintId, toConstraint: trailingConstraint)
            superview.addConstraint(trailingConstraint)
        }
        
        if (bottom) {
            
            let bottomConstraint = NSLayoutConstraint(item: self,
                                                      attribute: .bottom,
                                                      relatedBy: .equal,
                                                      toItem: superview,
                                                      attribute: .bottom,
                                                      multiplier: 1,
                                                      constant: 0)
            setConstraintIdentifier(constraintId, toConstraint: bottomConstraint)
            superview.addConstraint(bottomConstraint)
        }
        
        if (leading) {
            
            let leadingConstraint = NSLayoutConstraint(item: self,
                                                       attribute: .leading,
                                                       relatedBy: .equal,
                                                       toItem: superview,
                                                       attribute: .leading,
                                                       multiplier: 1,
                                                       constant: 0)
            setConstraintIdentifier(constraintId, toConstraint: leadingConstraint)
            superview.addConstraint(leadingConstraint)
        }
    }
    
    func addConstraintsCenterInSuperview() {
        
        addConstraintCenterVerticallyInSuperview(nil)
        addConstraintCenterHorizontallyInSuperview(nil)
    }
    
    func addConstraintsCenterInSuperview(_ constraintId: String?) {
        
        addConstraintCenterVerticallyInSuperview(constraintId)
        addConstraintCenterHorizontallyInSuperview(constraintId)
    }
    
    func addConstraintCenterVerticallyInSuperview() {
        
        addConstraintCenterVerticallyInSuperview(nil)
    }
    
    func addConstraintCenterVerticallyInSuperview(_ constraintId: String?) {
        
        guard let superview = superview else {
            NSLog("error adding constraint \(constraintId), there is no superview")
            return
        }
        
        let verticalConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.centerY,
            relatedBy: NSLayoutRelation.equal,
            toItem: superview,
            attribute: NSLayoutAttribute.centerY,
            multiplier: 1,
            constant: 0)
        
        setConstraintIdentifier(constraintId, toConstraint: verticalConstraint)
        
        superview.addConstraint(verticalConstraint)
    }
    
    func addConstraintCenterHorizontallyInSuperview() {
        
        addConstraintCenterHorizontallyInSuperview(nil)
    }
    
    func addConstraintCenterHorizontallyInSuperview(_ constraintId: String?) {
        
        guard let superview = superview else {
            NSLog("error adding constraint \(constraintId), there is no superview")
            return
        }
        
        let horizontalConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.centerX,
            relatedBy: NSLayoutRelation.equal,
            toItem: superview,
            attribute: NSLayoutAttribute.centerX,
            multiplier: 1,
            constant: 0)
        
        setConstraintIdentifier(constraintId, toConstraint: horizontalConstraint)
        
        superview.addConstraint(horizontalConstraint)
    }
    
    // TODO: return constraint in all methods
    @discardableResult
    func addConstraintTopSpaceToSuperview(_ space: CGFloat) -> NSLayoutConstraint {
        
        return addConstraintTopSpaceToSuperview(space, constraintId: nil)
    }
    
    func addConstraintTopSpaceToSuperview(_ space: CGFloat, constraintId: String?)  -> NSLayoutConstraint {
        
        guard let superview = superview else {
            NSLog("error adding constraint \(constraintId), there is no superview")
            return NSLayoutConstraint()
        }
        
        let topSpaceConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.top,
            relatedBy: NSLayoutRelation.equal,
            toItem: superview,
            attribute: NSLayoutAttribute.top,
            multiplier: 1.0,
            constant: space)
        
        setConstraintIdentifier(constraintId, toConstraint: topSpaceConstraint)
        
        superview.addConstraint(topSpaceConstraint)
        
        return topSpaceConstraint
    }
    
    func addConstraintBottomSpaceToSuperview(_ space: CGFloat) {
        
        addConstraintBottomSpaceToSuperview(space, constraintId: nil)
    }
    
    func addConstraintBottomSpaceToSuperview(_ space: CGFloat, constraintId: String?) {
        
        guard let superview = superview else {
            NSLog("error adding constraint \(constraintId), there is no superview")
            return
        }
        
        let bottomSpaceConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.bottom,
            relatedBy: NSLayoutRelation.equal,
            toItem: superview,
            attribute: NSLayoutAttribute.bottom,
            multiplier: 1.0,
            constant: space)
        
        setConstraintIdentifier(constraintId, toConstraint: bottomSpaceConstraint)
        
        superview.addConstraint(bottomSpaceConstraint)
    }
    
    func addConstraintLeadingSpaceToSuperview(_ space: CGFloat) {
        
        addConstraintLeadingSpaceToSuperview(space, constraintId: nil)
    }
    
    func addConstraintLeadingSpaceToSuperview(_ space: CGFloat, constraintId: String?) {
        
        guard let superview = superview else {
            NSLog("error adding constraint \(constraintId), there is no superview")
            return
        }
        
        let leadingConstraint = NSLayoutConstraint(
            item: superview,
            attribute: NSLayoutAttribute.leading,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.leading,
            multiplier: 1,
            constant: space)
        
        setConstraintIdentifier(constraintId, toConstraint: leadingConstraint)
        
        superview.addConstraint(leadingConstraint)
    }
    
    func addConstraintTrailingSpaceToSuperview(_ space: CGFloat) {
        
        addConstraintTrailingSpaceToSuperview(space, constraintId: nil)
    }
    
    func addConstraintTrailingSpaceToSuperview(_ space: CGFloat, constraintId: String?) {
        
        guard let superview = superview else {
            NSLog("error adding constraint \(constraintId), there is no superview")
            return
        }
        
        let trailingConstraint = NSLayoutConstraint(
            item: superview,
            attribute: NSLayoutAttribute.trailing,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.trailing,
            multiplier: 1,
            constant: space)
        
        setConstraintIdentifier(constraintId, toConstraint: trailingConstraint)
        
        superview.addConstraint(trailingConstraint)
    }
    
    func addConstraintVerticalSpaceToBelowView(_ view: UIView, space: CGFloat) {
        
        addConstraintVerticalSpaceToBelowView(view, space: space, constraintId: nil)
    }
    
    func addConstraintVerticalSpaceToBelowView(_ view: UIView, space: CGFloat, constraintId: String?) {
        
        guard let superview = superview else {
            NSLog("error adding constraint \(constraintId), there is no superview")
            return
        }
        
        let verticalSpaceConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.bottom,
            relatedBy: NSLayoutRelation.equal,
            toItem: view,
            attribute: NSLayoutAttribute.top,
            multiplier: 1,
            constant: -space)
        
        setConstraintIdentifier(constraintId, toConstraint: verticalSpaceConstraint)
        superview.addConstraint(verticalSpaceConstraint)
    }
    
    func addConstraintHorizontalSpaceToLeftView(_ view: UIView, space: CGFloat) {
        
        addConstraintHorizontalSpaceToLeftView(view, space: space, constraintId: nil)
    }
    
    func addConstraintHorizontalSpaceToLeftView(_ view: UIView, space: CGFloat, constraintId: String?) {
        
        guard let superview = superview else {
            NSLog("error adding constraint \(constraintId), there is no superview")
            return
        }
        
        let horizontalSpaceConstraint = NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.left,
            relatedBy: NSLayoutRelation.equal,
            toItem: view,
            attribute: NSLayoutAttribute.right,
            multiplier: 1,
            constant: space)
        
        setConstraintIdentifier(constraintId, toConstraint: horizontalSpaceConstraint)
        superview.addConstraint(horizontalSpaceConstraint)
    }
    
    // MARK: Private methods
    
    func setConstraintIdentifier(_ identifier: String?, toConstraint constraint: NSLayoutConstraint) {
        
        if let identifier = identifier {
            constraint.identifier = identifier
        }
    }
}
