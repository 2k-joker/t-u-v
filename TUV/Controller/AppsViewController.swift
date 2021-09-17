//
//  AppsViewController.swift
//  TUV
//
//  Created by Khalil Kum on 8/23/21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class AppsViewController: UIViewController {
    // MARK: Properties
    fileprivate var availableApps: [DataSnapshot]! = []
    fileprivate var appsConnectionStatusMap: [String:String]! = [:]
    fileprivate var selectedAppSnapshot: DataSnapshot!
    fileprivate let currentUser = Auth.auth().currentUser!
    fileprivate let dbReference = Database.database().reference()
    fileprivate var currentSelectedCell: UITableViewCell!
    fileprivate var _appConnectedRefHandle: DatabaseHandle!
    fileprivate var _appDisconnectedRefHandle: DatabaseHandle!
    fileprivate var _appAddedRefHandle: DatabaseHandle!

    // MARK: Outlets
    @IBOutlet weak var appsTableView: UITableView!
    @IBOutlet weak var finishButton: UIButton!
    
    // MARK: View States
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appsTableView.delegate = self
        appsTableView.dataSource = self
        finishButton.setTitleColor(.lightGray, for: .disabled)
        finishButton.isEnabled = false
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        availableApps.removeAll()
        appsTableView.reloadData()

        configureConnectedAppsHandler()
        configureDisconnectedAppsHandler()
        configureAddedAppsHandler()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        dbReference.child("users/\(currentUser.uid)/connectedApps").removeObserver(withHandle: _appConnectedRefHandle)
        dbReference.removeAllObservers()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "appDetailViewSegue" {
            let appDetailViewController = segue.destination as! AppDetailViewController

            appDetailViewController.selectedAppSnapshot = selectedAppSnapshot
        }
    }

    // MARK: Actions
    
    // MARK: Functions
    func configureConnectedAppsHandler() {
        _appConnectedRefHandle = dbReference.child("users/\(currentUser.uid)/connectedApps").observe(.childAdded, with: { snapshot in

            self.updateCurrentSelectedCell(with: "connected")
            self.appsConnectionStatusMap[snapshot.key] = "connected"
            self.updateFinishButton()
        })
    }
    
    func configureDisconnectedAppsHandler() {
        _appDisconnectedRefHandle = dbReference.child("users/\(currentUser.uid)/connectedApps").observe(.childRemoved, with: { snapshot in
            
            self.updateCurrentSelectedCell(with: "disconnected")
            self.appsConnectionStatusMap[snapshot.key] = "disconnected"
            self.updateFinishButton()
        })
    }
    
    func configureAddedAppsHandler() {
        _appAddedRefHandle = dbReference.child("apps").observe(.childAdded, with: { snapshot in

            self.availableApps.append(snapshot)
            self.appsTableView.insertRows(at: [IndexPath(row: self.availableApps.count - 1, section: 0)], with: .bottom)
        })
    }

    func updateFinishButton() {
        let connectedAppsCount = appsConnectionStatusMap.filter { $0.value == "connected" }
        finishButton.isEnabled = (connectedAppsCount.count > 0)
    }
    
    func updateCurrentSelectedCell(with newLabelText: String) {
        if let currentCell = currentSelectedCell {
            currentCell.detailTextLabel?.text = newLabelText
        }
    }
}

extension AppsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableApps.count
    }
    
    // MARK: Table view delegates
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = appsTableView.dequeueReusableCell(withIdentifier: "appCell")!
        let appSnapshot = availableApps[indexPath.row]
        let appData = appSnapshot.value as! [String:Any]
        let connectionStatus = appsConnectionStatusMap[appSnapshot.key]
        
        cell.textLabel?.text = appSnapshot.key
        cell.detailTextLabel?.text = connectionStatus == nil ? "disconnected" : connectionStatus
        cell.imageView?.image = UIImage(named: appData["imageName"] as! String)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            print("could not dequeue cell")
            return }
        
        currentSelectedCell = cell
        appsTableView.deselectRow(at: indexPath, animated: true)
        selectedAppSnapshot = availableApps[indexPath.row]
        self.performSegue(withIdentifier: "appDetailViewSegue", sender: cell)
    }
}
