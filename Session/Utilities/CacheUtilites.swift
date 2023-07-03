// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class CacheUtilites : NSObject{
    static let shared = CacheUtilites()
    
    static let kLocalSeed = "localSeed"
    
    var localSeed : String?{
        get{
            let seed = UserDefaults.standard.value(forKey: CacheUtilites.kLocalSeed) as? String
            return seed
        }
        set{
            UserDefaults.standard.setValue(true, forKey: "isNewAdd")
            UserDefaults.standard.setValue(newValue, forKey: CacheUtilites.kLocalSeed)
            UserDefaults.standard.synchronize()
        }
    }
    
}
