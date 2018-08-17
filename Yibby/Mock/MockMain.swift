//
//  MockMain.swift
//  Yibby
//
//  Created by Kishy Kumar on 3/1/18.
//  Copyright © 2018 Yibby. All rights reserved.
//

import Foundation
import OHHTTPStubs
import CocoaLumberjack

// MockMain singleton
class MockMain: NSObject {
    
    // MARK: - Properties
    
    override init() {
        
    }
    
    static let shared = MockMain()
    static var isMocked: Bool = false // default
    
    fileprivate weak var createBidStub: OHHTTPStubsDescriptor?
    fileprivate weak var endRideStub: OHHTTPStubsDescriptor?
    fileprivate var bidStubCallCount: Int = 0
    
    fileprivate var driverEnRouteNotification: [AnyHashable: Any]?
    fileprivate var rideStartNotification: [AnyHashable: Any]?
    fileprivate var driverArrivedNotification: [AnyHashable: Any]?
    fileprivate var rideEndNotification: [AnyHashable: Any]?
    
    fileprivate var mockTimer: Timer?

    // MARK: APIs
    
    func setup() {
        setupStubs()
        setupNotifications()
        MockMain.isMocked = true
    }
    
    func destroy() {
        removeStubs()
        MockMain.isMocked = false
    }
    
    // MARK: Helpers
    
    fileprivate func setupNotifications() {
        
        driverEnRouteNotification = ["message": "DRIVER_EN_ROUTE", "gcm.message_id": "0:1519976237855743%13a638aa13a638aa",
                                     "custom":  "{\"id\":\"d1f072fa-8eb2-471d-8b70-e851def6e571\",\"riderBidPrice\":38.0,\"driverBidPrice\":38.0,\"fare\":38.0,\"people\":1,\"pickupLocation\":{\"latitude\":37.422094,\"longitude\":-122.084068,\"name\":\"Googleplex, Amphitheatre Parkway, Mountain View, CA\"},\"dropoffLocation\":{\"latitude\":37.430033,\"longitude\":-122.173335,\"name\":\"Stanford Computer Science Department\"},\"driverLocation\":{\"latitude\":37.36522870607428,\"longitude\":-122.018072661126},\"driver\":{\"id\":\"3e249333-a689-4fcb-a853-33423a2f23cf\",\"firstName\":\"KISHY\",\"location\":{\"latitude\":37.36522870607428,\"longitude\":-122.018072661126},\"profilePictureFileId\":\"deff3a0b-a79f-4cc6-af0b-430e0a618225\",\"rating\":\"4.0\"},\"vehicle\":{\"id\":\"b481d4a6-9fd7-47bc-ad00-02f0f4bd8890\",\"exteriorColor\":\"RED\",\"licensePlate\":\"7KTU083\",\"make\":\"CHEVROLET\",\"model\":\"CAMARO\",\"capacity\":\"4\",\"vehiclePictureFileId\":\"\"},\"bidId\":\"0baacaf3-de8a-4fd7-ac00-76af10f0f111\",\"datetime\":\"2018-03-03T14:20:09.530-0800\",\"paymentMethodToken\":\"78trm3\",\"paymentMethodBrand\":\"Visa\",\"paymentMethodLast4\":\"1881\"}",
                                     "aps": [ "content-available": 1 ]]

        driverArrivedNotification = ["message": "DRIVER_ARRIVED", "gcm.message_id": "0:1519974904722076%13a638aa13a638aa",
                                    "custom": "{\"id\":\"d1f072fa-8eb2-471d-8b70-e851def6e571\",\"driverLocation\":{\"latitude\":37.3651811806833,\"longitude\":-122.018172992507},\"bidId\":\"0baacaf3-de8a-4fd7-ac00-76af10f0f111\"}",
                                    "aps": [ "content-available": 1 ]]

        rideStartNotification = ["message": "RIDE_START", "gcm.message_id": "0:1519975347288419%13a638aa13a638aa",
                                 "custom": "{\"id\":\"d1f072fa-8eb2-471d-8b70-e851def6e571\",\"driverLocation\":{\"latitude\":37.3651811806833,\"longitude\":-122.018172992507},\"bidId\":\"0baacaf3-de8a-4fd7-ac00-76af10f0f111\"}",
                                 "aps": [ "content-available": 1 ]]
        
        rideEndNotification = ["message": "RIDE_END", "gcm.message_id": "0:1519975487166703%13a638aa13a638aa",
                               "custom": "{\"id\":\"d1f072fa-8eb2-471d-8b70-e851def6e571\",\"driverLocation\":{\"latitude\":37.3651811806833,\"longitude\":-122.018172992507},\"bidId\":\"0baacaf3-de8a-4fd7-ac00-76af10f0f111\"}",
                               "aps": [ "content-available": 1 ]]
    }

    fileprivate func setupStubs() {
        
        let noDriversJsonPath = OHPathForFile("createbidresp1.json", type(of: self))
        let bidSuccessJsonPath = OHPathForFile("createbidresp2.json", type(of: self))
        let endRideJsonPath = OHPathForFile("endrideresp.json", type(of: self))
        
        // Install
        self.createBidStub = stub(condition: pathEndsWith("bid") && isMethodPOST()) { [weak self] _ in
            
            if let strongSelf = self {
                
                var callCount: Int = strongSelf.bidStubCallCount
                callCount = callCount + 1
                
                if (callCount == 3) {
                    callCount = 1
                }
                strongSelf.bidStubCallCount = callCount
                
                if (callCount == 1) {
                    
                    strongSelf.startMockTimer()
                    
                    return fixture(filePath: bidSuccessJsonPath!, headers: ["Content-Type":"application/json"])
                        .requestTime(2.0, responseTime: OHHTTPStubsDownloadSpeedWifi)
                    
                } else if (callCount == 2) {
                    
                    return fixture(filePath: noDriversJsonPath!, headers: ["Content-Type":"application/json"])
                        .requestTime(2.0, responseTime: OHHTTPStubsDownloadSpeedWifi)
                }
            }
            
            return fixture(filePath: noDriversJsonPath!, headers: ["Content-Type":"application/json"])
                .requestTime(2.0, responseTime: OHHTTPStubsDownloadSpeedWifi)
        }
        createBidStub?.name = "createBid stub"
        
        self.endRideStub = stub(condition: pathEndsWith("ride/review") && isMethodPOST()) { [weak self] _ in
            
            return fixture(filePath: endRideJsonPath!, headers: ["Content-Type":"application/json"])
                .requestTime(2.0, responseTime: OHHTTPStubsDownloadSpeedWifi)
        }
        endRideStub?.name = "endRide stub"
        
        OHHTTPStubs.onStubActivation { (request: URLRequest, stub: OHHTTPStubsDescriptor, response: OHHTTPStubsResponse) in
            DDLogVerbose("[OHHTTPStubs] Request to \(request.url!) has been stubbed with \(String(describing: stub.name))")
        }
    }
    
    fileprivate func removeStubs() {
        OHHTTPStubs.removeAllStubs()
    }
    
    // Post notifications
    func notifyDriverArrived() {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.pushController.processNotification(driverArrivedNotification!, isForeground: true)
    }
    
    func notifyRideStart() {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.pushController.processNotification(rideStartNotification!, isForeground: true)
    }
    
    func notifyRideEnd() {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.pushController.processNotification(rideEndNotification!, isForeground: true)
    }
    
    // MARK: - Mock Timer functions
    
    fileprivate func startMockTimer() {
        
        mockTimer = Timer.scheduledTimer(timeInterval: 20.0,
                                          target: self,
                                          selector: #selector(MockMain.bidWaitTimeoutCallback),
                                          userInfo: nil,
                                          repeats: false)
    }
    
    fileprivate func stopMockTimer() {
        if let mockTimer = self.mockTimer {
            mockTimer.invalidate()
        }
    }
    
    @objc fileprivate func bidWaitTimeoutCallback() {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.pushController.processNotification(driverEnRouteNotification!, isForeground: true)
    }
}
