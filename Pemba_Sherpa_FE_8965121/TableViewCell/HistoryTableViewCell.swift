//
//  HistoryTableViewCell.swift
//  Pemba_Sherpa_FE_8965121
//
//  Created by user237120 on 4/11/24.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    
    @IBOutlet weak var type: UIButton!
    
    @IBOutlet weak var city: UILabel!
    
    @IBOutlet weak var source: UILabel!
    
    @IBOutlet weak var contentStackView: UIStackView!
    
    //Function assigned from HistoryTableViewController and called when button clicked
    var buttonTappedHandler: (() -> Void)?
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        buttonTappedHandler?()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
