//
//  Main.swift
//  Pemba_Sherpa_FE_8965121
//
//  Created by user237120 on 4/5/24.
//

import UIKit
import CoreLocation
import MapKit
import Foundation

class MainViewContorller: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    // MARK: - WeatherData
    struct WeatherData: Codable {
        let coord: Coord
        let weather: [Weather]
        let base: String
        let main: Main
        let visibility: Int
        let wind: Wind
        let clouds: Clouds
        let dt: Int
        let sys: Sys
        let timezone, id: Int
        let name: String
        let cod: Int
    }
    
    // MARK: - Clouds
    struct Clouds: Codable {
        let all: Int
    }
    
    // MARK: - Coord
    struct Coord: Codable {
        let lon, lat: Double
    }
    
    // MARK: - Main
    struct Main: Codable {
        let temp, feelsLike, tempMin, tempMax: Double
        let pressure, humidity: Int
        
        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case pressure, humidity
        }
    }
    
    // MARK: - Sys
    struct Sys: Codable {
        let type, id: Int
        let country: String
        let sunrise, sunset: Int
    }
    
    // MARK: - Weather
    struct Weather: Codable {
        let id: Int
        let main, description, icon: String
    }
    
    // MARK: - Wind
    struct Wind: Codable {
        let speed: Double
        let deg: Int
    }
    
    let content = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let locationManager = CLLocationManager()
    var weatherDataFetched = false
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var temperatureInCelsius: UILabel!
    
    @IBOutlet weak var humidity: UILabel!
    
    @IBOutlet weak var windSpeed: UILabel!
    
    //Function to get city name from coordinate
    func getCityNameFrom(latitude: Double, longitude: Double, completion: @escaping (String?) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Reverse geocoding failed with error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("No placemark found for the given coordinates")
                completion(nil)
                return
            }
            
            // Extract the city name
            if let city = placemark.locality {
                completion(city)
            } else {
                completion(nil)
            }
        }
    }
    
    //Function to fetch weather
    func fetchWeatherIfNeeded(coordinate: CLLocationCoordinate2D) {
        guard !weatherDataFetched else {
            return
        }
        let apiKey = "fe10f6850eabc73b38e1717b29ae943b"
        let baseUrl = "https://api.openweathermap.org/data/2.5/weather"
        
        let urlString = "\(baseUrl)?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(apiKey)&units=metric"
        let urlSession = URLSession(configuration: .default)
        let url = URL(string: urlString)

        if let url = url {
            let dataTask = urlSession.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    let jsonDecode = JSONDecoder()
                    do {
                        let readableData = try jsonDecode.decode(WeatherData.self, from: data)
                        
                        //Save activity to DB
                        self.getCityNameFrom(latitude: coordinate.latitude, longitude: coordinate.longitude) { cityName in
                            guard let cityName = cityName else {
                                return
                            }
                            let newHistory = SearchHistory(context: self.content)
                            let temp = String(readableData.main.temp)
                            let humidity = String(readableData.main.humidity)
                            let windSpeedKmh = String(format: "%.2f", readableData.wind.speed * 3.6)
                            do {
                                newHistory.type = "Weather"
                                newHistory.source = "Home"
                                newHistory.city = cityName
                                newHistory.dateTime = Date(timeIntervalSince1970: Double(readableData.dt))
                                newHistory.temprature = temp
                                newHistory.humidity = humidity
                                newHistory.wind = "\(windSpeedKmh) Km/h"

                                try self.content.save()
                                print("saving")
                            } catch {
                                print("error could save")
                            }
                        }
                        DispatchQueue.main.async {
                            self.temperatureInCelsius.text = "\(String(readableData.main.temp))\u{00B0}"
                            self.humidity.text = "\(String(readableData.main.humidity))%"
                            self.windSpeed.text = String(format: "%.2f Km/h", readableData.wind.speed * 3.6)
                        }
                    }
                    catch {
                        print("Cannot decode")
                    }
                }
                
            }
            dataTask.resume()
        }
     
    }
    
    //Render the map
    func render (_ location: CLLocation) {
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setCenter(coordinate, animated: true)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        render(location)
        fetchWeatherIfNeeded(coordinate: location.coordinate)
        weatherDataFetched = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.delegate = self
        mapView.showsUserLocation = true        // Do any additional setup after loading the view.
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
