//
//  ViewController.swift
//  SKiCOACH
//
//  Created by Elina Kuosmanen on 12/03/2019.
//  Copyright © 2019 Elina Kuosmanen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var skatingStyleImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func skatingStyleButtons(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            skatingStyleImage.image = UIImage.init(named: "select-classic")
            break
        case 1:
            skatingStyleImage.image = UIImage.init(named: "select-skate")
            break
        default:
            break
        }
    }
    
}

