//
//  API.swift
//
//  Copyright © 2016-2025 Onfido. All rights reserved.
//

import Foundation

/// Theme options for the Onfido SDK
public enum Theme: String, Encodable {
    case automatic = "AUTOMATIC"
    case light = "LIGHT"
    case dark = "DARK"
}

/// Localisation configuration for the Onfido SDK
public enum Localisation: Encodable {
    case standard(String) // e.g., "en_US", "es_ES"
    case custom(CustomLocalisation)

    public struct CustomLocalisation: Encodable {
        let locale: String // e.g., "en_US"
        let phrases: [String: String] // Custom translations

        public init(locale: String, phrases: [String: String]) {
            self.locale = locale
            self.phrases = phrases
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .standard(locale):
            try container.encode("standard", forKey: .type)
            try container.encode(locale, forKey: .value)
        case let .custom(custom):
            try container.encode("custom", forKey: .type)
            try container.encode(custom, forKey: .value)
        }
    }
}

/// Coding keys for Step protocol encoding
private enum StepCodingKeys: String, CodingKey {
    case type
}

/// Protocol for steps with type discriminator
public protocol Step: Encodable {
    var type: String { get }
}

public struct AnyStep: Encodable {
    private let _encode: (Encoder) throws -> Void
    public let base: any Step

    public init(_ step: some Step) {
        base = step
        _encode = { encoder in
            try step.encode(to: encoder)
        }
    }

    public func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

/// Document capture step configuration
public struct DocumentStep: Step {
    public let type = "document"
    public let options: DocumentOptions?

    public struct DocumentOptions: Encodable {
        public let documentTypes: [String: Bool]?
        public let country: String?
        public let hideCountrySelection: Bool?
        public let forceCrossDevice: Bool?
        public let useLiveDocumentCapture: Bool?
        public let uploadFallback: Bool?

        public init(
            documentTypes: [String: Bool]? = nil,
            country: String? = nil,
            hideCountrySelection: Bool? = nil,
            forceCrossDevice: Bool? = nil,
            useLiveDocumentCapture: Bool? = nil,
            uploadFallback: Bool? = nil
        ) {
            self.documentTypes = documentTypes
            self.country = country
            self.hideCountrySelection = hideCountrySelection
            self.forceCrossDevice = forceCrossDevice
            self.useLiveDocumentCapture = useLiveDocumentCapture
            self.uploadFallback = uploadFallback
        }
    }

    public init(options: DocumentOptions? = nil) {
        self.options = options
    }
}

/// Face capture step configuration
public struct FaceStep: Step {
    public let type = "face"
    public let options: FaceOptions?

    public struct FaceOptions: Encodable {
        public let variant: String
        public let showIntro: Bool?
        public let showConfirmation: Bool?
        public let manualVideoCapture: Bool?
        public let recordAudio: Bool?

        public init(
            variant: String,
            showIntro: Bool? = nil,
            showConfirmation: Bool? = nil,
            manualVideoCapture: Bool? = nil,
            recordAudio: Bool? = nil
        ) {
            self.variant = variant
            self.showIntro = showIntro
            self.showConfirmation = showConfirmation
            self.manualVideoCapture = manualVideoCapture
            self.recordAudio = recordAudio
        }
    }

    public init(options: FaceOptions? = nil) {
        self.options = options
    }
}

/// Welcome step configuration
public struct WelcomeStep: Step {
    public let type = "welcome"
    public let options: WelcomeOptions?

    public struct WelcomeOptions: Encodable {
        public let title: String?
        public let description: String?

        public init(title: String? = nil, description: String? = nil) {
            self.title = title
            self.description = description
        }
    }

    public init(options: WelcomeOptions? = nil) {
        self.options = options
    }
}

/// Proof of Address step configuration
public struct ProofOfAddressStep: Step {
    public let type = "proofOfAddress"
    public let options: ProofOfAddressOptions?

    public struct ProofOfAddressOptions: Encodable {
        public let country: String?

        public init(country: String? = nil) {
            self.country = country
        }
    }

    public init(options: ProofOfAddressOptions? = nil) {
        self.options = options
    }
}

/// Configuration for the Onfido Web SDK
public struct SdkParameters: Encodable {
    public let token: String
    public let workflowRunId: String?
    public let steps: [AnyStep]?

    private enum CodingKeys: String, CodingKey {
        case token
        case workflowRunId
        case steps
    }

    public init(
        token: String,
        workflowRunId: String? = nil,
        steps: [Step]? = nil
    ) {
        self.token = token
        self.workflowRunId = workflowRunId
        self.steps = steps?.map { AnyStep($0) }
    }
}
