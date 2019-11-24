//
//  ExploreViewController.swift
//  Final Project
//
//  Created by G Hao Lee on 11/19/19.
//  Copyright © 2019 ghao. All rights reserved.
//

import UIKit

class ExploreViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    var posterSearchResults = [String]()
    var posterImages = [UIImage]()
    let CLIENT_ID = "64b3343ce46780976509"
    let CLIENT_SECRET = "f761e01ac696a8522317e8c2aeacb319"
    var token = ""
    
    @IBOutlet weak var exploreSearchBar: UISearchBar!
    @IBOutlet weak var theCollectionView: UICollectionView!
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(20, posterSearchResults.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = theCollectionView.dequeueReusableCell(withReuseIdentifier: "posterCell", for: indexPath) as! posterCell
        cell.posterImageView.image = posterImages[indexPath.row]
        print(indexPath.row)
        return cell
    }
    
    func fetchAPIToken() {
        let tokenURL = "https://api.artsy.net/api/tokens/xapp_token?client_id=\(CLIENT_ID)&client_secret=\(CLIENT_SECRET)"
        if let resourceURL = URL(string: tokenURL) {
            var request = URLRequest(url: resourceURL)
            request.httpMethod = "POST"
            URLSession.shared.dataTask(with: request) { data, response, error in
                if (error != nil) {
                    print("ERROR: ", error!)
                }
                else {
                    do{
                        let res = try JSONDecoder().decode(Token.self, from: data!)
                        self.token = res.token
                        self.fetchAPISearchQuery(query: "Andy Warhol")
                    } catch let error {
                        print("Error", error)
                    }
                }
                }.resume()
        }
    }
    
    func fetchAPISearchQuery(query: String) {
        var searchURL = "https://api.artsy.net/api/search?q="
        let userSearch = query.replacingOccurrences(of: " ", with: "+")
        searchURL += userSearch
        if let resourceURL = URL(string: searchURL) {
            var request = URLRequest(url: resourceURL)
            request.addValue(self.token, forHTTPHeaderField: "X-Xapp-Token")
            URLSession.shared.dataTask(with: request) { data, response, error in
                if (error != nil) {
                    print("ERROR: ", error!)
                }
                else {
                    do {
                        let res = try JSONDecoder().decode(APISearchResult.self, from: data!)
                        self.posterSearchResults = []
                        for item in res._embedded.results {
                            self.posterSearchResults.append(item._links.thumbnail.href)
                        }
                        self.fetchSearchImages()
                    } catch let error {
                        print(error)
                    }
                }
            }.resume()
        }
    }
    
    func fetchSearchImages() {
        self.posterImages = []
        for (idx, item) in posterSearchResults.enumerated() {
            let url = URL(string: item)
            let data = try? Data(contentsOf: url!)
            if (data != nil) {
                let image = UIImage(data:data!)
                self.posterImages.append(image!)
            }
            else {
                posterSearchResults.remove(at: idx)
            }
        }
        print(posterImages)
        let vc = self
        DispatchQueue.main.async {
            vc.theCollectionView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchBarText = self.exploreSearchBar.text!
        let vc = self
        DispatchQueue.main.async {
            vc.fetchAPISearchQuery(query: searchBarText)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theCollectionView.dataSource = self
        exploreSearchBar.delegate = self
        fetchAPIToken()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

