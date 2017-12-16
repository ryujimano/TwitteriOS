//
//  User.swift
//  twitter_alamofire_demo
//
//  Created by Charles Hieger on 6/17/17.
//  Copyright © 2017 Charles Hieger. All rights reserved.
//

import Foundation

class User: NSObject {

    var name: String?
    var screenName: String?
    var profileImageURL: URL?
    var tagline: String?
    var followersCount: Int?
    var followingCount: Int?
    var tweetCount: Int?
    var backgroundImageURL: URL?

    var dictionary: [String : Any]?

    init(dictionary: [String : Any]) {
        self.dictionary = dictionary

        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        if let profileImageURLString = dictionary["profile_image_url_https"] as? String {
            profileImageURL = URL(string: profileImageURLString)
        }
        tagline = dictionary["description"] as? String

        followersCount = dictionary["followers_count"] as? Int
        followingCount = dictionary["friends_count"] as? Int
        tweetCount = dictionary["statuses_count"] as? Int

        if let backgroundImageURL = dictionary["profile_background_image_url_https"] as? String {
            self.backgroundImageURL = URL(string: backgroundImageURL)
        }
    }

    static var _currentUser: User?

    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let defaults = UserDefaults.standard
                let user = defaults.object(forKey: "currentUserData") as? Data

                if let user = user {
                    let dictionary = try! JSONSerialization.jsonObject(with: user, options: []) as! [String : Any]
                    _currentUser = User(dictionary: dictionary)
                }
            }

            return _currentUser
        }
        set(user) {
            _currentUser = user
            let defaults = UserDefaults.standard
            if let user = user {
                let data = try! JSONSerialization.data(withJSONObject: user.dictionary, options: [])
                defaults.set(data, forKey: "currentUserData")
            }
            else {
                defaults.removeObject(forKey: "currentUserData")
            }
            defaults.synchronize()
        }
    }

}

