//
//  Tweet.swift
//  twitter_alamofire_demo
//
//  Created by Charles Hieger on 6/18/17.
//  Copyright © 2017 Charles Hieger. All rights reserved.
//

import Foundation

class Tweet: NSObject {

    var dictionary: [String : Any]!
    var retweetedStatus: NSDictionary?
    var retweetedUser: String?
    var text: String?
    var timestamp: Date?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    var name: String?
    var screenName: String?
    var profileImage: URL?
    var tweetImage: URL?
    var caption: String?
    var link: URL?
    var displayLink: String?
    var id: String?
    var retweeted: Bool!
    var favorited: Bool!
    var replies: String?

    init(dictionary dict: [String :  Any]) {
        dictionary = dict

        if let retweetedStatus = dictionary["retweeted_status"] as? [String : Any] {
            if let user = dictionary["user"] as? [String : Any] {
                retweetedUser = user["name"] as? String
            }
            dictionary = retweetedStatus
        }

        text = dictionary["text"] as? String
        if let timeString = dictionary["created_at"] as? String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.date(from: timeString)
        }
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favorite_count"] as? Int) ?? 0

        if let user = dictionary["user"] as? NSDictionary {
            name = user["name"] as? String
            screenName = user["screen_name"] as? String
            if let profileURLString = user["profile_image_url_https"] as? String {
                profileImage = URL(string: profileURLString)
            }
        }

        if let entities = dictionary["entities"] as? NSDictionary {
            if let media = entities["media"] as? [NSDictionary] {
                var photo: NSDictionary?
                if media.count > 0 {
                    photo = media[0]
                }
                if let tweetImageURL = photo?["media_url_https"] as? String {
                    tweetImage = URL(string: tweetImageURL)
                }
            }

            if let urls = entities["urls"] as? [NSDictionary] {
                var url: NSDictionary?
                if urls.count > 0 {
                    url = urls[0]
                }
                if let linkString = url?["url"] as? String {
                    link = URL(string: linkString)
                }
                if let linkString = url?["display_url"] as? String {
                    displayLink = linkString
                }
            }
        }

        id = dictionary["id_str"] as? String
        retweeted = dictionary["retweeted"] as? Bool ?? false
        favorited = dictionary["favorited"] as? Bool ?? false

        replies = dictionary["in_reply_to_user_id_str"] as? String
    }

    class func tweetsFromDictionary(dictionaries: [[String : Any]]) -> [Tweet] {
        var tweets: [Tweet] = []

        for dictionary in dictionaries {
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
        }

        return tweets
    }

}
