//
//  DetailViewControllerTableViewController.swift
//  CountryTrivia
//
//  Created by Cory Steers on 12/9/22.
//

import UIKit

class DetailViewController: UITableViewController {    
    var country: Country?
    var attributes = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let c = country else { fatalError("the country property was never populated") }
        
        attributes.append("Name:               \(c.name)")
        attributes.append("Capital:            \(c.capital)")
        attributes.append("Population:         \(c.population)")
        attributes.append("National Language:  \(c.nationalLanguage)")
        attributes.append("Currency:           \(c.currency)")
        attributes.append("Area (sq km):       \(c.areaInSqKm)")
        attributes.append("GDP:                \(c.gdp)")
        attributes.append("Timezone(s):        \(c.timezone)")
        attributes.append("Drive side of road: \(c.drivingSide)")
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attributes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Statistic", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = attributes[indexPath.row]
        
        return cell
    }
}
