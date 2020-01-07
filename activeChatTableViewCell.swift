//
//  activeChatTableViewCell.swift
//  Instant
//
//  Created by Suflea Marius on 14/11/2019.
//  Copyright © 2019 Marius Suflea. All rights reserved.
//

import UIKit

class activeChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var receivedView: UIView!
    
    @IBOutlet weak var sentView: UIView!
    
    @IBOutlet weak var sentText: UITextView!
    
    @IBOutlet weak var receivedText: UITextView!
    
    @IBOutlet weak var sentImage: UIImageView!
    
    @IBOutlet weak var receivedImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
