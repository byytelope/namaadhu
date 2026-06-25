import CoreLocation

final class CurrentLocationService: NSObject, CLLocationManagerDelegate {
  private let manager = CLLocationManager()
  private var completion: ((Result<CLLocation, Error>) -> Void)?

  override init() {
    super.init()
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyKilometer
  }

  func requestLocation(
    completion: @escaping (Result<CLLocation, Error>) -> Void
  ) {
    self.completion = completion

    switch manager.authorizationStatus {
    case .notDetermined:
      manager.requestWhenInUseAuthorization()
    case .authorizedAlways, .authorizedWhenInUse:
      manager.requestLocation()
    case .denied, .restricted:
      finish(with: .failure(CurrentLocationError.permissionDenied))
    @unknown default:
      finish(with: .failure(CurrentLocationError.unavailable))
    }
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    guard completion != nil else { return }

    switch manager.authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      manager.requestLocation()
    case .denied, .restricted:
      finish(with: .failure(CurrentLocationError.permissionDenied))
    case .notDetermined:
      break
    @unknown default:
      finish(with: .failure(CurrentLocationError.unavailable))
    }
  }

  func locationManager(
    _ manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation]
  ) {
    guard let location = locations.last else {
      finish(with: .failure(CurrentLocationError.unavailable))
      return
    }

    finish(with: .success(location))
  }

  func locationManager(
    _ manager: CLLocationManager,
    didFailWithError error: Error
  ) {
    if let locationError = error as? CLError, locationError.code == .denied {
      let result: CurrentLocationError =
        switch manager.authorizationStatus {
        case .denied, .restricted:
          .permissionDenied
        default:
          .servicesDisabled
        }

      finish(with: .failure(result))
      return
    }

    finish(with: .failure(error))
  }

  private func finish(with result: Result<CLLocation, Error>) {
    let completion = completion
    self.completion = nil
    completion?(result)
  }
}

private enum CurrentLocationError: LocalizedError {
  case permissionDenied
  case servicesDisabled
  case unavailable

  var errorDescription: String? {
    switch self {
    case .permissionDenied:
      "Location access is denied. Allow access in Settings to use your current location."
    case .servicesDisabled:
      "Location Services are turned off on this device."
    case .unavailable:
      "Your current location could not be determined."
    }
  }
}
