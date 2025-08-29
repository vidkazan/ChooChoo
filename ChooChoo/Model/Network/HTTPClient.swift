//
//  HTTPCLient.swift
//  ChooChoo
//
//  Created by Dmitrii Grigorev on 15.08.25.
//

import Foundation


protocol HTTPClient {
    func execute<Response: Codable>(
        url: URL,
        body: (any Encodable)?
    ) async -> Result<Response, ResponseError>
}
