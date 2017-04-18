//
//  Effects.swift
//  Voices
//
//  Created by Guido Marucci Blas on 4/17/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import PortalApplication

final class VoicesCommandExecutor: CommandExecutor {
    
    public func execute(command: Voices.Command, dispatch: @escaping (Voices.Action) -> Void) {
        
    }

    
}

final class VoicesSubscriptionManager: SubscriptionManager {
    
    public func add(subscription: Voices.Subscription, dispatch: @escaping (Voices.Action) -> Void) {
        
    }
    
    public func remove(subscription: Voices.Subscription) {
        
    }
    
}
