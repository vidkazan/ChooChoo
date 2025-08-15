//
//  HTTPCLient.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 15.08.25.
//

import Foundation


struct HTTPClient {
    enum InternalErrorCode: Int {
        case requestException = -1
    }

    enum Method: String {
        case GET, POST
    }

    enum Header {
        case applicationJson

        var headerData: (value: String, field: String) {
            switch self {
                case .applicationJson: ("application/json", HTTPClient.Header.contentType)
            }
        }

        private static let contentType = "Content-Type"
    }

    enum RequestError: Error {
        case invalidURL
        case invalidResponse
        case requestException(Error)
        case failedEncoding
        case failedDecoding
        case somethingWrong(Error)
    }

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func execute<Response: Decodable>(
        endpoint: any ApiEndpoint,
        method: Method,
        body: (any Encodable)? = nil,
        token: String?
    ) async -> Result<Response, ResponseError> {
        do {
            let result: Result<Response, ResponseError> = try await request(
                endpoint: endpoint,
                method: method,
                body: body
            )
            return result
        } catch {
            print("### HTTPClient request error:", error)
            return .failure(
                .generic(description: error.localizedDescription)
            )
        }
    }

    private func request<Response: Decodable>(
        endpoint: any ApiEndpoint,
        method: Self.Method,
        body: (any Encodable)?
    ) async throws -> Result<Response, ResponseError> {
        guard let url = URL.init(string: endpoint.apiPath) else { throw RequestError.invalidURL }

        var request = URLRequest(url: url/*, cachePolicy: .reloadIgnoringLocalCacheData*/)
        request.httpMethod = method.rawValue
        request.timeoutInterval = 30

        if let requestBody = body {
            setHeader(request: &request, header: Header.applicationJson)
            do {
                let encoder = JSONEncoder()
//                encoder.keyEncodingStrategy = .convertToSnakeCase
                let bodyData = try encoder.encode(requestBody)
                request.httpBody = bodyData
                print(
                    """
                    ### httpRequest:
                    ### url: \(String(describing: request.url))
                    ### header: \(String(describing: request.allHTTPHeaderFields))

                    """
//                    ### requestBody: \(String(describing: String(data: bodyData, encoding: .utf8)))
                )
            } catch {
                throw RequestError.failedEncoding
            }
        }

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { throw RequestError.invalidResponse }
            print(
                """
                ### httpResponse:
                ### url: \(String(describing: httpResponse.url))
                ### code: \(httpResponse.statusCode)
                ### responseBody: \(String(describing: String(data: data, encoding: .utf8)))
                """
            )
            guard httpResponse.statusCode != 500 else { return .failure(ResponseError.internalServerError) }

            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase

            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decodedData = try decoder.decode(Response.self, from: data)
                    return .success(decodedData)
                } catch {
                    throw RequestError.failedDecoding
                }
            case 400:
                    return .failure(.badRequest)
            case 404:
                    return .failure(.notFound)
            case 429:
                return .failure(.requestRateExceeded)
            default:
                return .failure(
                    .generic(description: String(
                        data: data,
                        encoding: .utf8
                    ) ?? "")
                )
            }
        } catch {
            print("### HTTPClient catch error:", error)
            throw RequestError.requestException(error)
        }
    }

    private func setHeader(request: inout URLRequest, header: Header) {
        request.setValue(header.headerData.value, forHTTPHeaderField: header.headerData.field)
    }
}
