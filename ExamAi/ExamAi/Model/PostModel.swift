//
//  PostModel.swift
//  ExamAi
//
//  Created by PCQ183 on 05/08/19.
//  Copyright © 2019 PCQ183. All rights reserved.
//

import UIKit
import SwiftyJSON

class PostModel: NSObject {
    
    var title           : String!   = ""
    var createdOn       : String!   = ""
    var isPostSelected  : Bool      = false
    
    
    required init(dictionary: JSON) {
        
        if dictionary.isEmpty != true {
            self.title = dictionary["title"].stringValue
           
            if let createdAt = dictionary["created_at"].string {
                let date        = PostDate.date(fromString: createdAt, withFormat: PostDateFormat.serverDateFormat)
                self.createdOn  = PostDate.string(fromDate: date!, withFormat: PostDateFormat.appDateFormat)
            }
        }
    }
}
