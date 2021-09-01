//
//  AppsViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/23/21.
//

import Foundation
import UIKit

class AppsViewController: UIViewController {
    // MARK: Properties
    let detailViewSegue = "appDetailViewSegue"
    
    var connectedApps: [App] = [App(type: .instagram)]
    var availableApps: [App] {
        [
            App(type: .twitter),
            App(type: .youtube)
        ]
    }
    fileprivate let tableSectionTitles = ["Connected", "Available"]

    // MARK: Outlets
    @IBOutlet weak var appsTableView: UITableView!
    @IBOutlet weak var finishButton: UIButton!
    
    // MARK: View States
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        appsTableView.reloadData()
        
        finishButton.setTitleColor(.lightGray, for: .disabled)
        updateFinishButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == detailViewSegue {
            let appDetailViewController = segue.destination as! AppDetailViewController
            let app = sender as! App
            appDetailViewController.app = app
        }
    }
    
    // MARK: Actions
    
    // MARK: Functions
    func updateFinishButton() {
        let connectedApps = appsTableView.numberOfRows(inSection: 0)
        finishButton.isEnabled = (connectedApps > 0)
    }
}

extension AppsViewController: UITableViewDelegate, UITableViewDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appsTableView.delegate = self
        appsTableView.dataSource = self
    }
    
    // MARK: Table view delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableSectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableSectionTitles[section]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return connectedApps.count
        case 1:
            return [availableApps.count, 0].max()!
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let app = getApp(indexPath: indexPath)
        let cell = appsTableView.dequeueReusableCell(withIdentifier: "appCell")!
        
        cell.imageView?.image = app.image
        cell.textLabel?.text = app.name
        cell.detailTextLabel?.text = "\(connectedApps.count) connected users"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = getApp(indexPath: indexPath)
        
        self.performSegue(withIdentifier: detailViewSegue, sender: app)
        appsTableView.deselectRow(at: indexPath, animated: true)
    }

    func getApp(indexPath: IndexPath) -> App {
        let section = indexPath.section
        let app = section == 1 ? availableApps[indexPath.row] : connectedApps[indexPath.row]
        
        return app
    }
}
