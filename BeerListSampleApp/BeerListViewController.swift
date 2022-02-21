//
//  BeerListViewController.swift
//  BeerListSampleApp
//
//  Created by Mac on 2022/02/18.
//

import UIKit

class BeerListViewController: UITableViewController {
    var beerList: [BeerInfo] = []
    var dataTasks: [URLSessionTask] = []
    var currentPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "브루어리"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(BeerListCell.self, forCellReuseIdentifier: "BeerListCell")
        tableView.rowHeight = 150
        tableView.prefetchDataSource = self
        
        self.searchBeer(currentPage)
    }
}

extension BeerListViewController: UITableViewDataSourcePrefetching {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beerList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BeerListCell", for: indexPath) as? BeerListCell else { return UITableViewCell() }
        
        let beer = beerList[indexPath.row]
        cell.configure(with: beer)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectBeer = beerList[indexPath.row]
        let detailViewController = BeerDetailViewController()
        
        detailViewController.beer = selectBeer
        self.show(detailViewController, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard currentPage != 1 else { return }
        
        indexPaths.forEach {
            if ($0.row + 1) / 25 + 1 == currentPage {
                self.searchBeer(currentPage)
            }
        }
    }
}

extension BeerListViewController {
    func searchBeer(_ page: Int) {
        guard let url = URL(string: "https://api.punkapi.com/v2/beers?page=\(page)"),
              dataTasks.firstIndex(where: { task in
                  task.originalRequest?.url == url
              }) == nil
        else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard error == nil,
                  let data = data,
                  let self = self,
                  let response = response as? HTTPURLResponse,
                  let beers = try? JSONDecoder().decode([BeerInfo].self, from: data) else {
                      print("ERROR: URLSession dataTask \(error?.localizedDescription ?? "")")
                      return
                  }
            
            switch response.statusCode {
            case (200..<300):
                self.beerList += beers
                self.currentPage += 1
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case (400..<500):
                print("""
                    ERROR: Client ERROR \(response.statusCode)
                    Response: \(response)
                """)
            case (500..<600):
                print("""
                    ERROR: Server ERROR \(response.statusCode)
                    Response: \(response)
                """)
            default:
                print("""
                    ERROR: Client ERROR \(response.statusCode)
                    Response: \(response)
                """)
            }
        }
        dataTask.resume()
        dataTasks.append(dataTask)
    }
}
