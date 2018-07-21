//
//  CustomAnimationDismisserRight.swift
//  Memer
//
//  Created by Nuri Chun on 6/4/18.
//  Copyright © 2018 tetra. All rights reserved.
//

import UIKit

class CustomAnimationDismisserRight: NSObject, UIViewControllerAnimatedTransitioning
{
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    {
        return 0
        
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        let containerView = transitionContext.containerView
        
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        containerView.addSubview(fromView)
        
        UIView.animate(withDuration: 0,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: .curveEaseIn,
                       animations: {
                        
                        // fromView now in containerView
                        fromView.frame = CGRect(x: fromView.frame.width, y: 0, width: fromView.frame.width, height: fromView.frame.height)
                        
                        // toView is being pushed out of the containerView
                        toView.frame = CGRect(x: toView.frame.width * 2, y: 0, width: toView.frame.width, height: toView.frame.height)
        }) { (_) in
            transitionContext.completeTransition(true)
        }
    }
}
