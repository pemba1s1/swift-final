//
//  News.swift
//  Pemba_Sherpa_FE_8965121
//
//  Created by user237120 on 4/5/24.
//

import UIKit
import Foundation

class NewsTableViewController: UITableViewController {
    
    // MARK: - WeatherData
    struct ArticleData: Codable {
        let status: String
        let totalResults: Int
        let articles: [Article]
    }

    // MARK: - Article
    struct Article: Codable {
        let source: Source
        let author: String?
        let title, description: String?
        let url: String?
        let urlToImage: String?
        let publishedAt: String?
        let content: String?
    }

    // MARK: - Source
    struct Source: Codable {
        let id: String?
        let name: String
    }

    let apiKey = "3851ef1d191245ddb0e53c0dfa9486e1"
    var news : [Article] = [];
    var placeName : String = "Waterloo"
    let content = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Function to get city name using alert
    @IBAction func getPlaceName(_ sender: Any) {
        let alert = UIAlertController(title: "Enter Placename", message: "",preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Location"
        }
        let addAction = UIAlertAction(title: "Add", style: .default, handler: {
            _ in
            if let textField = alert.textFields?.first {
                if let text = textField.text {
                    if text.isEmpty {
                        return
                    }
                    self.placeName = text
                    self.fetchNews()
                }
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //Function to activity to history
    func saveToHistory(firstNews: Article) {
        let newHistory = SearchHistory(context: self.content)
        print("Saving")
        newHistory.type = "News"
        newHistory.source = "News"
        newHistory.city = placeName
        newHistory.newsTitle = firstNews.title
        newHistory.newsAuthor = firstNews.author
        newHistory.newsDescription = firstNews.description
        newHistory.newsSource = firstNews.source.name
        do {
            try self.content.save()
        } catch {
            print("error could save")
        }
    }
    
    //Function to fetch news based on city name
    func fetchNews() {
        let baseUrl = "https://newsapi.org/v2/"
        
        let urlString = "\(baseUrl)everything?q=\(placeName)&from=2024-04-07&sortBy=popularity&apiKey=\(apiKey)"
        let urlSession = URLSession(configuration: .default)
        let url = URL(string: urlString)

        if let url = url {
            let dataTask = urlSession.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    let jsonDecode = JSONDecoder()
                    do {
                        let readableData = try jsonDecode.decode(ArticleData.self, from: data)
                        DispatchQueue.main.async {
                            self.news = readableData.articles
                            if(readableData.articles.count > 0) {
                                self.saveToHistory(firstNews: readableData.articles[ 0 ])
                            }                            
                            self.tableView.reloadData()
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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchNews()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return news.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! NewsTableViewCell
        cell.title.text = news[indexPath.row].title
        cell.desc.text = news[indexPath.row].description
        cell.source.text = news[indexPath.row].source.name
        cell.author.text = news[indexPath.row].author != nil ? news[indexPath.row].author : "Null"
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
