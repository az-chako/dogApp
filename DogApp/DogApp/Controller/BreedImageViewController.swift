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
            if error != nil {
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dogImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCellCollectionViewCell
        
        let imageUrl = URL(string: dogImages[indexPath.row])
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: imageUrl!) {
                DispatchQueue.main.async {
                    cell.imageView.image = UIImage(data: data)
                    // UIImageViewのcontentModeを設定
                    cell.imageView.contentMode = .scaleAspectFill
                    cell.imageView.clipsToBounds = true
                }
            }
        }
        
        return cell
    }
    
    // アイテムのサイズを設定するメソッド
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 10
        let collectionViewSize = collectionView.frame.size.width - padding
        
        let itemWidth = collectionViewSize / 2
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    // アイテム間のスペースを設定するメソッド
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImageDetail" {
            if let destinationVC = segue.destination as? ImageDisplayViewController, let indexPath = collectionView.indexPathsForSelectedItems?.first  {
                destinationVC.imageUrl = dogImages[indexPath.row]
                destinationVC.imageUrls = dogImages
            }
        }
    }
}
