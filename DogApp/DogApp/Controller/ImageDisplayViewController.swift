//
//  ImageDisplayViewController.swift
//  DogApp
//
//  Created by spark-03 on 2024/06/10.
//

import UIKit

class ImageDisplayViewController: UIViewController,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    var imageUrl: String?
    var imageUrls: [String] = []
    var currentIndex: Int = 0
    
    private var isZoomed = false
    private var originalCenter: CGPoint?
    private var originalTransform: CGAffineTransform?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let imageUrl = imageUrl {
            currentIndex = imageUrls.firstIndex(of: imageUrl) ?? 0
            displayImage(from: imageUrl)
        }
        
        // ダブルタップジェスチャーを追加
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGesture)
        imageView.isUserInteractionEnabled = true
        
        // ピンチジェスチャーを追加
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinchGesture.delegate = self
        imageView.addGestureRecognizer(pinchGesture)
        
        // スワイプジェスチャーを追加
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeftGesture.direction = .left
        imageView.addGestureRecognizer(swipeLeftGesture)
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRightGesture.direction = .right
        imageView.addGestureRecognizer(swipeRightGesture)
        
        // 初期位置を保存
        originalCenter = imageView.center
    }
    
    func displayImage(from url: String) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: URL(string: url)!) {
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data)
                }
            }
        }
    }
    
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        guard let originalCenter = originalCenter else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            if self.isZoomed {
                self.imageView.transform = .identity
                self.imageView.center = originalCenter
            } else {
                let scale: CGFloat = 2.0
                let newTransform = CGAffineTransform(scaleX: scale, y: scale)
                
                self.imageView.transform = newTransform
            }
        }, completion: { _ in
            self.isZoomed.toggle()
        })
    }
    
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        if gesture.state == .began {
            originalTransform = view.transform
            originalCenter = view.center
        }
        
        if let originalTransform = originalTransform {
            view.transform = originalTransform.scaledBy(x: gesture.scale, y: gesture.scale)
        }
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            currentIndex = (currentIndex + 1) % imageUrls.count
        case .right:
            currentIndex = (currentIndex - 1 + imageUrls.count) % imageUrls.count
        default:
            break
        }
        displayImage(from: imageUrls[currentIndex])
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
