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
}

enum ErrorResult {
    case success
    case failure
}
