//
//  APIResponse.swift
//  APOD
//
//  Created by Akshit Akhoury on 22/05/22.
//

import Foundation

struct APIResponse:Decodable
{
    let date:String?
    let explanation:String
    let hdurl:URL
    let media_type:String
    let copyright:String?
    let title:String
    let url:URL
}
