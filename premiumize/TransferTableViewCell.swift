//
//  TransferTableViewCell.swift
//  premiumize
//
//  Created by Jonas Geissler on 22.09.18.
//  Copyright © 2018 Jonas Geissler. All rights reserved.
//

import UIKit

class TransferTableViewCell: UITableViewCell {

    @IBOutlet weak var lblState: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblProgress: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
