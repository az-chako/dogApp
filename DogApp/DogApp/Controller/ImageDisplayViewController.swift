//
//  ImageDisplayViewController.swift
//  DogApp
//
//  Created by spark-03 on 2024/06/10.
//

import UIKit

class ImageDisplayViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    var imageUrls: [String] = []
    var currentIndex: Int = 0
    
    private var isZoomed = false
    private var originalCenter: CGPoint?
    private var originalTransform: CGAffineTransform?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        setupScrollView()
    }
    
    func setupScrollView() {
        for (index, url) in imageUrls.enumerated() {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.isUserInteractionEnabled = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            scrollView.addSubview(imageView)
            
            // Set Auto Layout constraints for imageView
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: self.view.frame.width * CGFloat(index)),
                imageView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
                imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
            ])
            
            loadImageAsync(url: url) { [weak self] image in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
            
            let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
            doubleTapGesture.numberOfTapsRequired = 2
            imageView.addGestureRecognizer(doubleTapGesture)
            
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
            imageView.addGestureRecognizer(pinchGesture)
        }
        
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(imageUrls.count), height: view.frame.height)
        scrollView.contentOffset = CGPoint(x: view.frame.width * CGFloat(currentIndex), y: 0)
    }
    
    func loadImageAsync(url: String, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            guard let url = URL(string: url), let data = try? Data(contentsOf: url) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        guard let imageView = gesture.view as? UIImageView else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            if self.isZoomed {
                imageView.transform = .identity
                self.scrollView.contentOffset = CGPoint(x: self.view.frame.width * CGFloat(self.currentIndex), y: 0)
            } else {
                let scale: CGFloat = 2.0
                let newTransform = CGAffineTransform(scaleX: scale, y: scale)
                imageView.transform = newTransform
            }
        }, completion: { _ in
            self.isZoomed.toggle()
        })
    }
    
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let imageView = gesture.view else { return }
        
        if gesture.state == .began {
            originalTransform = imageView.transform
            originalCenter = imageView.center
        }
        
        if let originalTransform = originalTransform {
            imageView.transform = originalTransform.scaledBy(x: gesture.scale, y: gesture.scale)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        loadVisibleImages()
    }
    
    func loadVisibleImages() {
        for subview in scrollView.subviews {
            guard let imageView = subview as? UIImageView else { continue }
            let visibleRect = CGRect(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y, width: scrollView.frame.width, height: scrollView.frame.height)
            if visibleRect.intersects(imageView.frame) {
                let index = Int(imageView.frame.origin.x / scrollView.frame.width)
                let url = imageUrls[index]
                loadImageAsync(url: url) { [weak self] image in
                    guard self != nil else { return }
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
            }
        }
    }
}
