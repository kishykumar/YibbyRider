//
//  Vehicle.swift
//  Yibby
//
//  Created by Kishy Kumar on 1/3/17.
//  Copyright © 2017 MyComp. All rights reserved.
//

import UIKit
import GoogleMaps
import ObjectMapper

class YBVehicle: Mappable {
    
    // MARK: - Properties
    var id: String?
    var exteriorColor: String?
    var licensePlate: String?
    var make: String?
    var model: String?
    var capacity: Int?
    var vehiclePictureFileId: String?
    
    // MARK: Initialization
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        id                   <- map["id"]
        exteriorColor        <- map["exteriorColor"]
        licensePlate         <- map["licensePlate"]
        make                 <- map["make"]
        model                <- map["model"]
        capacity             <- map["capacity"]
        vehiclePictureFileId <- map["vehiclePictureFileId"]
    }
}

extension YBVehicle {
    func makeAndModel() -> String {
        return (make!) + " " + (model!)
    }
}
