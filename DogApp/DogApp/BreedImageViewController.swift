//
//  BreedImageViewController.swift
//  DogApp
//
//  Created by spark-03 on 2024/06/07.
//

import UIKit

class BreedImageViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var breed: String?
    var dogImages: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let width = (view.frame.size.width - 20) / 3
            layout.itemSize = CGSize(width: width, height: width)
            layout.minimumInteritemSpacing = 5
            layout.minimumLineSpacing = 5
        }
        
        if let breed = breed {
            fetchBreedImages(breed: breed)
        }
    }
    
    func fetchBreedImages(breed: String) {
        let urlString = "https://dog.ceo/api/breed/\(breed)/images"
        guard let url = URL(string: urlString) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let dogImageData = try decoder.decode(DogImage.self, from: data)
                self.dogImages = dogImageData.message
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } catch {
            }
        }
        task.resume()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,numberOfItemsInSection section: Int) -> Int {
        return dogImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        if let imageView = cell.contentView.viewWithTag(100) as? UIImageView {
            let imageUrl = URL(string: dogImages[indexPath.row])
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: imageUrl!) {
                    DispatchQueue.main.async {
                        imageView.image = UIImage(data: data)
                    }
                }
            }
        }
        
        return cell
    }
}

