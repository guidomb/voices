//
//  Tweet.swift
//  Voices
//
//  Created by Guido Marucci Blas on 4/24/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation

struct ObjectID<Value>: Equatable, CustomStringConvertible, CustomDebugStringConvertible {
    
    static func ==<Value>(lhs: ObjectID<Value>, rhs: ObjectID<Value>) -> Bool {
        return lhs.id == rhs.id
    }
    
    private let id: String
    
    var description: String {
        return id
    }
    
    var debugDescription: String {
        return "\(Value.self)('\(id)')"
    }
    
    init(id: String) {
        self.id = id
    }
    
}

struct User {
    
    let id: ObjectID<User>
    let slug: String
    let name: String
    let avatar: URL
    
}

struct Tweet {
    
    let id: ObjectID<Tweet>
    let text: String
    let createdAt: Date
    let createdBy: ObjectID<User>
    let likedByMe: Bool
    
}
