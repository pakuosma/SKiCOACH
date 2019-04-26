//
//  ResultViewController.swift
//  SKiCOACH
//
//  Created by Elina Kuosmanen on 26/04/2019.
//  Copyright © 2019 Elina Kuosmanen. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func pushedDoneButton(_ sender: UIButton) {
        
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: {
            if let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController{
                tabBarController.selectedIndex = 1
            }
            
        })
    }
}
