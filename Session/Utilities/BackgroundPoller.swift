import PromiseKit
import SessionSnodeKit

@objc(LKBackgroundPoller)
public final class BackgroundPoller: NSObject {
    private static var promises: [Promise<Void>] = []

    private override init() { }

    @objc(pollWithCompletionHandler:)
    public static func poll(completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        promises = []
            .appending(pollForMessages())
            .appending(pollForClosedGroupMessages())
            .appending(
                Set(Storage.shared.getAllOpenGroups().values.map { $0.server })
                    .map { server in
                        let poller = OpenGroupAPI.Poller(for: server)
                        poller.stop()
                        
                        return poller.poll(isBackgroundPoll: true)
                    }
            )
        
        when(resolved: promises)
            .done { _ in
                completionHandler(.newData)
            }
            .catch { error in
                SNLog("Background poll failed due to error: \(error)")
                completionHandler(.failed)
            }
    }
    
    private static func pollForMessages() -> Promise<Void> {
        let userPublicKey: String = getUserHexEncodedPublicKey()
        return getMessages(for: userPublicKey)
    }
    
    private static func pollForClosedGroupMessages() -> [Promise<Void>] {
        let publicKeys = Storage.shared.getUserClosedGroupPublicKeys()
        return publicKeys.map { getClosedGroupMessages(for: $0) }
    }
    
    private static func getMessages(for publicKey: String) -> Promise<Void> {
        return SnodeAPI.getSwarm(for: publicKey)
            .then(on: DispatchQueue.main) { swarm -> Promise<Void> in
                guard let snode = swarm.randomElement() else { throw SnodeAPI.Error.generic }
                
                return attempt(maxRetryCount: 4, recoveringOn: DispatchQueue.main) {
                    return SnodeAPI.getRawMessages(from: snode, associatedWith: publicKey)
                        .then(on: DispatchQueue.main) { rawResponse -> Promise<Void> in
                            let (messages, lastRawMessage) = SnodeAPI.parseRawMessagesResponse(rawResponse, from: snode, associatedWith: publicKey)
                            var processedMessages: [JSON] = []
                            let promises = messages
                                .compactMap { json -> Promise<Void>? in
                                    // Use a best attempt approach here; we don't want to fail
                                    // the entire process if one of the messages failed to parse
                                    guard let envelope = SNProtoEnvelope.from(json),  let data = try? envelope.serializedData() else {
                                        return nil
                                    }
                        
                                    let job = MessageReceiveJob(data: data, serverHash: json["hash"] as? String, isBackgroundPoll: true)
                                    processedMessages.append(json)
                        
                                    return job.execute()
                                }
                    
                            // Now that the MessageReceiveJob's have been created we can update
                            // the `lastMessageHash` value
                            SnodeAPI.updateLastMessageHashValueIfPossible(
                                for: snode,
                                namespace: SnodeAPI.defaultNamespace,
                                associatedWith: publicKey,
                                from: lastRawMessage
                            )
                            SnodeAPI.updateReceivedMessages(
                                from: processedMessages,
                                associatedWith: publicKey
                            )
                    
                            return when(fulfilled: promises) // The promise returned by MessageReceiveJob never rejects
                        }
                }
            }
    }
    
    private static func getClosedGroupMessages(for publicKey: String) -> Promise<Void> {
        return SnodeAPI.getSwarm(for: publicKey)
            .then(on: DispatchQueue.main) { swarm -> Promise<Void> in
                guard let snode = swarm.randomElement() else { throw SnodeAPI.Error.generic }
            
                return attempt(maxRetryCount: 4, recoveringOn: DispatchQueue.main) {
                    var promises: [Promise<Data>] = []
                    var namespaces: [Int] = []
                
                    // We have to poll for both namespace 0 and -10 when hardfork == 19 && softfork == 0
                    if SnodeAPI.hardfork <= 19, SnodeAPI.softfork == 0 {
                        let promise = SnodeAPI.getRawClosedGroupMessagesFromDefaultNamespace(from: snode, associatedWith: publicKey)
                        promises.append(promise)
                        namespaces.append(SnodeAPI.defaultNamespace)
                    }
                
                    if SnodeAPI.hardfork >= 19 && SnodeAPI.softfork >= 0 {
                        let promise = SnodeAPI.getRawMessages(from: snode, associatedWith: publicKey, authenticated: false)
                        promises.append(promise)
                        namespaces.append(SnodeAPI.closedGroupNamespace)
                    }
                
                    return when(resolved: promises)
                        .then(on: DispatchQueue.main) { results -> Promise<Void> in
                            var promises: [Promise<Void>] = []
                            var index = 0
                    
                            for result in results {
                                if case .fulfilled(let rawResponse) = result {
                                    let (messages, lastRawMessage) = SnodeAPI.parseRawMessagesResponse(rawResponse, from: snode, associatedWith: publicKey)
                                    var processedMessages: [JSON] = []
                                    let jobPromises = messages.compactMap { json -> Promise<Void>? in
                                
                                        // Use a best attempt approach here; we don't want to fail
                                        // the entire process if one of the messages failed to parse
                                        guard let envelope = SNProtoEnvelope.from(json), let data = try? envelope.serializedData() else {
                                            return nil
                                        }
                                
                                        let job = MessageReceiveJob(data: data, serverHash: json["hash"] as? String, isBackgroundPoll: true)
                                        processedMessages.append(json)
                                
                                        return job.execute()
                                    }
                                    
                                    // Now that the MessageReceiveJob's have been created we can
                                    // update the `lastMessageHash` value
                                    SnodeAPI.updateLastMessageHashValueIfPossible(
                                        for: snode,
                                        namespace: namespaces[index],
                                        associatedWith: publicKey,
                                        from: lastRawMessage
                                    )
                                    SnodeAPI.updateReceivedMessages(
                                        from: processedMessages,
                                        associatedWith: publicKey
                                    )
                            
                                    promises += jobPromises
                                }
                        
                                index += 1
                            }
                            
                            return when(fulfilled: promises) // The promise returned by MessageReceiveJob never rejects
                        }
                }
            }
    }
}
