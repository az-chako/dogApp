//
//  ImageDisplayViewController.swift
//  DogApp
//
//  Created by spark-03 on 2024/06/10.
//

import UIKit

class ImageDisplayViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var imageUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let imageUrl = imageUrl {
            displayImage(from: imageUrl)
        }
        
        
    }
    
    func displayImage(from url: String) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: URL(string: url)!) {
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data:  data)
                }
            }
        }
    }
}
