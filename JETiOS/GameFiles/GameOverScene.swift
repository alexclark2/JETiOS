//
//  GameOverScene.swift
//  JETiOS
//
//  Created by MACBOOK on 6/22/19.
//  Copyright © 2019 Alexander. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit



class GameOverScene: SKScene, ButtonDelegate {
    
    var StartScreenViewController: UIViewController?
    
    func buttonClicked(sender: Button) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Start")
        vc.view.frame = (self.view?.frame)!
        vc.view.layoutIfNeeded()
        
        UIView.transition(with: self.view!, duration: 0.3, options: .transitionFlipFromRight, animations:
            {
                self.view?.window?.rootViewController = vc
        }, completion: { completed in
            
        })
        
        print("you clicked the button named \(sender.name!)")
    }
    
    private var buttonOne = Button()
    private var buttonTwo = Button()
    

    override func didMove(to view: SKView) {
        
    
        if let buttonOne = self.childNode(withName: "NewGame") as? Button {
            self.buttonOne = buttonOne
            buttonOne.delegate = self
        }
        let buttonOne = Button(imageNamed: "NewGame")
        buttonOne.name = "NewGame"
        buttonOne.position = CGPoint(x: 200, y: 350)
        buttonOne.delegate = self
        addChild(buttonOne)
        
        if let buttonTwo = self.childNode(withName: "HomeButton") as? Button {
            self.buttonTwo = buttonTwo
            buttonTwo.delegate = self
        }
        
        let buttonTwo = Button(imageNamed: "HomeButton")
        buttonTwo.name = "HomeButton"
        buttonTwo.position = CGPoint(x: 200, y: 150)
        buttonTwo.delegate = self
        addChild(buttonTwo)
    }
}
