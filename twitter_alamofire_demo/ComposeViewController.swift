//
//  ComposeViewController.swift
//  twitter_alamofire_demo
//
//  Created by Ryuji Mano on 12/15/17.
//  Copyright © 2017 Charles Hieger. All rights reserved.
//

import UIKit

protocol TweetDelegate: class {
    func postTweet(tweet: Tweet)
}

class ComposeViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var charCountLabel: UILabel!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    weak var delegate: TweetDelegate?

    var replyTweet:String?
    var replyID: String?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        avatarView.layer.cornerRadius = 5
        avatarView.clipsToBounds = true
        if let url = User.currentUser?.profileImageURL {
            avatarView.setImageWith(url)
        }
        textView.becomeFirstResponder()

        if let replyTweet = replyTweet {
            textView.text = "@\(replyTweet) "
        }
        if textView.text.characters.count >= 140 {
            textView.text = textView.text.substring(to: textView.text.index(textView.text.startIndex, offsetBy: 140))
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onTweet(_ sender: Any) {
        if replyTweet == nil {
            APIManager.shared.postTweet(text: textView.text, success: { (tweet) in
                self.delegate?.postTweet(tweet: tweet)
                self.dismiss(animated: true, completion: nil)
            }, failure: { (error) in
                print(error.localizedDescription)
            })
        }
        else {
            APIManager.shared.postReply(text: textView.text, id: replyID ?? "", success: { (tweet) in
                self.delegate?.postTweet(tweet: tweet)
                self.dismiss(animated: true, completion: nil)
            }, failure: { (error) in
                print(error.localizedDescription)
            })
        }
    }


    func textViewDidChange(_ textView: UITextView) {
        if textView.text.characters.count >= 140 {
            textView.text = textView.text.substring(to: textView.text.index(textView.text.startIndex, offsetBy: 140))
        }
        charCountLabel.text = "\(140 - textView.text.characters.count)"
    }

}
