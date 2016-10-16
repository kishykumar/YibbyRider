//
//  MainViewControllerSpec.swift
//  Yibby
//
//  Created by Kishy Kumar on 9/29/16.
//  Copyright © 2016 Yibby. All rights reserved.
//

@testable
import Yibby
import Quick
import Nimble
import Nimble_Snapshots
import GoogleMaps
import Braintree
import CocoaLumberjack

class MainViewControllerSpec: QuickSpec {
    override func spec() {
        
        describe("MainViewController") {
            
            let biddingStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Bidding, bundle: nil)
            var subject = biddingStoryboard.instantiateViewControllerWithIdentifier("MainViewControllerIdentifier") as! MainViewController
            
            beforeEach {
                // Arrange
                subject = biddingStoryboard.instantiateViewControllerWithIdentifier("MainViewControllerIdentifier") as! MainViewController
                
                // Act
                _ = subject.view
            }
            
            // Assert
            describe ("Initialization") {
                
                describe("Storyboard") {
                    
                    it("IBOutlets are  not nil") {
                        expect(subject.gmsMapViewOutlet).notTo(beNil())
                        expect(subject.rangeSliderOutlet).notTo(beNil())
                        expect(subject.bidButton).notTo(beNil())
                        expect(subject.cardLabelOutlet).notTo(beNil())
                        expect(subject.maxBidLabelOutlet).notTo(beNil())
                        expect(subject.priceSliderViewOutlet).notTo(beNil())
                        expect(subject.miscPickerViewOutlet).notTo(beNil())
                        expect(subject.peopleButtonOutlet).notTo(beNil())
                        expect(subject.peopleLabelOutlet).notTo(beNil())
                        expect(subject.cardHintOutlet).notTo(beNil())
                        expect(subject.centerMarkersViewOutlet).notTo(beNil())
                    }
                    
                    it("IBActions are wired up") {
                        let bidActions = subject.bidButton.actionsForTarget(subject, forControlEvent: UIControlEvents.TouchUpInside)
                        expect(bidActions).to(contain("onBidButtonClick:"))
                        expect(bidActions?.count) == 1
                    }
                    
                    it("is a BaseYibbyViewController") {
                        expect(subject).to(beAKindOf(BaseYibbyViewController.self))
                    }
                    
                    it("is a MainViewController") {
                        expect(subject).to(beAKindOf(MainViewController.self))
                    }
                }
                
                describe("Delegates") {
                    it("are setup") {
                        
                        expect(subject.gmsMapViewOutlet.delegate as? MainViewController).to(equal(subject))
                        expect(subject.peopleButtonOutlet.delegate as? MainViewController).to(equal(subject))
                    }
                }
                
                describe("Map") {
                    it("is setup") {
                        expect(subject.gmsMapViewOutlet.myLocationEnabled).to(beTrue())
                        expect(subject.gmsMapViewOutlet.settings.consumesGesturesInView).to(beTrue())
                    }
                }
                
                describe("Map Client") {
                    it("is setup") {
                        expect(subject.placesClient).toNot(beNil())
                    }
                }
            }
            
            describe("snapshots") {
                beforeEach {
                }
                validateAllSnapshots(subject, named: "Launch")
            }
            
            describe("Map") {
                
                describe("Set address") {
                
                    let lat: CLLocationDegrees = 1.1
                    let long: CLLocationDegrees = -1.2
                    let latLng: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat,long)
                    let address = "000 Oracle Pkwy, Redwood City, CA 94065"
                    
                    context("Dropoff") {
                        
                        beforeEach {
                            subject.setDropoffDetails(address, loc: latLng)
                        }

                        it("has correct details") {
                            expect(subject.dropoffPlaceName).to(equal(address))
                            expect(subject.dropoffLatLng).toNot(beNil())
                            expect(subject.dropoffMarker).toNot(beNil())
                            
                            if let dropoffMarker = subject.dropoffMarker {
                                expect(dropoffMarker.map).to(equal(subject.gmsMapViewOutlet))
                                expect(dropoffMarker.icon).toNot(beNil())
                                expect(dropoffMarker.position.latitude).to(equal(latLng.latitude))
                                expect(dropoffMarker.position.longitude).to(equal(latLng.longitude))
                            }
                            
                            if let dropoffLatLng = subject.dropoffLatLng {
                                expect(dropoffLatLng.latitude).to(equal(latLng.latitude))
                                expect(dropoffLatLng.longitude).to(equal(latLng.longitude))
                            }
                        }
                    }
                    
                    context("Pickup") {
                        
                        beforeEach {
                            subject.setPickupDetails(address, loc: latLng)
                        }
                        
                        it("has correct details") {
                            expect(subject.pickupPlaceName).to(equal(address))
                            expect(subject.pickupLatLng).toNot(beNil())
                            expect(subject.pickupMarker).toNot(beNil())
                            
                            if let pickupMarker = subject.pickupMarker {
                                expect(pickupMarker.map).to(equal(subject.gmsMapViewOutlet))
                                expect(pickupMarker.icon).toNot(beNil())
                                expect(pickupMarker.position.latitude).to(equal(latLng.latitude))
                                expect(pickupMarker.position.longitude).to(equal(latLng.longitude))
                            }
                            
                            if let pickupLatLng = subject.pickupLatLng {
                                expect(pickupLatLng.latitude).to(equal(latLng.latitude))
                                expect(pickupLatLng.longitude).to(equal(latLng.longitude))
                            }
                        }
                    }
                    
                    context("Current Location") {
                        beforeEach {
                            subject.setCurrentLocationDetails(address, loc: latLng)
                        }
                        
                        it("has correct details") {
                            expect(subject.currentPlaceName).to(equal(address))
                            expect(subject.currentPlaceLatLng).toNot(beNil())
                            
                            if let currentPlaceLatLng = subject.currentPlaceLatLng {
                                expect(currentPlaceLatLng.latitude).to(equal(latLng.latitude))
                                expect(currentPlaceLatLng.longitude).to(equal(latLng.longitude))
                            }
                        }
                    }
                }
                
                describe("Adjusting camera") {
                    
                    let lat: CLLocationDegrees = 1.1
                    let long: CLLocationDegrees = -1.2
                    let latLng: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat,long)
                    let address = "000 Oracle Pkwy, Redwood City, CA 94065"
                    
                    context("With nil pickup and nil dropoff") {
                        beforeEach {
                            subject.pickupMarker = nil
                            subject.dropoffMarker = nil
                        }
                        
                        it("works") {
                            subject.adjustGMSCameraFocus()
                        }
                    }
                    
                    context("With nil pickup and valid dropoff") {
                        beforeEach {
                            subject.pickupMarker = nil
                            subject.setDropoffDetails(address, loc: latLng)
                        }
                        
                        it("works") {
                            subject.adjustGMSCameraFocus()
                        }
                    }
                    
                    context("With valid pickup and nil dropoff") {
                        beforeEach {
                            subject.setPickupDetails(address, loc: latLng)
                            subject.dropoffMarker = nil
                        }
                        
                        it("works") {
                            subject.adjustGMSCameraFocus()
                        }
                    }
                }
            }
            
            describe("JOButtonMenuDelegate") {
                
                it("updates label text") {
                    subject.selectedOption(subject.peopleButtonOutlet, index: 0)
                    expect(subject.peopleLabelOutlet.text).to(equal(subject.peopleButtonOutlet.dataset[0].labelText))
                    
                    subject.selectedOption(subject.peopleButtonOutlet, index: 1)
                    expect(subject.peopleLabelOutlet.text).to(equal(subject.peopleButtonOutlet.dataset[1].labelText))
                    
                    subject.selectedOption(subject.peopleButtonOutlet, index: 2)
                    expect(subject.peopleLabelOutlet.text).to(equal(subject.peopleButtonOutlet.dataset[2].labelText))
                    
                    subject.selectedOption(subject.peopleButtonOutlet, index: 3)
                    expect(subject.peopleLabelOutlet.text).to(equal(subject.peopleButtonOutlet.dataset[3].labelText))
                }
            }
            
            describe("GMSMapViewDelegate") {
                
                it("doesn't do default action") {
                    
                    let ret = subject.mapView(subject.gmsMapViewOutlet, didTapMarker: subject.pickupMarker)
                    expect(ret).to(beTrue())
                }
            }
            
            describe("SelectPaymentViewControllerDelegate") {
                
                var paymentMethod: BTPaymentMethodNonce!
                var paymentController: PaymentViewController!
                
                beforeEach {
                    let paymentStoryboard: UIStoryboard = UIStoryboard(name: InterfaceString.StoryboardName.Payment, bundle: nil)
                    paymentController = paymentStoryboard.instantiateViewControllerWithIdentifier("PaymentViewControllerIdentifier")
                                            as! PaymentViewController
                    paymentController.controllerType = .PickForRide
                    
                    paymentMethod = BTPaymentMethodNonce(nonce: "hello",
                                                        localizedDescription: "ending in 45",
                                                        type: "Visa",
                                                        isDefault: false)
                }
                
                it("payment method is updated after selecting") {
                    
                    // send the tap
                    subject.onPaymentSelectAction(UITapGestureRecognizer())
                    
                    subject.selectPaymentViewController(paymentController,
                                                        didSelectPaymentMethod: paymentMethod,
                                                        controllerType: .PickForRide)
                    
                    expect(subject.selectedPaymentMethod).to(equal(paymentMethod))
                }
            }

            // TODO: Network call tests for onBidButtonClick
            
            // TODO: UI test for Pickup, dropoff markers set
            
            // TODO: UI test for onCenterMarkersButtonClick
            
            // TODO: UI test for MainViewController launch
            
            // TODO: Network failures simulate and click all buttons - bid, side button, etc
        }
    }
}
