//
//  ViewController.swift
//  CountryTrivia
//
//  Created by Cory Steers on 12/9/22.
//

import UIKit

class ViewController: UITableViewController {
    var countries = [Country]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Countries"
        navigationController?.navigationBar.prefersLargeTitles = true

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let url = Bundle.main.url(forResource: "countries", withExtension: "json")  else { fatalError("Can't load countries file")}
        guard let data = try? Data(contentsOf: url) else { fatalError("Can't create data from the url") }
        guard let decodedCountries = try? decoder.decode([Country].self, from: data)  else { fatalError("Can't decode json from the data") }
        countries = decodedCountries
        countries.sort { (lhs: Country, rhs: Country) -> Bool in
            return lhs.name < rhs.name
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Country", for: indexPath)
        let country = countries[indexPath.row]
                cell.textLabel?.text = country.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.country = countries[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)            
        }
    }

}

