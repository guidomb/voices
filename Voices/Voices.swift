//
//  Voices.swift
//  Voices
//
//  Created by Guido Marucci Blas on 4/17/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import PortalApplication
import PortalView

final class Voices: Application {

    typealias Action = PortalApplication.Action<Route, Message>
    typealias View = PortalApplication.View<Route, Message, Navigator>
    typealias ApplicationSubscription = PortalApplication.Subscription<Message, Route, Subscription>
    
    enum Command {
        
    }
    
    enum Message {
        
        case applicationLaunched
        case routeChanged(to: Route)
        
    }
    
    enum Route: PortalApplication.Route {
        
        case main
        
        var previous: Route? {
            switch self {
            case .main:
                return .none
            }
        }
        
    }
    
    enum Navigator: PortalApplication.Navigator {
        
        case main
        
        var baseRoute: Route {
            switch self {
            case .main:
                return .main
            }
        }
        
    }
    
    enum Subscription: Equatable {
        
        static func ==(lhs: Subscription, rhs: Subscription) -> Bool {
            return true
        }
        
    }
    
    struct State {
        
    }
    
    public var initialState: State {
        return State()
    }
    
    public var initialRoute: Route {
        return .main
    }
    
    public func translateRouteChange(from currentRoute: Route, to nextRoute: Route) -> Message? {
        return .routeChanged(to: nextRoute)
    }
    
    public func update(state: State, message: Message) -> (State, Command?)? {
        return .none
    }
    
    public func view(for state: State) -> View {
        return View(
            navigator: .main,
            root: .simple,
            component: container()
        )
    }
    
    public func subscriptions(for state: State) -> [ApplicationSubscription] {
        return []
    }
    
}
