//
//  TwitterService.swift
//  Voices
//
//  Created by Guido Marucci Blas on 4/24/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result
import Accounts
import Social

enum TwitterOperationError: Error {
    
    case accountAccessDenied
    case accountAccessFailure(Error)
    case accountUnavailable
    case invalidRequest
    case requestFailure(Error)
    case responseParsingFailure(TwitterParsingError)
    
}

enum TwitterParsingError: Error {
    
    case missingResponse
    case missingAttribute(String)
    case unsupportedType
    case jsonParsingError(Error)
    
}

struct TwitterTimelineResponse {
    
    let tweets: [Tweet]
    let users: [ObjectID<User> : User]
    
}

final class TwitterService {
    
    typealias TimelineProducer = SignalProducer<TwitterTimelineResponse, TwitterOperationError>
    
    fileprivate let accountStore = ACAccountStore()
    
    func fetchTimeline() -> TimelineProducer {
        return accountStore.requestAccessToTwitterAccounts()
            .mapError { TwitterOperationError.accountAccessFailure($0) }
            .flatMap(.concat, transform: extractFirstAccount)
            .flatMap(.concat, transform: fetchTimeline(for:))
    }
    
}

fileprivate func fetchTimeline(for account: ACAccount) -> TwitterService.TimelineProducer {
    guard let request = SLRequest.twitterHomeTimeline() else { return SignalProducer(error: .invalidRequest) }
    
    request.account = account
    return request.perform()
        .mapError { TwitterOperationError.requestFailure($0) }
        .flatMap(.concat) { (maybeData, _)  -> TwitterService.TimelineProducer in
            guard let data = maybeData else { return SignalProducer(error: .responseParsingFailure(.missingResponse)) }
            return SignalProducer.attempt { parseTimelineData(data) }
        }
}




// MARK: Parsing methods


fileprivate let tweetDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
    return dateFormatter
}()

fileprivate func formatDate(_ date: String) -> Date? {
    return tweetDateFormatter.date(from: date)
}

fileprivate func parseTimelineData(_ data: Data) -> Result<TwitterTimelineResponse, TwitterOperationError> {
    return parseJSON(from: data).flatMap { rawTweets in
        var users: [ObjectID<User> : User] = [:]
        var tweets: [Tweet] = []
        tweets.reserveCapacity(rawTweets.count)
        for rawTweet in rawTweets {
            switch parseTweet(rawTweet: rawTweet, usersCache: users) {
            case .success(let tweet, let maybeUser):
                if let user = maybeUser {
                    users[user.id] = user
                }
                tweets.append(tweet)
                
            case .failure(let error):
                return .failure(error)
            }
        }
        return .success(TwitterTimelineResponse(tweets: tweets, users: users))
    }
}

fileprivate func parseJSON(from data: Data) -> Result<[[String : Any]], TwitterOperationError> {
    do {
        if let rawTweets = try JSONSerialization.jsonObject(with: data, options: []) as? [[String : Any]] {
            return .success(rawTweets)
        } else {
            return .failure(.responseParsingFailure(.unsupportedType))
        }
    } catch let error {
        return .failure(.responseParsingFailure(.jsonParsingError(error)))
    }
}

fileprivate func parseTweet(rawTweet: [String : Any], usersCache:  [ObjectID<User> : User]) -> Result<(Tweet, User?), TwitterOperationError> {
    return parseTweet(rawTweet).flatMap { tweet in
        guard usersCache[tweet.createdBy] == nil else { return .success((tweet, .none)) }
        
        return parseUser(from: rawTweet).map { (tweet, $0) }
    }
}

fileprivate func parseTweet(_ tweet: [String : Any]) -> Result<Tweet, TwitterOperationError> {
    guard let tweetId = tweet["id_str"] as? String else {
        return .failure(.responseParsingFailure(.missingAttribute("id")))
    }
    guard let text = tweet["text"] as? String else {
        return .failure(.responseParsingFailure(.missingAttribute("text")))
    }
    guard let liked = tweet["favorited"] as? Bool else {
        return .failure(.responseParsingFailure(.missingAttribute("favorited")))
    }
    guard let rawCreatedAt = tweet["created_at"] as? String, let createdAt = formatDate(rawCreatedAt) else {
        return .failure(.responseParsingFailure(.missingAttribute("created_at")))
    }
    guard let rawUser = tweet["user"] as? [String:Any], let userId = rawUser["id_str"] as? String else {
        return .failure(.responseParsingFailure(.missingAttribute("user.id_str")))
    }
    
    let place: String?
    if let rawPlace = tweet["place"] as? [String : Any] {
        guard let fullName = rawPlace["full_name"] as? String else {
            return .failure(.responseParsingFailure(.missingAttribute("place.full_name")))
        }
        guard let country = rawPlace["country"] as? String else {
            return .failure(.responseParsingFailure(.missingAttribute("place.country")))
        }
        place = "\(fullName), \(country)"
    } else {
        place = .none
    }
    
    return .success(Tweet(
        id: ObjectID(tweetId),
        text: text,
        createdAt: createdAt,
        createdBy: ObjectID(userId),
        liked: liked,
        place: place
    ))
}

fileprivate func parseUser(from rawTweet: [String : Any]) -> Result<User, TwitterOperationError> {
    guard let rawUser = rawTweet["user"] as? [String : Any] else {
        return .failure(.responseParsingFailure(.missingAttribute("user")))
    }
    guard let userId = rawUser["id_str"] as? String else {
        return .failure(.responseParsingFailure(.missingAttribute("user.id")))
    }
    guard let slug = rawUser["screen_name"] as? String else {
        return .failure(.responseParsingFailure(.missingAttribute("user.screen_name")))
    }
    guard let name = rawUser["name"] as? String else {
        return .failure(.responseParsingFailure(.missingAttribute("user.name")))
    }
    guard let avatarURL = rawUser["profile_image_url_https"] as? String, let avatar = URL(string: avatarURL) else {
        return .failure(.responseParsingFailure(.missingAttribute("user.profile_image_url_https")))
    }
    
    
    return .success(User(
        id: ObjectID(userId),
        slug: slug,
        name: name,
        avatar: avatar
    ))
}

fileprivate func extractFirstAccount(_ accessResult: TwitterAccountAccessResult) -> SignalProducer<ACAccount, TwitterOperationError> {
    switch accessResult {
        
    case .granted(let accounts):
        if let account = accounts.first {
            return SignalProducer(value: account)
        } else {
            return SignalProducer(error: .accountUnavailable)
        }
    
    case .denied:
        return SignalProducer(error: .accountAccessDenied)
        
    }
}



// MARK: ACAccountStore and SLRequest extensions


fileprivate extension SLRequest {
    
    static func twitterHomeTimeline() -> SLRequest? {
        guard let url = URL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json") else { return .none }
        
        return SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, url: url, parameters: nil)
    }
    
    func perform() -> SignalProducer<(Data?, HTTPURLResponse?), NSError> {
        return SignalProducer { observer, _ in
            self.perform { (maybeData, maybeResponse, maybeError) in
                if let error = maybeError {
                    observer.send(error: error as NSError)
                } else {
                    observer.send(value: (maybeData, maybeResponse))
                }
            }
        }
    }
    
}

fileprivate enum TwitterAccountAccessResult {
    
    case granted([ACAccount])
    case denied
}

fileprivate extension ACAccountStore {
    
    var twitterAccountType: ACAccountType {
        return self.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
    }
    
    func requestAccessToTwitterAccounts() -> SignalProducer<TwitterAccountAccessResult, NSError> {
        return SignalProducer { observer, _  in
            self.requestAccessToAccounts(with: self.twitterAccountType, options: nil) { accessGranted, maybeError in
                if let error = maybeError {
                    observer.send(error: error as NSError)
                    return
                }
                
                if accessGranted {
                    var accounts: [ACAccount] = []
                    for account in self.accounts(with: self.twitterAccountType) where account is ACAccount {
                        accounts.append(account as! ACAccount)
                    }
                    observer.send(value: .granted(accounts))
                } else {
                    observer.send(value: .denied)
                }
                observer.sendCompleted()
            }
        }
    }
    
}
