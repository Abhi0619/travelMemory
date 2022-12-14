//
//  locationCell.swift
//  TravelMemoryProject
//
//  Created by IPS-161 on 12/12/22.
//

import UIKit

class locationCell: UITableViewCell {
    @IBOutlet weak var lblLatitude: UILabel!
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblVideoURL: UILabel!
    @IBOutlet weak var lblLongitude: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
