//
//  PlaceDetailController.swift
//  Nearby
//
//  Created by Abhisek on 5/23/18.
//  Copyright © 2018 Abhisek. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Combine

class PlaceDetailController: UIViewController {
    private var subscriptions = Set<AnyCancellable>()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var openStatusLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    private var viewModel: PlaceDetailViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func prepareView(viewModel: PlaceDetailViewModel) {
        self.viewModel = viewModel
    }
    
    private func setUpUI() {
        let title = viewModel.title
        subscriptions = [
            viewModel.$title.assign(to: \.text!, on: titleLabel),
            viewModel.$openStatus.assign(to: \.text!, on: openStatusLabel),
            viewModel.$distance.assign(to: \.text!, on: distanceLabel)
        ]
        
        viewModel.location.compactMap { location -> (MKCoordinateRegion, MKPointAnnotation)? in
            guard let lat = location?.coordinate.latitude,
                let long = location?.coordinate.longitude else { return nil }
            let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            return (region, annotation)
        }.sink { [weak self] location in
            self?.mapView.setRegion(location.0, animated: true)
            self?.mapView.addAnnotation(location.1)
        }.store(in: &subscriptions)
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

}
