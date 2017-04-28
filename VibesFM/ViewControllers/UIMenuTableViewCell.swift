//
//  UIMenuTableViewCell.swift
//  VibesFM
//
//  Created by Admin on 4/12/17.
//  Copyright © 2017 blukey630. All rights reserved.
//

import Foundation

class UIMenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var menuLine: UIImageView!
    @IBOutlet weak var menuIcon: UIImageView!
    @IBOutlet weak var menuName: UILabel!
    @IBOutlet weak var nameConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imgConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }
}
