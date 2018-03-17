//
//  UpdateViewController.swift
//  Noodoe
//
//  Created by giggs on 17/03/2018.
//  Copyright © 2018 giggs. All rights reserved.
//

import Foundation
import UIKit

class UpdateViewController: UIViewController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func updateButtonDidTap(_ sender: UIButton) {
        
        let userModle = UserModel()
        userModle.timezone = 8
        
        ApiService.updateUser(dataModel: userModle, handler: HttpHandler(successHandler: { data, res in
            let code = res.statusCode
            switch code {
            case 200:
                self.showAlert(message: "Update timezone to 8. successful.")
            default:
                if let _data = data, let errorModel = try? JSONDecoder().decode(ErrorModel.self, from: _data) {
                    self.showAlert(message: "\(errorModel.code ?? 0) - \(errorModel.error ?? "")")
                } else {
                    NSLog("Warning -> Unhandle status code: \(code)")
                }
            }
        }))
        
    }
    
    private func showAlert(message: String) -> Void {
        
        let alertVc = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertVc.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alertVc, animated: false, completion: nil)
        }
        
    }
 
}
