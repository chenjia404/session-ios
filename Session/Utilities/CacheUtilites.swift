// Copyright © 2023 Rangeproof Pty Ltd. All rights reserved.

import UIKit

class CacheUtilites : NSObject{
    static let shared = CacheUtilites()
    
    private static let kLocalSeed = "localSeed"
    
    private static let kLocalHttpsProxy = "localHttpsProxy"
    
    private static let kLocalUseHttpsProxy = "localUseHttpsProxy"
    
    private static let kLocalSocks5Proxy = "localSocks5Proxy"
    
    private static let kLocalUseSocks5Proxy = "localUseSocks5Proxy"
    
    
    
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
    
    
    var localHttpsProxy : String{
        get{
            let seed = UserDefaults.standard.value(forKey: CacheUtilites.kLocalHttpsProxy) as? String
            return seed ?? ""
        }
        set{
            UserDefaults.standard.setValue(newValue, forKey: CacheUtilites.kLocalHttpsProxy)
            UserDefaults.standard.synchronize()
        }
    }
    
    var useHttpsProxy : Bool{
        get{
            return UserDefaults.standard.bool(forKey: CacheUtilites.kLocalUseHttpsProxy)
        }
        set{
            
            UserDefaults.standard.setValue(newValue, forKey: CacheUtilites.kLocalUseHttpsProxy)
            UserDefaults.standard.synchronize()
        }
    }
    
    var localSocks5Proxy : String{
        get{
            let seed = UserDefaults.standard.value(forKey: CacheUtilites.kLocalSocks5Proxy) as? String
            return seed ?? ""
        }
        set{
            let value = newValue.components(separatedBy: "//").last
            UserDefaults.standard.setValue(value, forKey: CacheUtilites.kLocalSocks5Proxy)
            UserDefaults.standard.synchronize()
        }
    }
    
    var localUseSocks5Proxy : Bool{
        get{
            return UserDefaults.standard.bool(forKey: CacheUtilites.kLocalUseSocks5Proxy)
        }
        set{
            UserDefaults.standard.setValue(newValue, forKey: CacheUtilites.kLocalUseSocks5Proxy)
            UserDefaults.standard.synchronize()
        }
    }
    
}
