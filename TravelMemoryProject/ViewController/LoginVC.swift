//
//  LoginVC.swift
//  TravelMemoryProject
//
//  Created by IPS-153 on 03/01/23.
//

import Foundation
import UIKit
import TextFieldEffects
import Toaster
class loginVC: UIViewController {
    
    @IBOutlet weak var txtEmail: HoshiTextField!
    @IBOutlet weak var txtPassword: HoshiTextField!
    var isFromWidget:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        if isFromWidget {
            VideoService.instance.launchVideoRecorder(in: self, completion: nil)
        }
    }
    
    func naviToViewController() {
        DispatchQueue.main.async {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
            self.navigationController?.pushViewController(vc, animated: false)
        }
        
    }
    
}
//MARK: - Action Method
extension loginVC {
    @IBAction func btnLoginTapped(_ sender: UIButton) {
        let result = isValid()
        if result.valid {
            callLoginApi()
            return
        }
        Toast(text: "\(result.error)").show()
    }
    
    @IBAction func btnSignUpTapped(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: APi Calling
extension loginVC {
    
    func callLoginApi() {
        
        var params: [String:Any] = [:]
        params["email"] = txtEmail.text
        params["password"] = txtPassword.text
        CatFactApi().LogIn(parameters: params) { result in
            switch result {
            case .success(let value):
                Toast(text: "Login Successfully").show()
                value.setUserDetailToUserDefault()
                print(LoginModel.getUserDetailFromUserDefault())
                print("WITH RETURN TYPE \(value)")
                self.naviToViewController()
            case .failure(let error):
                print("-------\(error.localizedDescription)")
                switch error {
                case .internalError:
                    Toast(text: "Something went wrong.").show()
                case .serverError:
                    Toast(text: "Server issue.").show()
                case .parsingError:
                    Toast(text: "Invalid Cerdential.").show()
                }
            default:
                print("Default")
            }
        }
    }
}

//MARK: - Validation
extension loginVC {
    
    func isValid() -> (valid: Bool, error: String) {
        var result = (valid: true, error: "")
        if String.validate(value: txtEmail.text) {
            result.valid = false
            result.error = "Please enter email address."
            return result
        }else if !txtEmail.text!.isEmailAddressValid {
            result.valid = false
            result.error = "Please enter valid email address."
            return result
        }else if String.validate(value: txtPassword.text) {
            result.valid = false
            result.error = "Please enter password."
            return result
        }
        return result
    }
    
}
