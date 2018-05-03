//
//  DefaultPermissionChecker.swift
//  FlintCore
//
//  Created by Marc Palmer on 01/05/2018.
//  Copyright © 2018 Montana Floss Co. Ltd. All rights reserved.
//

import Foundation

/// The implementation of the system permission checker.
///
/// This registers and verifies the approprite adapaters and uses them to check the status
/// of all the permissions required by a feature.
///
/// !!! TODO: Add sanity check for missing Info.plist usage descriptions?
public class DefaultPermissionChecker: SystemPermissionChecker, CustomDebugStringConvertible {
    private let permissionAdapters: [SystemPermission:SystemPermissionAdapter]
    
    public init() {
        var permissionAdapters: [SystemPermission:SystemPermissionAdapter] = [:]

        func _add(_ adapter: SystemPermissionAdapter) {
            permissionAdapters[adapter.permission] = adapter
        }
        
#if canImport(AVFoundation)
        _add(CameraPermissionAdapter())
#endif
#if canImport(Photos)
        _add(PhotosPermissionAdapter())
#endif
#if canImport(CoreLocation)
        _add(LocationPermissionAdapter(usage: .whenInUse))
        _add(LocationPermissionAdapter(usage: .always))
#endif

        self.permissionAdapters = permissionAdapters
    }

    public func isAuthorised(for permissions: Set<SystemPermission>) -> Bool {
        var result = false
        for permission in permissions {
            if status(of: permission) != .authorized {
                result = false
                break
            } else {
                result = true
            }
        }
        return result
    }
    
    public func status(of permission: SystemPermission) -> SystemPermissionStatus {
        guard let adapter = permissionAdapters[permission] else {
            fatalError("No permission adapter for \(permission)")
        }
        return adapter.status
    }
    
    public func requestAuthorization(for permission: SystemPermission) {
        guard let adapter = permissionAdapters[permission] else {
            fatalError("No permission adapter for \(permission)")
        }
        adapter.requestAuthorisation()
    }

    public var debugDescription: String {
        let results = permissionAdapters.values.map { adapter in
            return "\(adapter.permission): \(adapter.status)"
        }
        return "Current permission statuses:\n\(results.joined(separator: "\n"))"
    }
}