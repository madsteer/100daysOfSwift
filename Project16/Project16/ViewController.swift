//
//  ViewController.swift
//  Project16
//
//  Created by Cory Steers on 12/11/22.
//

import MapKit
import UIKit

class ViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics.", url: "https://en.wikipedia.org/wiki/London")
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.", url: "https://en.wikipedia.org/wiki/Oslo")
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the City of Light.", url: "https://en.wikipedia.org/wiki/Paris")
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.", url: "https://en.wikipedia.org/wiki/Rome")
        let washington = Capital(title: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself.", url: "https://en.wikipedia.org/wiki/Washington,_D.C.")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Change Map", style: .plain, target: self, action: #selector(selectDifferentMap))
//        mapView.addAnnotation(london)
//        mapView.addAnnotation(oslo)
//        mapView.addAnnotation(paris)
//        mapView.addAnnotation(rome)
//        mapView.addAnnotation(washington)
        mapView.addAnnotations([london, oslo, paris, rome, washington])
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Capital else { return nil }
        
        let identifier = "Capital"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
        } else {
            annotationView?.annotation = annotation
        }
        
        annotationView?.markerTintColor = .blue
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let capital = view.annotation as? Capital else { return }
        
//        let placeName = capital.title
//        let placeInfo = capital.info
//
//        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
//        ac.addAction(UIAlertAction(title: "OK", style: .default))
//        present(ac, animated: true)
        
        let vc = WebViewController()
        vc.urlString = capital.urlString
        navigationController?.pushViewController(vc, animated: true)
    }
        
    @objc func selectDifferentMap() {
        let ac = UIAlertController(title: "Map type", message: "change type of map shown", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Standard", style: .default, handler: changeMap))
        ac.addAction(UIAlertAction(title: "Satellite", style: .default, handler: changeMap))
        ac.addAction(UIAlertAction(title: "Hybrid", style: .default, handler: changeMap))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func changeMap(action: UIAlertAction) {
        var mapType: MKMapType
        
        guard let actionTitle = action.title else { return }
        
        switch actionTitle {
        case "Satellite":
            mapType = .satellite
        case "Hybrid":
            mapType = .hybrid
        default:
            mapType = .standard
        }
        
        mapView.mapType = mapType
    }

}

