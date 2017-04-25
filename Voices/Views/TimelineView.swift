//
//  TimelineView.swift
//  Voices
//
//  Created by Guido Marucci Blas on 4/24/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation
import PortalView

struct TimelineView {
    
    static let defaultAvatar = UIImageContainer.loadImage(named: "default_avatar.png")!
    
    static func view(for tweets: [Tweet], users: [ObjectID<User> : User], avatars: [ObjectID<User> : Image]) -> Component<Voices.Action> {
        var items: [TableItemProperties<Voices.Action>] = []
        items.reserveCapacity(tweets.count)
        
        for tweet in tweets {
            guard let user = users[tweet.createdBy] else { continue }
            
            let renderableTweet = TweetView.RenderableTweet(
                text: tweet.text,
                createdAt: tweet.createdAt,
                place: tweet.place,
                userName: user.name,
                userSlug: user.slug,
                userAvatar: avatars[user.id] ?? TimelineView.defaultAvatar
            )
            let item = tableItem(height: TweetView.maxHeigth) { _ in
                TableItemRender<Voices.Action>(
                    component: TweetView.view(for: renderableTweet),
                    typeIdentifier: "TimelineTweet"
                )
            }
            items.append(item)
        }
        
        return table(
            items: items,
            style: tableStyleSheet() { base, table in
                table.separatorColor = .white
            },
            layout: layout() {
                $0.flex = flex() {
                    $0.grow = .one
                }
            }
        )
    }
    
}
