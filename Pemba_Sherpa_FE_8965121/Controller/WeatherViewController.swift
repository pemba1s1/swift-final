//
//  Weather.swift
//  Pemba_Sherpa_FE_8965121
//
//  Created by user237120 on 4/5/24.
//

import UIKit
import Foundation
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate {

    struct WeatherData: Codable {
        let coord: Coord
        let weather: [WeatherInfo]
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

    // MARK: - WeatherInfo
    struct WeatherInfo: Codable {
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
    var textAddress : String?
    
    @IBOutlet weak var city: UILabel!
    
    @IBOutlet weak var weatherDesc: UILabel!
    
    @IBOutlet weak var temp: UILabel!
    
    @IBOutlet weak var humidity: UILabel!
    
    @IBOutlet weak var windSpeed: UILabel!
    
    @IBOutlet weak var weatherIcon: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        // Do any additional setup after loading the view.
    }
    
    //Function to get city name from latitude and longitude
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
    
    //Function to convert address string to coordinate
    func convertAddress() {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(textAddress!) {
            (placemarks, error) in
            guard let placemarks = placemarks,
                  let location = placemarks.first?.location
            else {
                print("No locatin")
                return
            }
            print(location)
            self.fetchWeather(coordinate: location.coordinate)
                  
        }
    }
    
    //Fetch weather based on coordinate
    func fetchWeather(coordinate: CLLocationCoordinate2D) {
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
                        let temp = String(readableData.main.temp)
                        let humidity = String(readableData.main.humidity)
                        let windSpeedKmh = String(format: "%.2f", readableData.wind.speed * 3.6)

                        //Save the first news to history
                        self.getCityNameFrom(latitude: coordinate.latitude, longitude: coordinate.longitude) { cityName in
                            
                            guard let cityName = cityName else {
                                return
                            }
                            let newHistory = SearchHistory(context: self.content)
                            do {
                                newHistory.type = "Weather"
                                newHistory.source = "Weather"
                                newHistory.city = cityName
                                newHistory.dateTime = Date(timeIntervalSince1970: Double(readableData.dt))
                                newHistory.temprature = temp
                                newHistory.humidity = humidity
                                newHistory.wind = "\(windSpeedKmh) Km/h"

                                try self.content.save()
                            } catch {
                                print("error could save")
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.city.text = String(readableData.name)
                            self.weatherDesc.text = String(readableData.weather[0].description).uppercased()
                            let imageIcon = String(readableData.weather[0].icon)
                            self.temp.text = "\(temp)\u{00B0}C"
                            self.humidity.text = "Humidity: \(humidity)%"
                            self.windSpeed.text = "Wind: \(windSpeedKmh) Km/h"
                            
                            self.fetchIcon(imageIcon: imageIcon, urlSession: urlSession)
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
    
    //Function to fetch current weather icon
    func fetchIcon (imageIcon: String, urlSession: URLSession) {
        let imageUrlString = "https://openweathermap.org/img/wn/\(imageIcon)@4x.png"
        let url = URL(string: imageUrlString)
        
        if let url = url {
            let dataTask = urlSession.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    if let iconImage = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.weatherIcon.image = iconImage
                        }
                    } else {
                        print("Invalid icon image data")
                    }
                }
            }
            dataTask.resume()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        fetchWeather(coordinate: location.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location request failed with error: \(error.localizedDescription)")
        
    }
    
    //Function to get address using alert
    @IBAction func getAddress(_ sender: Any) {
        let alert = UIAlertController(title: "Enter Placename", message: "",preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Location"
        }
        let addAction = UIAlertAction(title: "Get", style: .default, handler: {
            _ in
            if let textField = alert.textFields?.first {
                if let text = textField.text {
                    if text.isEmpty {
                        return
                    }
                    self.textAddress = text
                    self.convertAddress()
                }
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}
