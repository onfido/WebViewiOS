//
//  Permissions.swift
//
//  Copyright © 2016-2025 Onfido. All rights reserved.
//

import AVFoundation

enum Permission {
    case microphone
    case camera
    case cameraAndMicrophone
}

enum PermissionAuthorisationStatus {
    case granted
    case denied
    case undetermined
    case restricted
}

protocol DevicePermissionProviding {
    func authStatus() -> PermissionAuthorisationStatus
    func requestPermission(response: @escaping (Bool) -> Void)
}

struct AudioSettingsPermission: DevicePermissionProviding {
    func authStatus() -> PermissionAuthorisationStatus {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)

        switch authorizationStatus {
        case .authorized:
            return .granted
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .notDetermined:
            return .undetermined
        @unknown default:
            return .undetermined
        }
    }

    func requestPermission(response: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            response(granted)
        }
    }
}

struct CameraPermission: DevicePermissionProviding {
    func authStatus() -> PermissionAuthorisationStatus {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

        switch authorizationStatus {
        case .authorized:
            return .granted
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .notDetermined:
            return .undetermined
        @unknown default:
            return .undetermined
        }
    }

    func requestPermission(response: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            response(granted)
        }
    }
}

struct PermissionsManager {
    private let audioPermission: AudioSettingsPermission
    private let cameraPermission: CameraPermission

    init() {
        audioPermission = AudioSettingsPermission()
        cameraPermission = CameraPermission()
    }

    public func permissionStatus(for permission: Permission) -> PermissionAuthorisationStatus {
        switch permission {
        case .microphone: return audioPermission.authStatus()
        case .camera: return cameraPermission.authStatus()
        case .cameraAndMicrophone:
            let cameraPermission = cameraPermission.authStatus()
            if cameraPermission == .granted {
                return audioPermission.authStatus()
            } else {
                return cameraPermission
            }
        }
    }

    public func request(_ permission: Permission, onComplete: @escaping (Bool) -> Void) {
        switch permission {
        case .microphone: audioPermission.requestPermission(response: onComplete)
        case .camera: cameraPermission.requestPermission(response: onComplete)
        case .cameraAndMicrophone:
            cameraPermission.requestPermission { granted in
                if granted {
                    audioPermission.requestPermission(response: onComplete)
                } else {
                    onComplete(false)
                }
            }
        }
    }
}
