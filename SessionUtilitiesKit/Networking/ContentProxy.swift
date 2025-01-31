//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import AFNetworking
import Foundation
@objc
public class ContentProxy: NSObject {

    @available(*, unavailable, message:"do not instantiate this class.")
    private override init() {
    }

    @objc
    public class func sessionConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.ephemeral
        let proxyHost = "contentproxy.signal.org"
        let proxyPort = 443
        configuration.connectionProxyDictionary = [
            "HTTPEnable": 1,
            "HTTPProxy": proxyHost,
            "HTTPPort": proxyPort,
            "HTTPSEnable": 1,
            "HTTPSProxy": proxyHost,
            "HTTPSPort": proxyPort
        ]
        return configuration
    }
    
    @objc
    public class func sessionCustomConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.ephemeral
        
        let localUseSocks5Proxy = UserDefaults.standard.bool(forKey: "localUseSocks5Proxy")
        if localUseSocks5Proxy, let socks5Proxy = UserDefaults.standard.string(forKey: "localSocks5Proxy"),socks5Proxy.count > 10 {
            let proxys = socks5Proxy.components(separatedBy: ":")
            let proxyHost = proxys.first ?? ""
            let proxyPort = proxys.last ?? ""
            
            configuration.connectionProxyDictionary = [
                kCFStreamPropertySOCKSProxyPort: proxyPort,
                kCFStreamPropertySOCKSProxyHost: proxyHost
            ]
        }
        
        return configuration
    }
    

    @objc
    public class func sessionManager(baseUrl baseUrlString: String?) -> AFHTTPSessionManager? {
        guard let baseUrlString = baseUrlString else {
            return AFHTTPSessionManager(baseURL: nil, sessionConfiguration: sessionConfiguration())
        }
        guard let baseUrl = URL(string: baseUrlString) else {
            return nil
        }
        let sessionManager = AFHTTPSessionManager(baseURL: baseUrl,
                                                  sessionConfiguration: sessionConfiguration())
        return sessionManager
    }

    @objc
    public class func jsonSessionManager(baseUrl: String) -> AFHTTPSessionManager? {
        guard let sessionManager = self.sessionManager(baseUrl: baseUrl) else {
            return nil
        }
        sessionManager.requestSerializer = AFJSONRequestSerializer()
        sessionManager.responseSerializer = AFJSONResponseSerializer()
        return sessionManager
    }

    static let userAgent = "Signal iOS (+https://signal.org/download)"

    public class func configureProxiedRequest(request: inout URLRequest) -> Bool {
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")

        padRequestSize(request: &request)

        guard let url = request.url,
        let scheme = url.scheme,
            scheme.lowercased() == "https" else {
                return false
        }
        return true
    }

    // This mutates the session manager state, so its the caller's obligation to avoid conflicts by:
    //
    // * Using a new session manager for each request.
    // * Pooling session managers.
    // * Using a single session manager on a single queue.
    @objc
    public class func configureSessionManager(sessionManager: AFHTTPSessionManager,
                                              forUrl urlString: String) -> Bool {

        guard let url = URL(string: urlString, relativeTo: sessionManager.baseURL) else {
            return false
        }

        var request = URLRequest(url: url)

        guard configureProxiedRequest(request: &request) else {
            return false
        }

        // Remove all headers from the request.
        for headerField in sessionManager.requestSerializer.httpRequestHeaders.keys {
            sessionManager.requestSerializer.setValue(nil, forHTTPHeaderField: headerField)
        }
        // Honor the request's headers.
        if let allHTTPHeaderFields = request.allHTTPHeaderFields {
            for (headerField, headerValue) in allHTTPHeaderFields {
                sessionManager.requestSerializer.setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }
        return true
    }

    public class func padRequestSize(request: inout URLRequest) {
        // Generate 1-64 chars of padding.
        let paddingLength: Int = 1 + Int(arc4random_uniform(64))
        let padding = self.padding(withLength: paddingLength)
        assert(padding.count == paddingLength)
        request.addValue(padding, forHTTPHeaderField: "X-SignalPadding")
    }

    private class func padding(withLength length: Int) -> String {
        // Pick a random ASCII char in the range 48-122
        var result = ""
        // Min and max values, inclusive.
        let minValue: UInt32 = 48
        let maxValue: UInt32 = 122
        for _ in 1...length {
            let value = minValue + arc4random_uniform(maxValue - minValue + 1)
            assert(value >= minValue)
            assert(value <= maxValue)
            result += String(UnicodeScalar(UInt8(value)))
        }
        return result
    }
}
