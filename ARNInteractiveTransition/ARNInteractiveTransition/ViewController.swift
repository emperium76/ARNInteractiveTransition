//
//  ViewController.swift
//  ARNInteractiveTransition
//
//  Created by xxxAIRINxxx on 2015/02/28.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit
import ARNTransitionAnimator

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    
    var animator : ARNTransitionAnimator!
    var modalVC : ModalViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 8.0
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        self.modalVC = storyboard.instantiateViewController(withIdentifier: "ModalViewController") as? ModalViewController
        self.modalVC.modalPresentationStyle = .custom
        self.modalVC.tapCloseButtonActionHandler = { [weak self] in
            self!.animator.interactiveType = .none
        }
        
        self.setupAnimator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ViewController viewWillAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("ViewController viewWillDisappear")
    }
    
    override var shouldAutomaticallyForwardAppearanceMethods : Bool {
        return false
    }
    
    @IBAction func tapMenuButton() {
        if self.presentedViewController == nil {
            self.animator.interactiveType = .none
            self.present(self.modalVC, animated: true, completion: nil)
        }
    }
    
    func setupAnimator() {
        self.animator = ARNTransitionAnimator(operationType: .present, fromVC: self, toVC: modalVC!)
        self.animator.gestureTargetView = self.view
        self.animator.interactiveType = .present
        self.animator.contentScrollView = self.tableView
        
        // Present
        
        self.animator.presentationBeforeHandler = { [weak self] (containerView: UIView, transitionContext:
            UIViewControllerContextTransitioning) in
            self!.beginAppearanceTransition(false, animated:true)
            self!.animator.direction = .bottom
            containerView.addSubview(self!.modalVC.view)
            containerView.addSubview(self!.view)
            
            self!.tableView.isUserInteractionEnabled = false
            self!.tableView.bounces = false
            self!.tableView.setContentOffset(self!.tableView.contentOffset, animated: false)
            
            self!.modalVC.view.layoutIfNeeded()
            
            let endOriginY = containerView.bounds.height - 50
            self!.modalVC.view.alpha = 0.0
            
            self!.animator.presentationCancelAnimationHandler = { (containerView: UIView) in
                self!.view.frame.origin.y = 0.0
                self!.modalVC.view.alpha = 0.0
                self!.tableView.isUserInteractionEnabled = true
                self!.tableView.bounces = true
                self!.endAppearanceTransition()
            }
            
            self!.animator.presentationAnimationHandler = { [weak self] (containerView: UIView, percentComplete: CGFloat) in
                self!.view.frame.origin.y = endOriginY * percentComplete
                if self!.view.frame.origin.y < 0.0 {
                    self!.view.frame.origin.y = 0.0
                }
                self!.modalVC.view.alpha = 1.0 * percentComplete
            }
            
            self!.animator.presentationCompletionHandler = {(containerView: UIView, completeTransition: Bool) in
                UIApplication.shared.keyWindow!.addSubview(self!.view)
                if completeTransition {
                    self!.animator.interactiveType = .dismiss
                    self!.tableView.panGestureRecognizer.state = .cancelled
                    self!.animator.contentScrollView = nil
                    
                    self!.tableView.bounces = true
                    self!.endAppearanceTransition()
                }
            }
        }
        
        // Dismiss
        
        self.animator.dismissalBeforeHandler = { [weak self] (containerView: UIView, transitionContext: UIViewControllerContextTransitioning) in
            self!.beginAppearanceTransition(true, animated:true)
            self!.animator.direction = .top
            let endOriginY = containerView.bounds.height - 50
            self!.modalVC.view.alpha = 1.0
            self!.tableView.isUserInteractionEnabled = true
            
            self!.animator.dismissalCancelAnimationHandler = { (containerView: UIView) in
                self!.view.frame.origin.y = endOriginY
                self!.modalVC.view.alpha = 1.0
                self!.tableView.isUserInteractionEnabled = false
                self!.endAppearanceTransition()
            }
            
            self!.animator.dismissalAnimationHandler = {(containerView: UIView, percentComplete: CGFloat) in
                self!.view.frame.origin.y = endOriginY - (endOriginY * percentComplete)
                if self!.view.frame.origin.y < 0.0 {
                    self!.view.frame.origin.y = 0.0
                }
                self!.modalVC.view.alpha = 1.0 - (1.0 * percentComplete)
            }
        }
        
        self.animator.dismissalCompletionHandler = { [weak self] (containerView: UIView, completeTransition: Bool) in
            UIApplication.shared.keyWindow!.addSubview(self!.view)
            if completeTransition {
                self!.animator.interactiveType = .present
                self!.animator.contentScrollView = self!.tableView
                self!.endAppearanceTransition()
            }
        }
        
        modalVC.transitioningDelegate = self.animator
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
        return cell
    }
}

