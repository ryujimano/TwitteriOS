//
//  TweetCell.swift
//  twitter_alamofire_demo
//
//  Created by Ryuji Mano on 12/15/17.
//  Copyright © 2017 Charles Hieger. All rights reserved.
//
import UIKit
import AFNetworking

protocol TweetCellDelegate: class {
    func onRetweet(tweet: Tweet, id: Int, failure: @escaping (Bool)->())
    func onFavorite(tweet: Tweet, id: Int, failure: @escaping (Bool)->())
    func getUser()
}

class TweetCell: UITableViewCell {
    weak var delegate: TweetCellDelegate?

    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var tweetImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!

    var link: URL?

    var tweet: Tweet! {
        didSet {
            if tweet.retweetedUser != nil {
                extraView?.isHidden = false
                extraImageView.image = #imageLiteral(resourceName: "retweet-icon")
                extraScreenNameLabel.text = "\(tweet.retweetedUser!) Retweeted"
            }
            else {
                extraView?.isHidden = true
            }

            retweetCountLabel.text = "\(tweet.retweetCount)"
            favoriteCountLabel.text = "\(tweet.favoritesCount)"

            if tweet.retweeted {
                retweetButton.imageView?.image = #imageLiteral(resourceName: "retweet-icon-green")
            }
            else {
                retweetButton.imageView?.image = #imageLiteral(resourceName: "retweet-icon")
            }

            if tweet.favorited {
                favoriteButton.imageView?.image = #imageLiteral(resourceName: "favor-icon-red")
            }
            else {
                favoriteButton.imageView?.image = #imageLiteral(resourceName: "favor-icon")
            }

            retweetButton.addTarget(self, action: #selector(self.onRetweet(_:)), for: .touchUpInside)

            favoriteButton.addTarget(self, action: #selector(self.onFavorite(_:)), for: .touchUpInside)


            link = tweet.link

            stackView.layer.borderWidth = 1
            stackView.layer.borderColor = UIColor.lightGray.cgColor
            tweetLabel.text = tweet.text

            nameLabel.text = tweet.name
            if let image = tweet.profileImage {
                profileView.setImageWith(image)
            }
            handleLabel.text = "@\(tweet.screenName!)"

            if let image = tweet.tweetImage {
                first?.isHidden = false
                tweetImageView.setImageWith(image)
            }
            else {
                first?.isHidden = true
            }

            if let caption = tweet.caption {
                second?.isHidden = false
                descriptionLabel.text = caption
            }
            else {
                second?.isHidden = true
            }

            if let link = tweet.displayLink {
                third?.isHidden = false
                linkButton.setTitle(link, for: .normal)
            }
            else {
                third?.isHidden = true
            }


            let secondsBetween = Int(Date().timeIntervalSince(tweet.timestamp!))

            if secondsBetween < 60 {
                dateLabel.text = "・1m"
            }
            else if secondsBetween < 3600 {
                dateLabel.text = "・\(secondsBetween / 60)m"
            }
            else if secondsBetween < 86400 {
                dateLabel.text = "・\(secondsBetween / 3600)h"
            }
            else {
                dateLabel.text = "・\(secondsBetween / 86400)d"
            }

            profileButton.addTarget(self, action: #selector(self.getUser(_:)), for: .touchUpInside)
            //        self.tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.getUser(sender:)))
            //        cell.profileView.addGestureRecognizer(self.tapRecognizer)
        }
    }

    var first: UIView?
    var second: UIView?
    var third: UIView?
    @IBOutlet weak var profileButton: UIButton!

    @IBOutlet weak var extraScreenNameLabel: UILabel!
    @IBOutlet weak var extraImageView: UIImageView!
    @IBOutlet weak var cellStackView: UIStackView!

    var extraView: UIView?
    var mainView: UIView?

    var id: Int!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        extraView = cellStackView.arrangedSubviews[0]
        mainView = cellStackView.arrangedSubviews[1]

        first = stackView.arrangedSubviews[0]
        second = stackView.arrangedSubviews[1]
        third = stackView.arrangedSubviews[2]

        stackView.layer.cornerRadius = 5
        stackView.clipsToBounds = true
        stackView.layer.borderWidth = 1
        stackView.layer.borderColor = UIColor.lightGray.cgColor

        profileView.layer.cornerRadius = 5
        profileView.clipsToBounds = true

        tweetImageView.layer.cornerRadius = 5
        tweetImageView.clipsToBounds = true
        tweetImageView.contentMode = .scaleAspectFill

        extraImageView.tintColor = .lightGray

    }

    func setTags(id: Int) {
        retweetButton.tag = id
        favoriteButton.tag = id
        profileButton.tag = id
        self.id = id
    }


    @objc func onRetweet(_ sender: UIButton) {
        if !tweet.retweeted {
            tweet.retweeted = true
            retweetCountLabel.text = "\(tweet.retweetCount + 1)"
            retweetButton.imageView?.image = #imageLiteral(resourceName: "retweet-icon-green")
        } else {
            tweet.retweeted = false
            retweetCountLabel.text = "\(tweet.retweetCount - 1)"
            retweetButton.imageView?.image = #imageLiteral(resourceName: "retweet-icon")
        }
        delegate?.onRetweet(tweet: tweet, id: id, failure: { (revertBool) in
            if revertBool {
                self.tweet.retweeted = true
                self.retweetCountLabel.text = "\(self.tweet.retweetCount)"
                self.retweetButton.imageView?.image = #imageLiteral(resourceName: "retweet-icon-green")
            } else {
                self.tweet.retweeted = false
                self.retweetCountLabel.text = "\(self.tweet.retweetCount)"
                self.retweetButton.imageView?.image = #imageLiteral(resourceName: "retweet-icon")
            }
        })
    }

    @objc func onFavorite(_ sender: UIButton) {
        if !tweet.favorited {
            tweet.favorited = true
            favoriteCountLabel.text = "\(tweet.favoritesCount + 1)"
            favoriteButton.imageView?.image = #imageLiteral(resourceName: "favor-icon-red")
        } else {
            tweet.favorited = false
            favoriteCountLabel.text = "\(tweet.favoritesCount - 1)"
            favoriteButton.imageView?.image = #imageLiteral(resourceName: "favor-icon")
        }
        delegate?.onFavorite(tweet: tweet, id: id, failure: { (revertBool) in
            if revertBool {
                self.tweet.favorited = true
                self.favoriteCountLabel.text = "\(self.tweet.favoritesCount)"
                self.favoriteButton.imageView?.image = #imageLiteral(resourceName: "favor-icon-red")
            } else {
                self.tweet.favorited = false
                self.favoriteCountLabel.text = "\(self.tweet.favoritesCount)"
                self.favoriteButton.imageView?.image = #imageLiteral(resourceName: "favor-icon")
            }
        })
    }

    @objc func getUser(_ sender: UIButton) {

    }

    @IBAction func onLink(_ sender: Any) {
        if let link = self.link {
            UIApplication.shared.open(link, options: [:], completionHandler: nil)
        }
    }
}

