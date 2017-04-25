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
import PortalView

final class VoicesCommandExecutor: CommandExecutor {
    
    private let twitterService = TwitterService()
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: configuration)
    }()
    
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
            
        case .fetchUsersAvatar(let avatarsByUserId):
            for (userId, avatarURL) in avatarsByUserId {
                let request = URLRequest(url: avatarURL)
                session.reactive.data(with: request).startWithResult { result in
                    switch result {
                    case .success(let data, _):
                        if let image = UIImage(data: data) {
                            let avatar = UIImageContainer(image: image)
                            dispatch(.sendMessage(.userAvatarFetched(userId: userId, avatar: avatar)))
                        } else {
                            print("VoicesCommandExecutor - Invalid image format for avatar '\(avatarURL.absoluteString)' for user '\(userId)'")
                        }
                        
                    case .failure(_):
                        print("VoicesCommandExecutor - Error fetching avatar '\(avatarURL.absoluteString)' for user '\(userId)'")
                    }
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
