// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import Foundation
import WalletCore
import SessionUtilitiesKit

public class WalletUtilities{
    
    public static var address = ""
    
    static func saveAddress(){
        if let seed = Identity.fetchHexEncodedSeed() {
            let mnemonic = Mnemonic.encode(entropy: seed)
            let wallet = HDWallet(mnemonic: mnemonic, passphrase: "")
            let address = wallet?.getAddressForCoin(coin: .ethereum)
            self.address = address ?? ""
            return
        }

        // Legacy account
        let mnemonic = Mnemonic.encode(entropy: Identity.fetchUserPrivateKey()!)
        let wallet = HDWallet(mnemonic: mnemonic, passphrase: "")
        let address = wallet?.getAddressForCoin(coin: .ethereum)
        self.address = address ?? ""
    }
}
