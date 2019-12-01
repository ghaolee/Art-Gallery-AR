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
    var counter = 0
    
    @IBOutlet weak var activityWheel: UIActivityIndicatorView!
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
        if (indexPath.row < posterImages.count) {
            cell.posterImageView.image = posterImages[indexPath.row]
        }
        cell.posterButton.tag = indexPath.row
        cell.posterButton.addTarget(self, action: #selector(saveImageAlert), for: .touchUpInside)
        
        let width = NSLayoutConstraint(item: cell, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
        cell.addConstraint(width)
        let height = NSLayoutConstraint(item: cell, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
        cell.addConstraint(height)
        return cell
    }
    
    @objc func saveImageAlert(sender: UIButton) {
        let index = sender.tag
        let alert = UIAlertController(title: title, message: "Select This Image?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: {(action) in
            self.saveImage(index: index)
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        let imageView = UIImageView(frame: CGRect(x: 25, y: 50, width: 220, height: 220))
        let height = NSLayoutConstraint(item: alert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 320)
        alert.view.addConstraint(height)
        if (sender.tag >= posterImages.count) {
            sender.tag -= 1
        }
        imageView.image = posterImages[index]
        alert.view.addSubview(imageView)
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveImage(index: Int) {
        let paths = URL(fileURLWithPath: NSHomeDirectory())
        let fileName = "/Documents/PosterImages/\(counter).png"
        let filePath = paths.appendingPathComponent(fileName)
        counter += 1
        UserDefaults.standard.set(counter, forKey: "imageNameCounter")
        do {
            try posterImages[index].pngData()?.write(to: filePath, options: .atomic)
            print("SUCCESS:", filePath)
        }
        catch let error{
            print(error)
        }
    }
    
    func createDir() {
        let filePath = NSHomeDirectory() + "/Documents/PosterImages"
        do {
            try FileManager.default.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print(error)
        }
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
                if (idx < posterSearchResults.count) {
                    posterSearchResults.remove(at: idx)
                }
            }
        }
        let vc = self
        DispatchQueue.main.async{
            vc.theCollectionView.reloadData()
            vc.stopActivityWheel()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchBarText = self.exploreSearchBar.text!
        if (searchBarText != "") {
            let vc = self
            DispatchQueue.main.async {
                vc.startActivityWheel()
                vc.fetchAPISearchQuery(query: searchBarText)
            }
        }
        self.exploreSearchBar.endEditing(true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDir()
        theCollectionView.dataSource = self
        exploreSearchBar.delegate = self
        counter = UserDefaults.standard.integer(forKey: "imageNameCounter")
        fetchAPIToken()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startActivityWheel() {
        activityWheel.startAnimating()
        theCollectionView.isHidden = true
    }
    
    func stopActivityWheel() {
        activityWheel.stopAnimating()
        theCollectionView.isHidden = false
    }
    
    
    
}

