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
    
    static func view(tweets: [Tweet], users: [ObjectID<User> : User], avatars: [ObjectID<User> : Image]) -> Component<Voices.Action> {
        var items: [TableItemProperties<Voices.Action>] = []
        items.reserveCapacity(tweets.count)
        
        for tweet in tweets {
            guard let user = users[tweet.createdBy] else { continue }
            
            let item: TableItemProperties<Voices.Action> = tableItem(
                height: TweetView.maxHeight,
                onTap: .navigate(to: .detail(tweet.id))) { (maxHeight: UInt) in
                    let renderableTweet = TweetView.RenderableTweet.from(
                        tweet: tweet,
                        user: user,
                        avatar: avatars[user.id],
                        maxHeight: maxHeight
                    )
                    return TableItemRender<Voices.Action>(
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
