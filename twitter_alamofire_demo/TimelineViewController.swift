//
//  TimelineViewController.swift
//  twitter_alamofire_demo
//
//  Created by Charles Hieger on 6/18/17.
//  Copyright © 2017 Charles Hieger. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    var tweets: [Tweet] = []
    var count = 20
    var isMoreDataLoading = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        APIManager.shared.getHomeTimeLine(count: count, completion: { (tweets, error) in
            if let tweets = tweets {
                self.tweets = tweets
                self.tableView.reloadData()
            } else if let error = error {
                print("Error getting home timeline: " + error.localizedDescription)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        APIManager.shared.getHomeTimeLine(count: count, completion: { (tweets, error) in
            if let tweets = tweets {
                self.tweets = tweets
                self.tableView.reloadData()
            } else if let error = error {
                print("Error getting home timeline: " + error.localizedDescription)
            }
        })
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refresh(refreshControl:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        
        cell.tweet = tweets[indexPath.row]
        cell.delegate = self
        cell.setTags(id: indexPath.row)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height

            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                if count < 200 {
                    count += 20
                }
                reload(at: count)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func didTapLogout(_ sender: Any) {
        APIManager.shared.logout()
    }
    
    @objc func refresh(refreshControl:UIRefreshControl) {
        count = 20
        APIManager.shared.getHomeTimeLine(count: count, completion: { (tweets, error) in
            if let tweets = tweets {
                self.tweets = tweets
                self.tableView.reloadData()
                refreshControl.endRefreshing()

            }
        })
    }

    func reload(at count: Int) {
        APIManager.shared.getHomeTimeLine(count: count, completion: { (tweets, error) in
            if let tweets = tweets {
                self.tweets = tweets
                self.tableView.reloadData()
                self.isMoreDataLoading = false
            }
        })
    }

}

extension TimelineViewController: TweetCellDelegate {
    func onRetweet(tweet: Tweet, id: Int, failure: @escaping (Bool)->()) {
        if tweet.retweeted {
            APIManager.shared.retweet(id: (tweet.id)!, success: { (tweet) in
                self.tweets[id] = tweet
                self.tableView.reloadData()
            }, failure: { (error) in
                print(error.localizedDescription)
                failure(false)
            })
        }
        else {
            APIManager.shared.unretweet(id: (tweet.id)!, success: { (tweet) in
                self.tweets[id] = tweet
                self.tableView.reloadData()
            }, failure: { (error) in
                print(error.localizedDescription)
                failure(true)
            })
        }
    }

    func onFavorite(tweet: Tweet, id: Int, failure: @escaping (Bool)->()) {
        if tweet.favorited {
            APIManager.shared.favorite(id: (tweet.id)!, success: { (tweet) in
                self.tweets[id] = tweet
                self.tableView.reloadData()
            }, failure: { (error) in
                failure(false)
            })
        } else {
            APIManager.shared.unfavorite(id: (tweet.id)!, success: { (tweet) in
                self.tweets[id] = tweet
                self.tableView.reloadData()
            }, failure: { (error) in
                failure(true)
            })
        }
    }

    func getUser() {

    }
}
