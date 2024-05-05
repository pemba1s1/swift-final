//
//  NewsTableViewCell.swift
//  Pemba_Sherpa_FE_8965121
//
//  Created by user237120 on 4/6/24.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var desc: UILabel!    

    @IBOutlet weak var source: UILabel!
    
    @IBOutlet weak var author: UILabel!
    
    override func awakeFromNib() {
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
