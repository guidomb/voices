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
        
        case fetchTimeline
        
    }
    
    enum Message {
        
        case applicationLaunched
        case routeChanged(to: Route)
        case timelineFetched(TwitterTimelineResponse)
        case twitterOperationFailure(TwitterOperationError)
        
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
    
    enum State {
        
        case idle
        case applicationStarted
        case failed(TwitterOperationError)
        case complete(tweets: [Tweet], users: [ObjectID<User> : User], avatars: [ObjectID<User> : Image])
        
    }
    
    public var initialState: State {
        return .idle
    }
    
    public var initialRoute: Route {
        return .main
    }
    
    public func translateRouteChange(from currentRoute: Route, to nextRoute: Route) -> Message? {
        return .routeChanged(to: nextRoute)
    }
    
    public func update(state: State, message: Message) -> (State, Command?)? {
        switch (state, message) {
        
        case (.idle, .applicationLaunched):
            return (.applicationStarted, .fetchTimeline)
        
        case (.applicationStarted, .timelineFetched(let result)):
            return (.complete(tweets: result.tweets, users: result.users, avatars: [:]), .none)
            
        case (.applicationStarted, .twitterOperationFailure(let error)):
            return (.failed(error), .none)
            
        default:
            return .none
        }
    }
    
    public func view(for state: State) -> View {
        switch state {
            
        case .applicationStarted:
            return View(
                navigator: .main,
                root: .stack(navigationBar(title: "Timeline")),
                component: label(
                    text: "Fetching timeline ...",
                    style: labelStyleSheet() { base, label in
                        label.textColor = .white
                    }
                )
            )
            
        case .complete(let tweets, let users, let avatars):
            return View(
                navigator: .main,
                root: .stack(navigationBar(title: "Timeline")),
                component: TimelineView.view(for: tweets, users: users, avatars: avatars)
            )
            
        case .failed(_):
            return View(
                navigator: .main,
                root: .stack(navigationBar(title: "Timeline")),
                alert: AlertProperties(
                    title: "Operation error",
                    text: "There was an error while fetching the timeline. Do you want to try again?",
                    primary: AlertProperties<Action>.Button(title: "No"),
                    secondary: AlertProperties<Action>.Button(title: "Yes")
                )
            )
            
        default:
            return View(
                navigator: .main,
                root: .stack(navigationBar(title: "Timeline")),
                component: container()
            )
        }
        
        
    }
    
    public func subscriptions(for state: State) -> [ApplicationSubscription] {
        return []
    }
    
}

private extension Voices {
    
    func navigationBar(title: String) -> NavigationBar<Action> {
        return PortalView.navigationBar(
            properties: properties() {
                $0.title = .text(title)
                $0.onBack = .navigateToPreviousRoute(preformTransition: false)
                $0.hideBackButtonTitle = true
            },
            style: navigationBarStyleSheet() { base, navBar in
                navBar.titleTextColor = .black
                navBar.isTranslucent = false
                navBar.tintColor = .black
                navBar.statusBarStyle = .default
                base.backgroundColor = .white
            }
        )
    }
    
}
