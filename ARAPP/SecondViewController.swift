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
    var savedPosterPaths = [String]()
    var selectedPosterIndex = -1
    
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
        cell.selectImage.tag = indexPath.row;
        cell.selectImage.addTarget(self, action:#selector(selectImageAlert), for: .touchUpInside);
        cell.deleteButton.tag = indexPath.row;
        cell.deleteButton.addTarget(self, action:#selector(deleteSavedImage), for: .touchUpInside)
        if (selectedPosterIndex == indexPath.row) {
            cell.savedImageView.layer.borderWidth = 3
            cell.savedImageView.layer.borderColor = UIColor.yellow.cgColor
        }
        else {
            cell.savedImageView.layer.borderWidth = 0
        }
        let width = NSLayoutConstraint(item: cell, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
        cell.addConstraint(width)
        let height = NSLayoutConstraint(item: cell, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
        cell.addConstraint(height)
        return cell
    }
    
    @IBOutlet weak var theCollectionView: UICollectionView!
    
    
    @objc func selectImageAlert(sender: UIButton) {
        let alert = UIAlertController(title: title, message: "Selected Image:", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        let imageView = UIImageView(frame: CGRect(x: 25, y: 50, width: 220, height: 220))
        let height = NSLayoutConstraint(item: alert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 320)
        alert.view.addConstraint(height)
        imageView.image = savedPosters[sender.tag]
        alert.view.addSubview(imageView)
        selectedPosterIndex = sender.tag
        self.present(alert, animated: true, completion: nil)
        UserDefaults.standard.set(savedPosterPaths[sender.tag], forKey: "SelectedImage")
        theCollectionView.reloadData()
    }
    
    @objc func deleteSavedImage(sender: UIButton) {
        let index = sender.tag
        let alert = UIAlertController(title: title, message: "Delete This Image?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.default, handler: {(action) in
            self.deleteImage(index: index)
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        let imageView = UIImageView(frame: CGRect(x: 10, y: 50, width: 220, height: 220))
        let height = NSLayoutConstraint(item: alert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 320)
        alert.view.addConstraint(height)
        imageView.image = savedPosters[index]
        alert.view.addSubview(imageView)
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteImage(index: Int) {
        let filePath = savedPosterPaths[index]
        if FileManager.default.fileExists(atPath: filePath) {
            try! FileManager.default.removeItem(atPath: filePath)
        }
        print(filePath)
        fetchSavedPosters()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theCollectionView.dataSource = self
        fetchSavedPosters()
        NotificationCenter.default.addObserver(self, selector: #selector(fetchSavedPosters), name: .didReceiveData, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.fetchSavedPosters()
        }
    }
    
    @objc func fetchSavedPosters() {
        savedPosters = []
        savedPosterPaths = []
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
                        savedPosterPaths.append(folderPath + "/" + item)
                    }
                }
                self.theCollectionView.reloadData()
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

extension Notification.Name {
    static let didReceiveData = Notification.Name("didReceiveData")
}
