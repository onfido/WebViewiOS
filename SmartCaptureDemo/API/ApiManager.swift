//
//  ApiManager.swift
//
//  Copyright © 2016-2024 Onfido. All rights reserved.
//

import UIKit

final class ApiManager {
    typealias NetworkResponse = (data: Data, response: URLResponse)

    // MARK: - Properties

    enum Constants {
        static let baseURL = "https://api.onfido.com/"
    }

    static let shared = ApiManager()

    private let session: URLSession = .shared
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Internal API

    func getData<D: Decodable>(from endpoint: ApiEndpoint) async throws -> D {
        let request = try createRequest(from: endpoint)
        let networkResponse: NetworkResponse = try await session.data(for: request)
        guard let response = networkResponse.response as? HTTPURLResponse else { throw ApiManagerError.serverError }
        
        let statusCode = response.statusCode
        switch statusCode {
        case 200 ... 299:
            return try decoder.decode(D.self, from: networkResponse.data)
        default:
            throw ApiManagerError.urlError(statuscode: statusCode)
        }
    }

    // MARK: - Private API

    private func createRequest(from endpoint: ApiEndpoint) throws -> URLRequest {
        /// Ensure an `Env.xcconfig` with respective variables are added. See README for more details.
        let apiToken = EnvironmentVars.apiKey
        let workflowId = EnvironmentVars.workflowID

        let parameters: [String: String]
        switch endpoint {
        case .applicantApi:
            parameters = [
                "first_name": "John",
                "last_name": "Doe",
                "email": "john.doe@gmail.com"
            ]
        case let .sdkTokenApi(id):
            parameters = [
                "applicant_id": "\(id)"
            ]
        case let .workFlowRunApi(id):
            guard let workflowId else {
                fatalError("Workflow ID must be added in Env.xcconfig file. See README for more details.")
            }
            parameters = [
                "applicant_id": "\(id)",
                "workflow_id": "\(workflowId)"
            ]
        }

        let urlString = "\(Constants.baseURL)\(endpoint.path)"
        guard let url = URL(string: urlString) else { throw ApiManagerError.invalidRequestURL }

        var request = URLRequest(url: url)
        request.setValue("Token token=\(apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        let data = try encoder.encode(parameters)
        request.httpBody = data

        return request
    }
}
