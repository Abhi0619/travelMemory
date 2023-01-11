//
//  GuestVC.swift
//  TravelMemoryProject
//
//  Created by IPS-153 on 10/01/23.
//

import UIKit

class GuestVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func btnAsGuestTapped(_ sender: UIButton) {
        DispatchQueue.main.async {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @IBAction func btnLoginTapped(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginVC") as! loginVC
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
