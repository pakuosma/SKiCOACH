//
//  ViewController.swift
//  SKiCOACH
//
//  Created by Elina Kuosmanen on 12/03/2019.
//  Copyright © 2019 Elina Kuosmanen. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var skatingStyleImage: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var distance:Double = 0
    
    override func viewDidLoad() {

    }
    
    override func viewDidDisappear(_ animated: Bool) {

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    @IBAction func pushedSkatingStyleButtons(_ sender: UISegmentedControl) {
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

extension Date {
    func roundDate(calendar cal: Calendar) -> Date {
        let year  = cal.component(.year, from: self)
        let month = cal.component(.month, from: self)
        let day   = cal.component(.day, from: self)
        return cal.date(from: DateComponents(year: year, month: month, day: day))!
    }
}



