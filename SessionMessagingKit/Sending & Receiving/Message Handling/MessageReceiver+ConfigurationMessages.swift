// Copyright © 2022 Rangeproof Pty Ltd. All rights reserved.

import Foundation
import GRDB
import Sodium
import SignalCoreKit
import SessionUtilitiesKit

extension MessageReceiver {
    internal static func handleConfigurationMessage(_ db: Database, message: ConfigurationMessage) throws {
        let userPublicKey = getUserHexEncodedPublicKey(db)
        
        guard message.sender == userPublicKey else { return }
        
        SNLog("Configuration message received.")
        
        // Note: `message.sentTimestamp` is in ms (convert to TimeInterval before converting to
        // seconds to maintain the accuracy)
        let isInitialSync: Bool = (!UserDefaults.standard[.hasSyncedInitialConfiguration])
        let messageSentTimestamp: TimeInterval = TimeInterval((message.sentTimestamp ?? 0) / 1000)
        let lastConfigTimestamp: TimeInterval = UserDefaults.standard[.lastConfigurationSync]
            .defaulting(to: Date(timeIntervalSince1970: 0))
            .timeIntervalSince1970
        
        // Profile
        try MessageReceiver.updateProfileIfNeeded(
            db,
            publicKey: userPublicKey,
            name: message.displayName,
            profilePictureUrl: message.profilePictureUrl,
            profileKey: OWSAES256Key(data: message.profileKey),
            sentTimestamp: messageSentTimestamp
        )
        
        if isInitialSync || messageSentTimestamp > lastConfigTimestamp {
            if isInitialSync {
                UserDefaults.standard[.hasSyncedInitialConfiguration] = true
                NotificationCenter.default.post(name: .initialConfigurationMessageReceived, object: nil)
            }
            
            UserDefaults.standard[.lastConfigurationSync] = Date(timeIntervalSince1970: messageSentTimestamp)
            
            // Contacts
            try message.contacts.forEach { contactInfo in
                guard let sessionId: String = contactInfo.publicKey else { return }
                
                let contact: Contact = Contact.fetchOrCreate(db, id: sessionId)
                let profile: Profile = Profile.fetchOrCreate(db, id: sessionId)
                
                try profile
                    .with(
                        name: contactInfo.displayName,
                        profilePictureUrl: .updateIf(contactInfo.profilePictureUrl),
                        profileEncryptionKey: .updateIf(
                            contactInfo.profileKey.map { OWSAES256Key(data: $0) }
                        )
                    )
                    .save(db)
                
                /// We only update these values if the proto actually has values for them (this is to prevent an
                /// edge case where an old client could override the values with default values since they aren't included)
                ///
                /// **Note:** Since message requests have no reverse, we should only handle setting `isApproved`
                /// and `didApproveMe` to `true`. This may prevent some weird edge cases where a config message
                /// swapping `isApproved` and `didApproveMe` to `false`
                try contact
                    .with(
                        isApproved: (contactInfo.hasIsApproved && contactInfo.isApproved ?
                            true :
                            .existing
                        ),
                        isBlocked: (contactInfo.hasIsBlocked ?
                            .update(contactInfo.isBlocked) :
                            .existing
                        ),
                        didApproveMe: (contactInfo.hasDidApproveMe && contactInfo.didApproveMe ?
                            true :
                            .existing
                        )
                    )
                    .save(db)
                
                // If the contact is blocked
                if contactInfo.hasIsBlocked && contactInfo.isBlocked {
                    // If this message changed them to the blocked state and there is an existing thread
                    // associated with them that is a message request thread then delete it (assume
                    // that the current user had deleted that message request)
                    if
                        contactInfo.isBlocked != contact.isBlocked, // 'contact.isBlocked' will be the old value
                        let thread: SessionThread = try? SessionThread.fetchOne(db, id: sessionId),
                        thread.isMessageRequest(db)
                    {
                        _ = try thread.delete(db)
                    }
                }
            }
            
            // Closed groups
            //
            // Note: Only want to add these for initial sync to avoid re-adding closed groups the user
            // intentionally left (any closed groups joined since the first processed sync message should
            // get added via the 'handleNewClosedGroup' method anyway as they will have come through in the
            // past two weeks)
            if isInitialSync {
                let existingClosedGroupsIds: [String] = (try? SessionThread
                    .filter(SessionThread.Columns.variant == SessionThread.Variant.closedGroup)
                    .fetchAll(db))
                    .defaulting(to: [])
                    .map { $0.id }
                
                try message.closedGroups.forEach { closedGroup in
                    guard !existingClosedGroupsIds.contains(closedGroup.publicKey) else { return }
                    
                    let keyPair: Box.KeyPair = Box.KeyPair(
                        publicKey: closedGroup.encryptionKeyPublicKey.bytes,
                        secretKey: closedGroup.encryptionKeySecretKey.bytes
                    )
                    
                    try MessageReceiver.handleNewClosedGroup(
                        db,
                        groupPublicKey: closedGroup.publicKey,
                        name: closedGroup.name,
                        encryptionKeyPair: keyPair,
                        members: [String](closedGroup.members),
                        admins: [String](closedGroup.admins),
                        expirationTimer: closedGroup.expirationTimer,
                        messageSentTimestamp: message.sentTimestamp!
                    )
                }
            }
            
            // Open groups
            for openGroupURL in message.openGroups {
                if let (room, server, publicKey) = OpenGroupManager.parseOpenGroup(from: openGroupURL) {
                    OpenGroupManager.shared
                        .add(db, roomToken: room, server: server, publicKey: publicKey, isConfigMessage: true)
                        .retainUntilComplete()
                }
            }
        }
    }
}
