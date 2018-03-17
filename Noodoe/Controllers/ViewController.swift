//
//  ViewController.swift
//  Noodoe
//
//  Created by giggs on 17/03/2018.
//  Copyright © 2018 giggs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var accountTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    
    var textFieldList: Array<UITextField>?
    let tagBase: Int = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextFields()
        setupLoginButton()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(gesture:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupTextFields() -> Void {
        textFieldList = [accountTextField, passwordTextField]
        
        textFieldList!.enumerated().forEach { entry in
            let offset = entry.offset
            let textField = entry.element
            
            textField.tag = tagBase + offset
            textField.returnKeyType = (offset < textFieldList!.count - 1) ? .next : UIReturnKeyType.done
            textField.delegate = self
        }
    }
    
    @objc private func hideKeyboard(gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    private func setupLoginButton() -> Void {
        loginButton.isEnabled = false
        loginButton.addTarget(self, action: #selector(submit(sender:)), for: .touchUpInside)
    }
    
    @objc private func submit(sender: UIButton) -> Void {
        guard let username = accountTextField.text, let password = passwordTextField.text else {
            return
        }
        
        ApiService.login(username: username, password: password, handler:
            HttpHandler(
                successHandler: { data, res in
                    let code = res.statusCode
                    switch code {
                    case 200:
                        if let userModel = ApiService.desiralize(type: UserModel.self, data: data) {
                            AppConfig.userModel = userModel
                            self.showUpdateViewController()
                        }
                    default:
                        if let _data = data, let errorModel = try? JSONDecoder().decode(ErrorModel.self, from: _data) {
                            self.showAlert(message: "\(errorModel.code ?? 0) - \(errorModel.error ?? "")")
                        } else {
                            NSLog("Warning -> Unhandle status code: \(code)")
                        }
                    }
            },
                errorHandler: { error in
                    NSLog("Error -> \(error.localizedDescription)")
                    self.showAlert(message: error.localizedDescription)
            }
            )
        )
    }
    
    private func showAlert(message: String) -> Void {
        
        let alertVc = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertVc.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alertVc, animated: false, completion: nil)
        }
        
    }
    
    private func showUpdateViewController() -> Void {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UpdateViewController")
        
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        guard let _txFields = textFieldList else {
            return true
        }
        
        let offset = textField.tag - tagBase
        let hasNext = offset < _txFields.count - 1
        
        if hasNext {
            _txFields[offset + 1].becomeFirstResponder()
        }
        
        return !hasNext
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let _txFields = textFieldList else {
            return
        }
        
        let anyIsEmpty = _txFields.reduce(false) { prev, e in
            prev || (e.text?.isEmpty ?? true)
        }
        
        loginButton.isEnabled = !anyIsEmpty
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let _txFields = textFieldList, let current: NSString = textField.text as NSString? else {
            return true
        }
        
        var anyIsEmpty = false
        anyIsEmpty = anyIsEmpty || current.replacingCharacters(in: range, with: string).isEmpty
        
        anyIsEmpty = _txFields.filter({ $0 !== textField })
            .reduce(anyIsEmpty) { prev, e in
                prev || (e.text?.isEmpty ?? true)
        }
        
        loginButton.isEnabled = !anyIsEmpty
        
        return true
    }
    
}

