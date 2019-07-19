//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let swifter = Swifter(consumerKey: "INSERT TWITTER API KEY", consumerSecret: "INSERT TWITTER SECRET API KEY")
    let sentimentClassifier = TweetSentimentClassifier()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    @IBAction func predictPressed(_ sender: Any) {
        
        if let searchText = textField.text {
            swifter.searchTweet(using: searchText, lang: "en", count: 100, tweetMode: .extended, success: { (results, metadata) in
                
                var tweets = [TweetSentimentClassifierInput]()
                
                for i in 0..<100 {
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        
                        tweets.append(tweetForClassification)
                        print("\(i) \(tweet)")
                    }
                }
                
                do {
                    let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
                    var sentimentScore = 0
                    
                    for prediction in predictions {
                        let sentiment = prediction.label
                        
                        if sentiment == "Pos" {
                            sentimentScore += 1
                        } else if sentiment == "Neg" {
                            sentimentScore -= 1
                        }
                    }
                    
                    if sentimentScore > 20 {
                        self.sentimentLabel.text = "😍"
                    } else if sentimentScore > 10 {
                        self.sentimentLabel.text = "😃"
                    } else if sentimentScore > 0 {
                        self.sentimentLabel.text = "🙂"
                    } else if sentimentScore == 0 {
                        self.sentimentLabel.text = "😐"
                    } else if sentimentScore > -10 {
                        self.sentimentLabel.text = "😕"
                    } else if sentimentScore > -20 {
                        self.sentimentLabel.text = "😡"
                    } else {
                        self.sentimentLabel.text = "🤮"
                    }
                    
                    print("sentimentScore: \(sentimentScore)")
                } catch {
                    print("There was an error with making a prediciton, \(error)")
                }
                
            }) { (error) in
                print("There was an error with the Twitter API Request, \(error)")
            }
        }
        
    }
    
}

