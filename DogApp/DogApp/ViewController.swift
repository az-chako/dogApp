//
//  ViewController.swift
//  DogApp
//
//  Created by spark-03 on 2024/06/07.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var dogBreeds: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BreedCell")
        
        fetchDogBreeds()
    }
    
    func fetchDogBreeds() {
        guard let url = URL(string: "https://dog.ceo/api/breeds/list/all") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {data, response, error in
            if error != nil {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let dogBreedData = try decoder.decode(DogBreed.self, from: data)
                self.dogBreeds = Array(dogBreedData.message.keys).sorted()
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
            }
        }
        
        task.resume()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dogBreeds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BreedCell", for: indexPath)
        cell.textLabel?.text = dogBreeds[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "BreedSegue", sender: dogBreeds[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BreedSegue" {
            if let destinationVC = segue.destination as? BreedImageViewController, let selectedBreed = sender as? String {
                destinationVC.breed = selectedBreed
            }
        }
    }
}

