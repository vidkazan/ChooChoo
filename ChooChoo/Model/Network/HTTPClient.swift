//
//  HTTPCLient.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 15.08.25.
//

import Foundation


protocol HTTPClient {
    func execute<Response: Decodable>(
        endpoint: any ApiEndpoint,
        method: HttpMethod,
        body: (any Encodable)?
    ) async -> Result<Response, ResponseError>
}

enum HttpMethod: String {
    case GET, POST
}
