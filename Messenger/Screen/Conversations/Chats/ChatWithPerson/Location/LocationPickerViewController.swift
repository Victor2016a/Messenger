//
//  LocationPickerViewController.swift
//  Messenger
//
//  Created by Victor Vieira on 26/07/22.
//

import UIKit
import CoreLocation
import MapKit

class LocationPickerViewController: UIViewController {
  private let locationView = LocationView()
  var completion: ((CLLocationCoordinate2D) -> Void)?
  private var coordinates: CLLocationCoordinate2D?
  private var isPickable: Bool
  
  init(coordinates: CLLocationCoordinate2D?, isPickable: Bool) {
    self.coordinates = coordinates
    self.isPickable = isPickable
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    super.loadView()
    view = locationView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigation()
  }
  
  private func setupNavigation(){
    view.backgroundColor = .systemBackground
    
    if isPickable {
      navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send",
                                                          style: .done,
                                                          target: self,
                                                          action: #selector(sendTapButton))
      locationView.mapView.isUserInteractionEnabled = true
      
      let gesture = UITapGestureRecognizer(target: self,
                                           action: #selector(didTapMap(_:)))
      
      gesture.numberOfTouchesRequired = 1
      gesture.numberOfTapsRequired = 1
      locationView.mapView.addGestureRecognizer(gesture)
      
    } else {
      guard let coordinates = coordinates else { return }
      let pin = MKPointAnnotation()
      pin.coordinate = coordinates
      locationView.mapView.addAnnotation(pin)
    }
  }
  
  @objc private func sendTapButton() {
    guard let coordinates = coordinates else { return }
    
    navigationController?.popViewController(animated: true)
    completion?(coordinates)
  }
  
  @objc private func didTapMap(_ gesture: UITapGestureRecognizer) {
    let locationInView = gesture.location(in: locationView.mapView)
    let coordinates = locationView.mapView.convert(locationInView, toCoordinateFrom: locationView.mapView)
    self.coordinates = coordinates
    
    for annotation in locationView.mapView.annotations {
      locationView.mapView.removeAnnotation(annotation)
    }
    
    let pin = MKPointAnnotation()
    pin.coordinate = coordinates
    locationView.mapView.addAnnotation(pin)
  }
}
