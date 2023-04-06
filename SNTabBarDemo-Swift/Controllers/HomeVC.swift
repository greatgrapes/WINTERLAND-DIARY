//
//  HomeVC.swift
//  winterland
//
//  Created by 박진성 on 2023/02/16.
//

import UIKit
import Lottie

class HomeVC: UIViewController {
    
    //MARK: - Properties
    private let animationView: LottieAnimationView = {
        let animationView: LottieAnimationView = .init(name: "snowball")
        
        return animationView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        }
    

    // MARK: - Helpers
    func makeUI() {
        animationView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(animationView)
        
        animationView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        
        animationView.heightAnchor.constraint(equalToConstant: 600).isActive = true
        animationView.widthAnchor.constraint(equalToConstant: 600).isActive = true
        
        animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        animationView.play()
        animationView.loopMode = .loop
    }
    
    
}
