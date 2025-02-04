//
//  Alert.swift
//  Virtual Tourist
//
//  Created by Aaryan Kothari on 15/05/20.
//  Copyright © 2020 Aaryan Kothari. All rights reserved.
//

import UIKit

extension UIViewController {
    func deleteAlert(_ item : String,completion: @escaping (ErrorResult)->()){
        let deleteAlert = UIAlertController(title: "Delete " + item, message: "This action cannot be undone", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){ (UIAlertAction) in
            completion(.failure)
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (UIAlertAction) in
            completion(.success)
        }
        deleteAlert.addAction(cancelAction)
        deleteAlert.addAction(deleteAction)
        
        self.present(deleteAlert,animated: true)
    }
    
    //MARK:- ALERT fucntion for error display
    internal func errorALert(_ message:String, completion: (() -> Void)? = nil){
        let title = "Uh Oh 🙁"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}

enum ErrorResult {
    case success
    case failure
}
