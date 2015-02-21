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
    static let RADIUS = "5mi"
    static let TWEET_COUNT = 15
    static let GET_TWEETS_SINCE = "2012-09-01"
    static let RESULT_TYPE = "recent"
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    let locationManager:CLLocationManager = CLLocationManager()
    let searchBarTop : UISearchBar = UISearchBar()
    var swifter : Swifter
    var tweets : [JSONValue] = []
    @IBOutlet var tableView: UITableView!
    
    required init(coder aDecoder: NSCoder) {
        self.swifter = Swifter(consumerKey: AuthCredentials.CONSUMER_KEY, consumerSecret: AuthCredentials.CONSUMER_SECRET, oauthToken: AuthCredentials.OAUTH_TOKEN, oauthTokenSecret: AuthCredentials.OAUTH_SECRET)
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = self.searchBarTop;
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Networking Stuff
    func searchForTweetsAtLocation (query : String, latitude : CLLocationDegrees, longitude : CLLocationDegrees) {
        
        let failureHandler: ((NSError) -> Void) = {
            error in
            println(error.localizedDescription)
        }
        
        let geocode = latitude.description + "," + longitude.description + "," + Config.RADIUS
        
        swifter.getSearchTweetsWithQuery(query, geocode: geocode, lang: "en", locale: "en", resultType: Config.RESULT_TYPE, count: Config.TWEET_COUNT, until: "", sinceID: "", maxID: "", includeEntities: false, callback: "", success: { (statuses, searchMetadata) -> Void in
            
            
            
            self.tweets = statuses!
            self.tableView.reloadData()
            
            
            }, failure: failureHandler)
        
    }
    
    func updateTweets (latitude : CLLocationDegrees, longitude : CLLocationDegrees) {
        searchForTweetsAtLocation("Kanye", latitude: latitude, longitude: longitude)
    }
    
    //MARK: - UITableViewControllerDelegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // do stuff
        let cell:TweetTableViewCell = tableView.dequeueReusableCellWithIdentifier("TweetCellIdentifier", forIndexPath: indexPath) as TweetTableViewCell
        

        if (tweets.count != 0) {
            cell.loadCell(tweets[indexPath.row]["user"]["screen_name"].string!, text: tweets[indexPath.row]["text"].string!, location: tweets[indexPath.row]["place"]["full_name"].string!, date: "date", profileImageURL: tweets[indexPath.row]["user"]["profile_image_url"].string!)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // do more stuff
        return tweets.count;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 175
    }
    
    
    //MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var location:CLLocation = locations[locations.count-1] as CLLocation
        if (location.horizontalAccuracy > 0) {
            self.locationManager.stopUpdatingLocation()
            updateTweets(location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
    }



}

