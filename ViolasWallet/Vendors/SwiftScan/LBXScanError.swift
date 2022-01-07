//
//  LBXScanError.swift
//  swiftScan
//
//  Created by palliums on 2019/9/10.
//  Copyright © 2019 xialibing. All rights reserved.
//

import UIKit

public enum LBXScanError: Error {
    case error(String)
    public enum AuthorizePhotoFailedReason {
        // User has not yet made a choice with regards to this application
        case notDetermined
        // This application is not authorized to access photo data.
        case restricted
        // User has explicitly denied this application access to photos data.
        case denied
    }
    case AuthorizePhotoError(reason: AuthorizePhotoFailedReason)
}
extension LBXScanError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .error(let string):
            return "\(string)"
        case .AuthorizePhotoError(reason: let reason):
            return reason.localizedDescription
        }
    }
}
extension LBXScanError.AuthorizePhotoFailedReason {
    var localizedDescription: String {
        switch self {
        case .notDetermined:
            return "User has not yet made a choice with regards to this application"
        case .restricted:
            return "This application is not authorized to access photo data."
        case .denied:
            return "User has explicitly denied this application access to photos data."
        }
    }
}
