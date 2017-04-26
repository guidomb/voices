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
        case fetchUsersAvatar([(ObjectID<User>, URL)])
        
    }
    
    enum Message {
        
        case applicationLaunched
        case routeChanged(to: Route)
        case timelineFetched(TwitterTimelineResponse)
        case userAvatarFetched(userId: ObjectID<User>, avatar: Image)
        case twitterOperationFailure(TwitterOperationError)
        
    }
    
    enum Route: PortalApplication.Route {
        
        static func ==(lhs: Route, rhs: Route) -> Bool {
            switch (lhs, rhs) {
            case (.timeline, timeline):
                return true
            case (.detail(let a), .detail(let b)):
                return a == b
            default:
                return false
            }
        }
        
        case timeline
        case detail(ObjectID<Tweet>)
        
        var previous: Route? {
            switch self {
            case .timeline:
                return .none
            case .detail(_):
                return .timeline
            }
        }
        
    }
    
    enum Navigator: PortalApplication.Navigator {
        
        case main
        
        var baseRoute: Route {
            switch self {
            case .main:
                return .timeline
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
        case complete(CompleteState)
        
    }
    
    struct CompleteState {
        
        var tweets: [Tweet]
        var users: [ObjectID<User> : User]
        var avatars: [ObjectID<User> : Image]
        var currentRoute: Route
        
    }
    
    public var initialState: State {
        return .idle
    }
    
    public var initialRoute: Route {
        return .timeline
    }
    
    public func translateRouteChange(from currentRoute: Route, to nextRoute: Route) -> Message? {
        return .routeChanged(to: nextRoute)
    }
    
    public func update(state: State, message: Message) -> (State, Command?)? {
        switch (state, message) {
        
        case (.idle, .applicationLaunched):
            return (.applicationStarted, .fetchTimeline)
        
        case (.applicationStarted, .timelineFetched(let result)):
            let command = Command.fetchUsersAvatar(result.users.values.map { ($0.id, $0.avatar) })
            let nextState = CompleteState(
                tweets: result.tweets,
                users: result.users,
                avatars: [:],
                currentRoute: .timeline
            )
            return (.complete(nextState), command)
            
        case (.applicationStarted, .twitterOperationFailure(let error)):
            return (.failed(error), .none)
            
        case (.complete(var completeState), .userAvatarFetched(let userId, let avatar)):
            completeState.avatars[userId] = avatar
            return (.complete(completeState), .none)
            
        case (.complete(var completeState), .routeChanged(let nextRoute)):
            completeState.currentRoute = nextRoute
            return (.complete(completeState), .none)
            
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
                        label.textAligment = .center
                    },
                    layout: layout() {
                        $0.flex = flex() {
                            $0.grow = .one
                        }
                        $0.justifyContent = .center
                    }
                )
            )
            
        case .complete(let completeState):
            switch completeState.currentRoute {

            case .timeline:
                return View(
                    navigator: .main,
                    root: .stack(navigationBar(title: "Timeline")),
                    component: TimelineView.view(
                        tweets: completeState.tweets,
                        users: completeState.users,
                        avatars: completeState.avatars
                    )
                )
            
            case .detail(let tweetId):
                if  let tweet = completeState.tweets.first(where: { $0.id == tweetId }),
                    let user = completeState.users[tweet.createdBy] {
                    
                    let avatar = completeState.avatars[user.id]
                    let renderableTweet = TweetView.RenderableTweet.forTweet(tweet, user: user, avatar: avatar)
                    return View(
                        navigator: .main,
                        root: .stack(navigationBar(title: "Tweet")),
                        component: container(
                            children: [
                                TweetView.view(for: renderableTweet)
                            ],
                            style: styleSheet() {
                                $0.backgroundColor = .white
                            },
                            layout: layout() {
                                $0.flex = flex() {
                                    $0.grow = .one
                                }
                            }
                        )
                    )
                } else {
                    return View(
                        navigator: .main,
                        root: .stack(navigationBar(title: "Tweet")),
                        component: label(
                            text: "Invalid tweet id!",
                            style: labelStyleSheet() { base, label in
                                label.textColor = .white
                                label.textAligment = .center
                            },
                            layout: layout() {
                                $0.flex = flex() {
                                    $0.grow = .one
                                }
                                $0.justifyContent = .center
                            }
                        )
                    )
                }
            }
            
            
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
                component: label(
                    text: "Unsupported transition!",
                    style: labelStyleSheet() { base, label in
                        label.textColor = .white
                        label.textAligment = .center
                    },
                    layout: layout() {
                        $0.flex = flex() {
                            $0.grow = .one
                        }
                        $0.justifyContent = .center
                    }
                )
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
