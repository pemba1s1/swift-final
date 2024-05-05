//
//  Map.swift
//  Pemba_Sherpa_FE_8965121
//
//  Created by user237120 on 4/5/24.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    let content = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let manager = CLLocationManager()
    var startLocation : CLLocationCoordinate2D?
    var startLocationString: String?
    var endLocationString: String?
    var endLocation : CLLocationCoordinate2D?
    var transportType : MKDirectionsTransportType = .automobile
    var mapOverlay : MKPolyline?
    var annotations : [MKAnnotation] = []
    @IBOutlet weak var mapSpan: UISlider!
    
    @IBOutlet weak var transportMode: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            render (location)
        }
    }
    
    //Render the map
    func render (_ location: CLLocation) {
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: Double(self.mapSpan.value), longitudeDelta: Double(self.mapSpan.value))
        let region = MKCoordinateRegion(center: coordinate, span: span)
        let pin = MKPointAnnotation()
        
        pin.coordinate = coordinate
        annotations.append(pin)
        mapView.addAnnotation(pin)
        mapView.setRegion(region, animated: true)
    }
    
    //convert string address to coordinate
    func convertAddress(startLoc: String, endLoc : String) {
        let geoCoder1 = CLGeocoder()
        let geoCoder2 = CLGeocoder()
        let group = DispatchGroup()
        group.enter()
        geoCoder1.geocodeAddressString(startLoc) {
            (placemarks, error) in
            defer {
                group.leave()
            }
            guard let placemarks = placemarks,
                  let location = placemarks.first?.location
            else {
                print("No location")
                return
            }
            self.startLocation = location.coordinate
        }
        group.enter()
        geoCoder2.geocodeAddressString(endLoc) {
            (placemarks, error) in
            defer {
                group.leave()
            }
            guard let placemarks = placemarks,
                  let location = placemarks.first?.location
            else {
                print("No location")
                return
            }
            self.endLocation = location.coordinate
        }
        
        group.notify(queue: .main) {
            self.mapThis()
            self.saveToHistory()
        }
    }
    
    //Save to database
    func saveToHistory() {
        let newHistory = SearchHistory(context: self.content)
        print("Saving")
        newHistory.type = "Map"
        newHistory.source = "Map"
        newHistory.startPoint = startLocationString
        newHistory.endPoint = endLocationString
        switch transportType {
        case .automobile:
            newHistory.methodOfTravel = "Car"
        case .walking:
            newHistory.methodOfTravel = "Walk"
        default:
            break
        }
        do {
            try self.content.save()
        } catch {
            print("error could save")
        }

    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let routeline = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        routeline.strokeColor = .green
        return routeline
    }
    
    //Map the polyline from start location to end location
    func mapThis() {
        guard startLocation != nil, endLocation != nil else {
            return
        }
        let startCor = self.startLocation!
        let destinationCor = self.endLocation!
        let sourcePlacemark = MKPlacemark(coordinate:  startCor)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCor)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destinationItem = MKMapItem(placemark: destinationPlacemark)
        
        let destinationRequest = MKDirections.Request()
        
        destinationRequest.source = sourceItem
        destinationRequest.destination = destinationItem
        
        destinationRequest.transportType = transportType
        destinationRequest.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: destinationRequest)
        directions.calculate {
            (response, error) in
            guard let response = response else {
                if let error = error {
                    print(error)
                }
                return
            }
            let route = response.routes[0]
            if let overlay = self.mapOverlay {
                self.mapView.removeOverlay(overlay)
            }
            self.mapOverlay = route.polyline
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                    
            self.mapView.removeAnnotations(self.annotations)
            let startPin = MKPointAnnotation()
            self.annotations.append(startPin)
            startPin.coordinate = startCor
            startPin.title = "Start Point"
            self.mapView.addAnnotation(startPin)
            let endPin = MKPointAnnotation()
            self.annotations.append(endPin)
            let coordinate = CLLocationCoordinate2D(latitude: destinationCor.latitude, longitude: destinationCor.longitude)
            endPin.coordinate = coordinate
            endPin.title = "End Point"
            self.mapView.addAnnotation(endPin)

        }
        
    }
    
    //Change transport type to car
    @IBAction func changeTransportTypeToAutomobile(_ sender: UIButton) {
        transportType = .automobile
        transportMode.text = "Car"
        mapThis()
        saveToHistory()
    }
    
    //Change transport type to walk
    @IBAction func changeTransportTypeToWalking(_ sender: UIButton) {
        transportType = .walking
        transportMode.text = "Walk"
        mapThis()
        saveToHistory()
    }
    
    //Change span to zoom in and out
    @IBAction func changeMapSpan(_ sender: UISlider) {
        let span = MKCoordinateSpan(latitudeDelta: Double(sender.value), longitudeDelta: Double(sender.value))
        let newRegion = MKCoordinateRegion(center: mapView.region.center, span: span)
        mapView.setRegion(newRegion, animated: true)
        
    }
    
    //Get the start and end location using alert
    @IBAction func getStartAndEndLocation(_ sender: Any) {
        let alert = UIAlertController(title: "Where Would You Like To Go", message: "Enter Your Destination",preferredStyle: .alert)
        alert.addTextField { (textField1) in
            textField1.placeholder = "Start Location"
        }
        alert.addTextField { (textField2) in
            textField2.placeholder = "End Location"
        }
        let addAction = UIAlertAction(title: "Direction", style: .default, handler: {
            (action) in
            var startLoc : String
            var endLoc : String
            
            if alert.textFields![0].text!.isEmpty {
                return
            }
            startLoc = alert.textFields![0].text!
            
            if alert.textFields![1].text!.isEmpty {
                return
            }
            endLoc = alert.textFields![1].text!
            self.startLocationString = startLoc
            self.endLocationString = endLoc
            self.convertAddress(startLoc: startLoc, endLoc: endLoc)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        mapView.delegate = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
