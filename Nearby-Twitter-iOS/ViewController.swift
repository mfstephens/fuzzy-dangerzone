//
//  ViewController.swift
//  Nearby-Twitter-iOS
//
//  Created by Matthew Stephens on 2/19/15.
//  Copyright (c) 2015 MattStephens. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreLocation

struct AuthCredentials {
    static let CONSUMER_KEY = "fx95oKhMHYgytSBmiAqQ"
    static let CONSUMER_SECRET = "0zfaijLMWMYTwVosdqFTL3k58JhRjZNxd2q0i9cltls"
    static let OAUTH_TOKEN = "2305278770-GGw8dQQg3o5Vqfx9xHpUgJ0CDUe3BoNmUNeWZBg"
    static let OAUTH_SECRET = "iEzxeJjEPnyODVcoDYt5MVvrg90Jx2TOetGdNeol6PeYp"
}

struct Config {
    static let RADIUS = "200mi"
    static let TWEET_COUNT = 20
    static let GET_TWEETS_SINCE = "2014-09-01"
    static let RESULT_TYPE = "recent"
}


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let locationManager:CLLocationManager = CLLocationManager()
    let searchBarTop : UISearchBar = UISearchBar()
    let imageCornerRadius : CGFloat = 5
    var swifter : Swifter
    var tweets : [JSONValue] = []
    var currentQuery : String = ""
    var currentLocation : CLLocation!
    var mediaArray  = [[UIImageView]]()
    @IBOutlet var tableView: UITableView!
    
    required init(coder aDecoder: NSCoder) {
        self.swifter = Swifter(consumerKey: AuthCredentials.CONSUMER_KEY, consumerSecret: AuthCredentials.CONSUMER_SECRET, oauthToken: AuthCredentials.OAUTH_TOKEN, oauthTokenSecret: AuthCredentials.OAUTH_SECRET)
        currentLocation = nil
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // search bar
        self.navigationItem.titleView = self.searchBarTop
        searchBarTop.showsScopeBar = true
        searchBarTop.delegate = self
        
        // location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Networking Stuff
    func updateTable () {
        
        let failureHandler: ((NSError) -> Void) = {
            error in
            println(error.localizedDescription)
        }
        
        let geocode = currentLocation.coordinate.latitude.description + "," + currentLocation.coordinate.longitude.description + "," + Config.RADIUS
        
        swifter.getSearchTweetsWithQuery(currentQuery, geocode: geocode, lang: "en", locale: "en", resultType: Config.RESULT_TYPE, count: Config.TWEET_COUNT, until: "", sinceID: "", maxID: "", includeEntities: true, callback: "", success: { (statuses, searchMetadata) -> Void in
            
            
            
            self.tweets = statuses!
            self.tableView.reloadData()
            
            
            }, failure: failureHandler)
        
    }
    
    //MARK: - UISearchBar
    func searchBarSearchButtonClicked( searchBar: UISearchBar!)
    {
        currentQuery = searchBar.text
        searchBar.resignFirstResponder()
        updateTable()
    }
    
    //MARK: - UITableViewControllerDelegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let tweetCellIdentifier = "TweetCellIdentifier"
        let loadMoreCellIdentifier = "LoadMoreCellIdentifier"
        
        if (indexPath.row != tweets.count && tweets.count != 0) {
            let cell:TweetTableViewCell = tableView.dequeueReusableCellWithIdentifier(tweetCellIdentifier, forIndexPath: indexPath) as TweetTableViewCell
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            // make author's name bold
            var attributedAuthorName : NSMutableAttributedString = NSMutableAttributedString(string: tweets[indexPath.row]["user"]["screen_name"].string!)
            var nameLength = countElements(tweets[indexPath.row]["user"]["screen_name"].string!)
            cell.tweetAuthor.text = tweets[indexPath.row]["user"]["screen_name"].string!
            attributedAuthorName.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(17.0), range: NSMakeRange(0, nameLength))
            
            
            // load other data
            cell.tweetAuthor.attributedText = attributedAuthorName
            cell.tweetText.text = tweets[indexPath.row]["text"].string!
            cell.tweetLocation.text = tweets[indexPath.row]["place"]["full_name"].string!
            cell.tweetTextID = tweets[indexPath.row]["id"].double!
            cell.tweetAuthorID = tweets[indexPath.row]["user"]["id"].double!
            
            // set profile picture
            let imageURL = UIImage(data: NSData(contentsOfURL: NSURL(string: tweets[indexPath.row]["user"]["profile_image_url"].string!)!)!)
            cell.profileImageView.image = imageURL
            cell.profileImageView.layer.cornerRadius = imageCornerRadius
            cell.profileImageView.clipsToBounds = true
            
            // check if we have any images. If so, load them into the cell
            var tempArr : [UIImageView] = []
            if let media = tweets[indexPath.row]["entities"]["media"].array? {
                for m in media {
                    let imageURL = UIImage(data: NSData(contentsOfURL: NSURL(string: m["media_url_https"].string!)!)!)
                    let image = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.imageCollection.frame.size.width, height: 100))
                    image.image = imageURL
                    tempArr.append(image)
                }
            } else {
//                cell.imageCollection.removeFromSuperview()
            }
            mediaArray.append(tempArr)
            
            // set relative date
            let calendar = NSCalendar.autoupdatingCurrentCalendar()
            calendar.timeZone = NSTimeZone.systemTimeZone()
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeZone = calendar.timeZone
            dateFormatter.dateFormat = "EEE LLL d HH:mm:ss Z yyyy"
            if let startDate = dateFormatter.dateFromString(tweets[indexPath.row]["created_at"].string!) {
                let components = calendar.components(NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.CalendarUnitMinute,
                    fromDate: startDate, toDate: NSDate(), options: nil)
                let minutes = components.minute
                let hours = components.hour
                let days = components.day
                
                // if the post is less than a day/hour old, don't show the day/hour value
                if (days == 0 && hours == 0) {
                    cell.tweetRelativeTime.text = minutes.description + "m"
                } else if (days == 0) {
                    cell.tweetRelativeTime.text = hours.description + "h " + minutes.description + "m"
                } else {
                    cell.tweetRelativeTime.text = days.description + "d " + hours.description + "h " + minutes.description + "m"
                }
            }
            
            return cell
        } else if (indexPath.row == tweets.count && tweets.count == Config.TWEET_COUNT) {
            let cell:TweetTableViewCell = tableView.dequeueReusableCellWithIdentifier(loadMoreCellIdentifier, forIndexPath: indexPath) as TweetTableViewCell
            return cell
        }
        

        // silence error message
        let cell = UITableViewCell()
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: TweetTableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == tweets.count && tweets.count == Config.TWEET_COUNT) {
            return
        }
        cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, index: indexPath.row)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // add an extra 'load more' cell when we have more than 15 tweets
        if (tweets.count < Config.TWEET_COUNT) {
            return tweets.count
        } else {
            return tweets.count + 1;
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == tweets.count && tweets.count == Config.TWEET_COUNT) {
            return 54
        }
        if let media = tweets[indexPath.row]["entities"]["media"].array? {
            return 300
        } else {
            return 175
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchBarTop.resignFirstResponder()
    }
    
    //MARK: - UICollectionView
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let media = mediaArray[collectionView.tag] as Array
        return media.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as UICollectionViewCell
        
        if (indexPath.row == tweets.count && tweets.count == Config.TWEET_COUNT) {
            return cell
        }

        let media = mediaArray[collectionView.tag] as Array
        cell.contentView.addSubview(media[indexPath.item] as UIImageView)

        
        return cell
    }
    
    
    //MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var location:CLLocation = locations[locations.count-1] as CLLocation
        if (location.horizontalAccuracy > 0) {
            self.locationManager.stopUpdatingLocation()
            currentLocation = location
            updateTable()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
    }



}

