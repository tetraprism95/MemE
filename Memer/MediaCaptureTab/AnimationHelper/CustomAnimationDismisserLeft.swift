//
//  CustomAnimationDismissor.swift
//  Memer
//
//  Created by Nuri Chun on 5/21/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit

class CustomAnimationDismisserLeft: NSObject, UIViewControllerAnimatedTransitioning 
{
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    {
        return 0.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        let containerView = transitionContext.containerView
        
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        containerView.addSubview(fromView)
        
        UIView.animate(withDuration: 0, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            
            // Start bringing back the fromView into MainView
            fromView.frame = CGRect(x: -fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
            
            // Kick toView out of the mainView
            toView.frame = CGRect(x: -toView.frame.width, y: 0, width: toView.frame.width, height: toView.frame.width)
        }) { (_) in
            transitionContext.completeTransition(true)
        }
    }
}
