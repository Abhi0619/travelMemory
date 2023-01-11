//
//  Extension.swift
//  TravelMemoryProject
//
//  Created by IPS-153 on 10/01/23.
//

import Foundation
extension LoginModel {
    func setUserDetailToUserDefault(){
        do{
            let userDetail = try JSONEncoder().encode(self)
            
            _userDefault.setValue(userDetail, forKey: user_Detail)
            _userDefault.synchronize()
        }catch{
            DispatchQueue.main.async {
                
            }
        }
    }
    static func getUserDetailFromUserDefault() -> LoginModel? {
        if let userDetail = UserDefaults.standard.value(forKey: user_Detail) as? Data{
            do {
                let user:LoginModel = try JSONDecoder().decode(LoginModel.self, from: userDetail)
                return user
            }catch{
                DispatchQueue.main.async {
                    
                }
                return nil
            }
        }
        DispatchQueue.main.async {
            //ShowToast.show(toatMessage: kCommonError)
        }
        return nil
    }
}
