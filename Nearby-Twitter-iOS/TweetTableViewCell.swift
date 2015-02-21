//
//  TweetTableViewCell.swift
//  Nearby-Twitter-iOS
//
//  Created by Matthew Stephens on 2/20/15.
//  Copyright (c) 2015 MattStephens. All rights reserved.
//

import Foundation
import UIKit



class TweetTableViewCell :  UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var tweetText: UILabel!
    @IBOutlet weak var tweetAuthor: UILabel!
    @IBOutlet weak var tweetLocation: UILabel!
    let cornerRadius : CGFloat = 5
    
    @IBOutlet weak var replyButton: UIButton!
    
    @IBAction func didPressReply(sender: AnyObject) {
        
    }
    
    func loadCell(author : String, text : String, location : String, date : String, profileImageURL : String) {
        profileImageView.layer.cornerRadius = cornerRadius
        profileImageView.clipsToBounds = true
        tweetText.text = text
        tweetAuthor.text = author
        tweetLocation.text = location
        
        
//        var frame : CGRect = tweetText.frame
//        frame.size.height = tweetText.height
//        tweetText.frame = frame

        
        tweetText.sizeToFit()
        tweetLocation.frame.origin.y = tweetText.frame.maxY + 200
        replyButton.frame.origin.y = tweetLocation.frame.maxY + 200
        
        profileImageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string: profileImageURL)!)!)
    }
    
}
