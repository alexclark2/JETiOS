//
//  StartScreenViewController.swift
//  JETiOS
//
//  Created by MACBOOK on 6/22/19.
//  Copyright © 2019 Alexander. All rights reserved.
//

import UIKit
import SpriteKit


class StartScreenViewController: UIViewController {
    
    
    @IBOutlet var StartButton: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()
        showButtons()
    }
    @IBAction func startGame(_ sender: Any) {
        
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        hideButtons()
    }
    
    func showSocialNetworks(){
        
        let activityVC : UIViewController = StartScreenViewController()
        
        self.present(activityVC, animated: true, completion: nil)
    }
    

    
    func hideButtons(){
        StartButton.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func showButtons() {
        StartButton.isHidden  = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
}
