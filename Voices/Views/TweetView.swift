//
//  Tweet.swift
//  Voices
//
//  Created by Guido Marucci Blas on 4/24/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//
import Foundation
import PortalView
import UIKit

struct TweetView {
    
    struct RenderableTweet {
        
        let text: String
        let createdAt: Date
        let place: String?
        let userName: String
        let userSlug: String
        let userAvatar: Image
        
    }
    
    static let maxHeigth: UInt = 300
    
    fileprivate static let avatarSize: UInt = 50
    fileprivate static let padding: UInt = 5
    fileprivate static let contentPadding: UInt = 5
    fileprivate static let headerHeight: UInt = 20
    fileprivate static let contentMaxWidth = UInt(UIScreen.main.bounds.size.width) - avatarSize - contentPadding
    
    static func view(for tweet: RenderableTweet) -> Component<Voices.Action> {
        return container(
            children: [
                userAvatar(tweet.userAvatar),
                content(for: tweet)
            ],
            style: styleSheet() {
                $0.backgroundColor = .black
            },
            layout: layout() {
                $0.flex = flex() {
                    $0.direction = .row
                    $0.grow = .one
                }
                $0.padding = .all(value: padding)
                $0.height = dimension() {
                    $0.maximum = maxHeigth
                }
            }
        )
    }
    
    private static func userAvatar(_ avatar: Image) -> Component<Voices.Action> {
        return container(
            children: [
                imageView(
                    image: avatar,
                    style: styleSheet(),
                    layout: layout() {
                        $0.width = PortalView.Dimension(value: avatarSize)
                        $0.height = PortalView.Dimension(value: avatarSize)
                    }
                )
            ],
            style: styleSheet(),
            layout: layout() {
                $0.flex = flex() {
                    $0.grow = .one
                }
                $0.width = dimension() {
                    $0.maximum = avatarSize
                }
            }
        )
    }
    
    private static func content(for tweet: RenderableTweet) -> Component<Voices.Action> {
        var body: [Component<Voices.Action>] = [
            label(
                text: tweet.text,
                style: labelStyleSheet() { base, label in
                    label.textColor = .white
                    label.adjustToFitWidth = true
                }
            )
        ]
        if let place = tweet.place {
            body.append(label(
                text: place,
                style: labelStyleSheet() { base, label in
                    label.textColor = .white
                    label.adjustToFitWidth = true
                    label.textSize = 12
                })
            )
        }
        
        return container(
            children: [
                header(
                    userName: tweet.userName,
                    userSlug: "@\(tweet.userSlug)",
                    createdAt: "1m"
                ),
                container(
                    children: body,
                    style: styleSheet(),
                    layout: layout() {
                        $0.flex = flex() {
                            $0.grow = .one
                        }
                        $0.justifyContent = .spaceBetween
                    }
                )
            ],
            style: styleSheet(),
            layout: layout() {
                $0.width = dimension() {
                    // Max width must be set becuase UIKit needs a fixed width in order to decide
                    // if text's size needs to be adjusted or moved to a next line.
                    $0.maximum = contentMaxWidth
                }
                $0.padding = .by(edge: edge() {
                    $0.left = contentPadding
                })
                $0.flex = flex() {
                    $0.grow = .two
                }
            }
        )
    }
    
    private static func header(userName: String, userSlug: String, createdAt: String) -> Component<Voices.Action> {
        return container(
            children: [
                user(name: userName, slug: userSlug),
                label(
                    text: createdAt,
                    style: labelStyleSheet() { base, label in
                        label.textColor = .white
                        label.textSize = 12
                    }
                )
            ],
            layout: layout() {
                $0.height = PortalView.Dimension(value: headerHeight)
                $0.flex = flex() {
                    $0.direction = .row
                }
                $0.justifyContent = .spaceBetween
            }
        )
    }
    
    private static func user(name: String, slug: String) -> Component<Voices.Action> {
        return container(
            children: [
                label(
                    text: name,
                    style: labelStyleSheet() { base, label in
                        label.textColor = .white
                        label.textSize = 14
                    }
                ),
                label(
                    text: slug,
                    style: labelStyleSheet() { base, label in
                        label.textColor = .white
                        label.textSize = 12
                    },
                    layout: layout() {
                        $0.margin = .by(edge: edge() {
                            $0.left = 5
                        })
                    }
                )
            ],
            layout: layout() {
                $0.flex = flex() {
                    $0.direction = .row
                }
            }
        )
    }
    
}
