//
//  MapVC.swift
//  GeoFence
//
//  Created by Chad on 10/27/17.
//  Copyright © 2017 LintLabs. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {
    let fenceArray: NSMutableArray = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "GeoFence"
        self.view.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        // Set up map
        let mapView = MKMapView()
        mapView.frame = self.view.bounds
        mapView.mapType = .satelliteFlyover
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isPitchEnabled = false
        self.view.addSubview(mapView)
        
        // Set up fence layer
        
        // set up tool bar
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addFenceBox(sender:)))
        self.setToolbarItems([addButton], animated: false)
        
        // other controls?
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func addFenceBox(sender: UIBarButtonItem) {
        //print("Add fence box")
        // animate addition from toolbar, place in center at default start size
        let newBox = FenceView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        newBox.center = self.view.center
        newBox.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        newBox.alpha = 0.5
        newBox.isMultipleTouchEnabled = true
        self.view.addSubview(newBox)
        fenceArray.add(newBox)
        
        
    }
    func deleteFenceBox() {
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
}
