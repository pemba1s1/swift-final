//
//  History.swift
//  Pemba_Sherpa_FE_8965121
//
//  Created by user237120 on 4/5/24.
//

import UIKit
import Foundation

class HistoryTableViewController: UITableViewController {

    var historyData: [SearchHistory]?
    let content = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Function to preload history if empty
    func seedHistoryData() {
        let newHistory1 = SearchHistory(context: self.content)
        newHistory1.type = "Weather"
        newHistory1.source = "Home"
        newHistory1.city = "Waterloo"
        newHistory1.dateTime = Date()
        newHistory1.temprature = "20"
        newHistory1.humidity = "69"
        newHistory1.wind = "69 Km/h"
        
        let newHistory2 = SearchHistory(context: self.content)
        newHistory2.type = "Weather"
        newHistory2.source = "Weather"
        newHistory2.city = "Waterloo"
        newHistory2.dateTime = Date()
        newHistory2.temprature = "20"
        newHistory2.humidity = "69"
        newHistory2.wind = "69 Km/h"
        
        let newHistory3 = SearchHistory(context: self.content)
        newHistory3.type = "News"
        newHistory3.source = "News"
        newHistory3.city = "Waterloo"
        newHistory3.newsTitle = "News Title"
        newHistory3.newsAuthor = "Gaben"
        newHistory3.newsDescription = "Crownfall Patch Notes"
        newHistory3.newsSource = "Steam"
        
        let newHistory4 = SearchHistory(context: self.content)
        newHistory4.type = "Map"
        newHistory4.source = "Map"
        newHistory4.startPoint = "Waterloo"
        newHistory4.endPoint = "Cambridge"
        newHistory4.methodOfTravel = "Car"
        
        let newHistory5 = SearchHistory(context: self.content)
        newHistory5.type = "Map"
        newHistory5.source = "Map"
        newHistory5.startPoint = "Waterloo"
        newHistory5.endPoint = "Cambridge"
        newHistory5.methodOfTravel = "Walk"
        
        do{
            try self.content.save()
            print("Seeding History Data")
        } catch {
            print("Error while seeding")
        }
        fetchHistory()
    }
    
    //Function to fetch history from DB
    func fetchHistory() {
        do {
            self.historyData = try content.fetch(SearchHistory.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("no data")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchHistory()
        if (self.historyData?.count == 0) {
            seedHistoryData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return historyData?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryTableViewCell
        cell.type.setTitle(historyData?[indexPath.row].type, for: .normal)
        cell.source.text = "From: \((historyData?[indexPath.row].source)!)"
        if let city = historyData?[indexPath.row].city {
            cell.city.text = "City: \(city)"
        } else {
            cell.city.text = ""
        }
        
        //clear the subviews of stackview
        cell.contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        //Load the content based on type of the history{News, Weather, Map}
        switch historyData?[indexPath.row].type {
        case "Weather":
            //Navigate to WeatherView if Source is Weather
            if historyData?[indexPath.row].source == "Weather" {
                //Handler called when button is clicked
                cell.buttonTappedHandler = {
                    let weatherView = self.storyboard?.instantiateViewController(identifier: "WeatherViewController") as! WeatherViewController
                    self.navigationController?.pushViewController(weatherView, animated: true)
                }
            } else{
                cell.buttonTappedHandler = {
                    
                }
            }
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss"

            // Format the Date object into date and time strings
            let formattedDate = dateFormatter.string(from: (historyData?[indexPath.row].dateTime)!)
            let formattedTime = timeFormatter.string(from: (historyData?[indexPath.row].dateTime)!)
            let dateLabel = UILabel()
            dateLabel.text = "Date: \(formattedDate)"
            let timeLabel = UILabel()
            timeLabel.text = "Time: \(formattedTime)"
            stackView.addArrangedSubview(dateLabel)
            stackView.addArrangedSubview(timeLabel)

            let tempLabel = UILabel()
            tempLabel.text = "Temp: \((historyData?[indexPath.row].temprature)!)\u{00B0}C"

            let humidityLabel = UILabel()
            humidityLabel.text = "Humidity: \((historyData?[indexPath.row].humidity)!)%"

            let windSpeedLabel = UILabel()
            windSpeedLabel.text = "Wind: \((historyData?[indexPath.row].wind)!) Km/h"

            cell.contentStackView.addArrangedSubview(stackView)
            cell.contentStackView.addArrangedSubview(tempLabel)
            cell.contentStackView.addArrangedSubview(humidityLabel)
            cell.contentStackView.addArrangedSubview(windSpeedLabel)
        case "News":
            //Navigate to NewsView
            //Handler called when button clicked
            cell.buttonTappedHandler = {
                let newsView = self.storyboard?.instantiateViewController(identifier: "NewsTableViewController") as! NewsTableViewController
                self.navigationController?.pushViewController(newsView, animated: true)
            }
            let title = UILabel()
            title.text = "Title: \((historyData?[indexPath.row].newsTitle)!)"

            let contentDescription = UILabel()
            contentDescription.numberOfLines = 0
            contentDescription.text = "Description: \((historyData?[indexPath.row].newsDescription)!)"

            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            let author = UILabel()
            author.text = "Author: \((historyData?[indexPath.row].newsAuthor)!)"
            let source = UILabel()
            source.text = "Source: \((historyData?[indexPath.row].source)!)"
            stackView.addArrangedSubview(author)
            stackView.addArrangedSubview(source)

            cell.contentStackView.addArrangedSubview(title)
            cell.contentStackView.addArrangedSubview(contentDescription)
            cell.contentStackView.addArrangedSubview(stackView)
            break
        case "Map":
            //Navigate to MapView
            //Handler called when button clicked
            cell.buttonTappedHandler = {
                let mapView = self.storyboard?.instantiateViewController(identifier: "MapViewController") as! MapViewController
                self.navigationController?.pushViewController(mapView, animated: true)
            }
            let startPoint = UILabel()
            startPoint.text = "Start Point: \((historyData?[indexPath.row].startPoint)!)"
            let endPoint = UILabel()
            endPoint.text = "End Point: \((historyData?[indexPath.row].endPoint)!)"

            let modeOfTravel = UILabel()
            modeOfTravel.text = "Mode Of Travel: \((historyData?[indexPath.row].methodOfTravel)!)"
            cell.contentStackView.addArrangedSubview(startPoint)
            cell.contentStackView.addArrangedSubview(endPoint)
            cell.contentStackView.addArrangedSubview(modeOfTravel)
        default:
            break
        }
        return cell

    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let historyToRemove = self.historyData![indexPath.row]
            self.content.delete(historyToRemove)
            do {
                try self.content.save()
            }catch {
                print("err")
            }
            self.historyData?.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }

    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
