//
//  SecondViewController.swift
//  Final Project
//
//  Created by G Hao Lee on 11/19/19.
//  Copyright © 2019 ghao. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var savedPosters = [UIImage]()
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(20, savedPosters.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = theCollectionView.dequeueReusableCell(withReuseIdentifier:
            "savedPosterCell", for: indexPath) as! savedPosterCell
        cell.savedImageView.image = savedPosters[indexPath.row]
        print(indexPath.row)
        return cell
    }
    
    @IBOutlet weak var theCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theCollectionView.dataSource = self
        fetchSavedPosters()
    }
    
    func fetchSavedPosters() {
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath          = paths.first
        {
            let folderPath = dirPath + "/PosterImages"
            do {
                let items = try FileManager.default.contentsOfDirectory(atPath: folderPath)
                
                for item in items {
                    let imageURL = folderPath + "/" + item
                    if let saveImage = UIImage(contentsOfFile: imageURL) {
                        savedPosters.append(saveImage)
                    }
                }
                print(savedPosters)
                theCollectionView.reloadData()
            } catch {
                print(error)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

