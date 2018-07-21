//
//  CustomAnimationPresentor.swift
//  Memer
//
//  Created by Nuri Chun on 5/21/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import Foundation
import UIKit

class CustomAnimationPresentorLeft: NSObject, UIViewControllerAnimatedTransitioning 
{
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        let containerView = transitionContext.containerView
        
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        // adding the view
        containerView.addSubview(toView)
        
        let startingFrame = CGRect(x: -toView.frame.width, y: 0, width: toView.frame.width, height: toView.frame.height)
        
        toView.frame = startingFrame
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {

            // toView is moved into mainView
            toView.frame = CGRect(x: 0, y: 0, width: toView.frame.width, height: toView.frame.height)
            
            // fromView is moved out of the mainView
            fromView.frame = CGRect(x: fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
            
        }) { (_) in
            transitionContext.completeTransition(true)
        }
    }
}
