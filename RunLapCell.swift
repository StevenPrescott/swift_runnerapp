//
//  RunLapCell.swift
//  RunnerApp
//
//  Created by Tarun Sachdeva on 10/2/15.
//  Copyright (c) 2015 Tarun Sachdeva. All rights reserved.
//

import UIKit

class RunLapCell: UITableViewCell {
    
    @IBOutlet var nameLbl : UILabel!
    @IBOutlet var hoursLbl : UILabel!
    @IBOutlet var minuteLbl : UILabel!
    @IBOutlet var secondsLbl : UILabel!
    @IBOutlet var runnerNameLbl : UILabel!
    
    @IBOutlet var timeLbl : UILabel!
    
    var runnerId:NSMutableString = NSMutableString()
    
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
