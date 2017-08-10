//
//  MarketInfoAPI.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import Foundation
import Moya

// MARK: - Networking Provider

/**
    The application uses the dependency 'Moya' for all network requests.
    See the official [documentation](https://github.com/Moya/Moya) on how it works.
 */
let MarketInfoProvider = MoyaProvider<MarketInfo>(endpointClosure: { (target: MarketInfo) -> Endpoint<MarketInfo> in
    let url = target.baseURL.appendingPathComponent(target.path).absoluteString
    let endpoint: Endpoint<MarketInfo> = Endpoint<MarketInfo>(url: url, sampleResponseClosure: { .networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters, parameterEncoding: target.parameterEncoding, httpHeaderFields: target.headers)
    return endpoint
})

// MARK: - Networking Routes

enum MarketInfo {
    case xemPrice, btcPrice
}

extension MarketInfo: TargetType {
    
    var baseURL: URL {
        switch self {
        case .xemPrice:
            return URL(string: "https://poloniex.com")!
        case .btcPrice:
            return URL(string: "https://blockchain.info")!
        }
    }
    var path: String {
        switch self {
        case .xemPrice:
            return "/public"
        case .btcPrice:
            return "/ticker"
        }
    }
    var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }
    var parameters: [String: Any]? {
        switch self {
        case .xemPrice:
            return ["command": "returnTicker"]
        default:
            return [:]
        }
    }
    var parameterEncoding: Moya.ParameterEncoding {
        switch self {
        default:
            return URLEncoding.default
        }
    }
    var headers: [String: String] {
        switch self {
        default:
            return [:]
        }
    }
    var task: Task {
        return .request
    }
    var sampleData: Data {
        switch self {
        default:
            return "{\"data\":[]}".UTF8EncodedData as Data
        }
    }
}
