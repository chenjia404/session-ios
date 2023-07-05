import Foundation
import PromiseKit
public enum HTTP {
    private static let seedNodeURLSessionDelegate = SeedNodeURLSessionDelegateImplementation()
    private static let snodeURLSessionDelegate = SnodeURLSessionDelegateImplementation()

    // MARK: Certificates
    
    /// **Note:** These certificates will need to be regenerated and replaced at the start of April 2025, iOS has a restriction after iOS 13
    /// where certificates can have a maximum lifetime of 825 days (https://support.apple.com/en-au/HT210176) as a result we
    /// can't use the 10 year certificates that the other platforms use
    private static let storageSeed1Cert: SecCertificate = {
        let path = Bundle.main.path(forResource: "seed1-2023-2y", ofType: "der")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        return SecCertificateCreateWithData(nil, data as CFData)!
    }()

    private static let storageSeed2Cert: SecCertificate = {
        let path = Bundle.main.path(forResource: "seed2-2023-2y", ofType: "der")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        return SecCertificateCreateWithData(nil, data as CFData)!
    }()

    private static let storageSeed3Cert: SecCertificate = {
        let path = Bundle.main.path(forResource: "seed3-2023-2y", ofType: "der")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        return SecCertificateCreateWithData(nil, data as CFData)!
    }()
    
    // MARK: Settings
    public static let timeout: TimeInterval = 10

    // MARK: Seed Node URL Session Delegate Implementation
    private final class SeedNodeURLSessionDelegateImplementation : NSObject, URLSessionDelegate {

        func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            guard let trust = challenge.protectionSpace.serverTrust else {
                return completionHandler(.cancelAuthenticationChallenge, nil)
            }
            // Mark the seed node certificates as trusted
            let certificates = [ storageSeed1Cert, storageSeed2Cert, storageSeed3Cert]
            guard SecTrustSetAnchorCertificates(trust, certificates as CFArray) == errSecSuccess else {
                SNLog("Failed to set seed node certificates.")
                return completionHandler(.cancelAuthenticationChallenge, nil)
            }
            
            // Check that the presented certificate is one of the seed node certificates
            var error: CFError?
            guard SecTrustEvaluateWithError(trust, &error) else {
                // Extract the result for further processing (since we are defaulting to `invalid` we
                // don't care if extracting the result type fails)
                var result: SecTrustResultType = .invalid
                _ = SecTrustGetTrustResult(trust, &result)
                
                switch result {
                    case .proceed, .unspecified:
                        /// Unspecified indicates that evaluation reached an (implicitly trusted) anchor certificate without any evaluation
                        /// failures, but never encountered any explicitly stated user-trust preference. This is the most common return
                        /// value. The Keychain Access utility refers to this value as the "Use System Policy," which is the default user setting.
                        return completionHandler(.useCredential, URLCredential(trust: trust))
                    
                    case .recoverableTrustFailure:
                        /// A recoverable failure generally suggests that the certificate was mostly valid but something minor didn't line up,
                        /// while we don't want to recover in this case it's probably a good idea to include the reason in the logs to simplify
                        /// debugging if it does end up happening
                        let reason: String = {
                            guard
                                let validationResult: [String: Any] = SecTrustCopyResult(trust) as? [String: Any],
                                let details: [String: Any] = (validationResult["TrustResultDetails"] as? [[String: Any]])?
                                    .reduce(into: [:], { result, next in next.forEach { result[$0.key] = $0.value } })
                            else { return "Unknown" }

                            return "\(details)"
                        }()
                        
                        SNLog("Failed to validate a seed certificate with a recoverable error: \(reason)")
                        return completionHandler(.cancelAuthenticationChallenge, nil)
                        
                    default:
                        SNLog("Failed to validate a seed certificate with an unrecoverable error.")
                        return completionHandler(.cancelAuthenticationChallenge, nil)
                }
            }
            
            return completionHandler(.useCredential, URLCredential(trust: trust))
        }
    }
    
    // MARK: Snode URL Session Delegate Implementation
    private final class SnodeURLSessionDelegateImplementation : NSObject, URLSessionDelegate {

        func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            // Snode to snode communication uses self-signed certificates but clients can safely ignore this
            completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        }
    }

    // MARK: - Verb
    
    public enum Verb: String, Codable {
        case get = "GET"
        case put = "PUT"
        case post = "POST"
        case delete = "DELETE"
    }

    // MARK: - Error
    
    public enum Error: LocalizedError, Equatable {
        case generic
        case invalidURL
        case invalidJSON
        case parsingFailed
        case invalidResponse
        case maxFileSizeExceeded
        case httpRequestFailed(statusCode: UInt, data: Data?)
        case timeout
        
        public var errorDescription: String? {
            switch self {
                case .generic: return "An error occurred."
                case .invalidURL: return "Invalid URL."
                case .invalidJSON: return "Invalid JSON."
                case .parsingFailed, .invalidResponse: return "Invalid response."
                case .maxFileSizeExceeded: return "Maximum file size exceeded."
                case .httpRequestFailed(let statusCode, _): return "HTTP request failed with status code: \(statusCode)."
                case .timeout: return "The request timed out."
            }
        }
    }

    // MARK: - Main
    
    public static func execute(_ verb: Verb, _ url: String, timeout: TimeInterval = HTTP.timeout, useSeedNodeURLSession: Bool = false) -> Promise<Data> {
        return execute(verb, url, body: nil, timeout: timeout, useSeedNodeURLSession: useSeedNodeURLSession)
    }

    public static func execute(_ verb: Verb, _ url: String, parameters: JSON?, timeout: TimeInterval = HTTP.timeout, useSeedNodeURLSession: Bool = false) -> Promise<Data> {
        if let parameters = parameters {
            do {
                guard JSONSerialization.isValidJSONObject(parameters) else { return Promise(error: Error.invalidJSON) }
                let body = try JSONSerialization.data(withJSONObject: parameters, options: [ .fragmentsAllowed ])
                return execute(verb, url, body: body, timeout: timeout, useSeedNodeURLSession: useSeedNodeURLSession)
            }
            catch (let error) {
                return Promise(error: error)
            }
        }
        else {
            return execute(verb, url, body: nil, timeout: timeout, useSeedNodeURLSession: useSeedNodeURLSession)
        }
    }

    public static func execute(_ verb: Verb, _ url: String, body: Data?, timeout: TimeInterval = HTTP.timeout, useSeedNodeURLSession: Bool = false) -> Promise<Data> {
        
        var url = url
        var o_host = ""
        
        let localUseHttpsProxy = UserDefaults.standard.bool(forKey: "localUseHttpsProxy")
        if localUseHttpsProxy, let customUrl = UserDefaults.standard.string(forKey: "localHttpsProxy"),customUrl.count > 10{
            var host = url.components(separatedBy: "//").last?.components(separatedBy: "/") ?? []
            o_host = host.first ?? ""
            host[0] = customUrl
            url = host.joined(separator: "/")
        }
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = verb.rawValue
        request.httpBody = body
        request.timeoutInterval = timeout
        request.allHTTPHeaderFields?.removeValue(forKey: "User-Agent")
        request.setValue(o_host, forHTTPHeaderField: "o-host")
        request.setValue("WhatsApp", forHTTPHeaderField: "User-Agent") // Set a fake value
        request.setValue("en-us", forHTTPHeaderField: "Accept-Language") // Set a fake value
        
        
        let (promise, seal) = Promise<Data>.pending()
        let urlSession = useSeedNodeURLSession ? URLSession(configuration: ContentProxy.sessionCustomConfiguration(), delegate: seedNodeURLSessionDelegate, delegateQueue: nil) : URLSession(configuration: ContentProxy.sessionCustomConfiguration(), delegate: snodeURLSessionDelegate, delegateQueue: nil)
        let task = urlSession.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse else {
                if let error = error {
                    SNLog("\(verb.rawValue) request to \(url) failed due to error: \(error).")
                } else {
                    SNLog("\(verb.rawValue) request to \(url) failed.")
                }
                
                // Override the actual error so that we can correctly catch failed requests in sendOnionRequest(invoking:on:with:)
                switch (error as? NSError)?.code {
                    case NSURLErrorTimedOut: return seal.reject(Error.timeout)
                    default: return seal.reject(Error.httpRequestFailed(statusCode: 0, data: nil))
                }
                
            }
            if let error = error {
                SNLog("\(verb.rawValue) request to \(url) failed due to error: \(error).")
                // Override the actual error so that we can correctly catch failed requests in sendOnionRequest(invoking:on:with:)
                return seal.reject(Error.httpRequestFailed(statusCode: 0, data: data))
            }
            let statusCode = UInt(response.statusCode)

            guard 200...299 ~= statusCode else {
                var json: JSON? = nil
                if let processedJson: JSON = try? JSONSerialization.jsonObject(with: data, options: [ .fragmentsAllowed ]) as? JSON {
                    json = processedJson
                }
                else if let result: String = String(data: data, encoding: .utf8) {
                    json = [ "result": result ]
                }
                
                let jsonDescription: String = (json?.prettifiedDescription ?? "no debugging info provided")
                SNLog("\(verb.rawValue) request to \(url) failed with status code: \(statusCode) (\(jsonDescription)).")
                return seal.reject(Error.httpRequestFailed(statusCode: statusCode, data: data))
            }
            
            seal.fulfill(data)
        }
        task.resume()
        return promise
    }
}
