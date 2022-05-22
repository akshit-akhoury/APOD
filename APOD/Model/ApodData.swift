//
//  ApodData.swift
//  APOD
//
//  Created by Akshit Akhoury on 22/05/22.
//

import UIKit

class ApodData: NSObject,NSSecureCoding
{
    static var supportsSecureCoding: Bool {
           return true
    }
    
    let title:String
    let explanation:String
    let copyright:String
    let imageData:Data
    
    func encode(with coder: NSCoder)
    {
        coder.encode(title,forKey: "title")
        coder.encode(explanation,forKey: "explanation")
        coder.encode(copyright,forKey: "copyright")
        coder.encode(imageData,forKey: "imageData")
    }
    
    required init?(coder: NSCoder)
    {
        title = coder.decodeObject(forKey: "title") as? String ?? ""
        explanation = coder.decodeObject(forKey: "explanation") as? String ?? ""
        copyright = coder.decodeObject(forKey: "copyright") as? String ?? ""
        imageData = coder.decodeObject(forKey: "imageData") as? Data ?? Data()
    }
    
    init(title:String,explanation:String,copyright:String,imageData:Data)
    {
        self.title = title
        self.explanation = explanation
        self.copyright = copyright
        self.imageData = imageData
        super.init()
    }
}
