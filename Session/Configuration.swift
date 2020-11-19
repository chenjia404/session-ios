import SessionMessagingKit
import SessionProtocolKit
import SessionSnodeKit

@objc(SNConfiguration)
final class Configuration : NSObject {

    @objc static func performMainSetup() {
        SNMessagingKit.configure(
            storage: Storage.shared,
            messageReceiverDelegate: MessageReceiverDelegate.shared,
            signalStorage: OWSPrimaryStorage.shared(),
            identityKeyStore: OWSIdentityManager.shared(),
            sessionRestorationImplementation: SessionRestorationImplementation(),
            certificateValidator: SMKCertificateDefaultValidator(trustRoot: OWSUDManagerImpl.trustRoot()),
            openGroupAPIDelegate: OpenGroupAPIDelegate.shared,
            pnServerURL: PushNotificationManager.server,
            pnServerPublicKey: PushNotificationManager.serverPublicKey
        )
        SessionProtocolKit.configure(storage: Storage.shared, sharedSenderKeysDelegate: MessageSenderDelegate.shared)
        SessionSnodeKit.configure(storage: Storage.shared)
    }
}
