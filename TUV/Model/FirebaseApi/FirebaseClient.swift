//
//  FirebaseClient.swift
//  TUV
//
//  Created by Khalil Kum on 10/3/21.
//

import FirebaseDatabase
import FirebaseAuth

class FirebaseClient {
    // MARK: Properties
    static let dbReference: DatabaseReference = Database.database().reference()
    let currentUser: User? = Auth.auth().currentUser
    
    class func retrieveDataFromFirebase(forPath pathString: String, withTimeout timeoutSeconds: TimeInterval = 10, completionHandler: @escaping ((Bool, Error?, DataSnapshot?) -> Void)) {
        let timer = HelperMethods.configureTimeoutObserver(withTimeoutSeconds: timeoutSeconds) {
            completionHandler(true, nil, nil)
        }
        
        dbReference.child(pathString).observeSingleEvent(of: .value) { snapshot in
            timer.invalidate()
            
            if snapshot.exists() {
                dbReference.child(pathString).keepSynced(true)

                completionHandler(false, nil, snapshot)
            } else {
                dbReference.child(pathString).getData { error, snapshot in
                    if snapshot.exists() {
                        dbReference.child(pathString).keepSynced(true)
                        
                        completionHandler(false, nil, snapshot)
                    } else if error != nil {
                        completionHandler(false, error, nil)
                    } else {
                        let error = NSError(domain: "Failed to load data for path: \(pathString)", code: 404, userInfo: nil) as Error
                        completionHandler(false, error, nil)
                    }
                }
            }
        }
    }
    
    class func retrieveDataFromFirebase(forQuery query: DatabaseQuery, withTimeout timeoutSeconds: TimeInterval = 10, completionHandler: @escaping((Bool, Error?, DataSnapshot?) -> Void)) {
        let timer = HelperMethods.configureTimeoutObserver(withTimeoutSeconds: timeoutSeconds) {
            completionHandler(true, nil, nil)
        }
        
        query.observeSingleEvent(of: .value) { snapshot in
            timer.invalidate()
            
            if snapshot.exists() {
                query.keepSynced(true)

                completionHandler(false, nil, snapshot)
            } else {
                query.getData { error, snapshot in
                    if snapshot.exists() {
                        query.keepSynced(true)
                        
                        completionHandler(false, nil, snapshot)
                    } else if error != nil {
                        completionHandler(false, error, nil)
                    } else {
                        let error = NSError(domain: "Failed to load data for query: \(query.debugDescription)", code: 404, userInfo: nil) as Error
                        completionHandler(false, error, nil)
                    }
                }
            }
        }
    }
    
    class func writeDataToFirebase(withNewData updates: [String:Any], withTimeout timeoutSeconds: TimeInterval = 30, completionHandler: @escaping ((Bool, Error?, DatabaseReference?) -> Void)) {
        let timer = HelperMethods.configureTimeoutObserver(withTimeoutSeconds: timeoutSeconds) {
            completionHandler(true, nil, nil)
        }
        
        dbReference.updateChildValues(updates) { error, reference in
            timer.invalidate()
            completionHandler(false, error, reference)
        }
    }
}
