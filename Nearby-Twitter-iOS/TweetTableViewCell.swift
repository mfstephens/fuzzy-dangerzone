//
//  TweetTableViewCell.swift
//  Nearby-Twitter-iOS
//
//  Created by Matthew Stephens on 2/20/15.
//  Copyright (c) 2015 MattStephens. All rights reserved.
//

import Foundation
import UIKit



class TweetTableViewCell :  UITableViewCell, UIAlertViewDelegate  {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tweetText: UILabel!
    @IBOutlet weak var tweetAuthor: UILabel!
    @IBOutlet weak var tweetLocation: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var tweetRelativeTime: UILabel!
    @IBOutlet weak var imageCollection: UICollectionView!
    
    var tweetTextID : Double!
    var tweetAuthorID : Double!
    
    @IBAction func didPressReply(sender: AnyObject) {
        var message = tweetText.text! + "\nTweet ID: " + tweetTextID.description + "\nTweet Author ID: " + tweetAuthorID.description
        var alert : UIAlertView = UIAlertView(title: "Reply", message: message, delegate: self, cancelButtonTitle: "Done")
        alert.show()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.imageCollection.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "TweetCellIdentifier")
    }
    
    required init(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCollectionViewDataSourceDelegate(dataSourceDelegate delegate: protocol<UICollectionViewDelegate,UICollectionViewDataSource>, index: NSInteger) {
        self.imageCollection.dataSource = delegate
        self.imageCollection.delegate = delegate
        self.imageCollection.tag = index
        self.imageCollection.reloadData()
    }
    

    
}
