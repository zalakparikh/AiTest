//
//  DetailTableCell.swift
//  ExamAi
//
//  Created by PCQ183 on 05/08/19.
//  Copyright © 2019 PCQ183. All rights reserved.
//

import UIKit

class DetailTableCell: UITableViewCell {
    
    //MARK:- IBOutlet
    @IBOutlet private weak var lblTitle     : UILabel!
    @IBOutlet private weak var lblDate      : UILabel!
    @IBOutlet private weak var toggleSwitch : UISwitch!
    
    //MARK:- variable
    var postData : PostModel!{
        didSet{
            self.setPostData()
        }
    }
    
    //MARK:- setUpData Method
    private func setPostData(){
        self.lblTitle.text      = self.postData.title
        self.lblDate.text       = self.postData.createdOn
        self.toggleSwitch.isOn  = self.postData.isPostSelected
        self.backgroundColor    = self.postData.isPostSelected ? .lightGray : .white
    }
    
}
