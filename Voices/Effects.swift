//
//  Effects.swift
//  Voices
//
//  Created by Guido Marucci Blas on 4/17/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import PortalApplication
import Social
import Accounts

final class VoicesCommandExecutor: CommandExecutor {
    
    let twitterService = TwitterService()
    
    public func execute(command: Voices.Command, dispatch: @escaping (Voices.Action) -> Void) {
        switch command {
            
        case .fetchTimeline:
            twitterService.fetchTimeline().startWithResult { result in
                switch result {
                case .success(let timelineResponse):
                    dispatch(.sendMessage(.timelineFetched(timelineResponse)))
                case .failure(let error):
                    dispatch(.sendMessage(.twitterOperationFailure(error)))
                }
            }
            
        }
    }

    
}

final class VoicesSubscriptionManager: SubscriptionManager {
    
    public func add(subscription: Voices.Subscription, dispatch: @escaping (Voices.Action) -> Void) {
        
    }
    
    public func remove(subscription: Voices.Subscription) {
        
    }
    
}
