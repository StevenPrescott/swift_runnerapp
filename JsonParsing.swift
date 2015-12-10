//
//  JsonParsing.swift
//  RunnerApp
//
//  Created by Prescott | Neshagaran on 9/26/15.
//  Copyright (c) 2015 Prescott | Neshagaran. All rights reserved.
//

import UIKit
@objc protocol JsonDelegete
{
    func dataFound()
    func connectionInterruption()
}
class JsonParsing: UIViewController {
    
    var jpdelegate : JsonDelegete?
    var fetchedData: NSMutableData = NSMutableData()
    var fetchedDataArray : NSMutableArray = NSMutableArray()
    var fetchedJsonResult : NSDictionary! = NSDictionary()
    var tempArray = NSMutableArray()
    var theConnection : NSURLConnection = NSURLConnection()
    

    override func viewDidLoad() {
        
       
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func loadData(HttpType : String, url : String ,isHeader : Bool,throughAccessToken : Bool,dataToSend:String,sendData :Bool)
    {
       
        
        
        var base64LoginString = String()
        print(NSUserDefaults.standardUserDefaults().valueForKey("username") as! String)
        let username: String! = NSUserDefaults.standardUserDefaults().valueForKey("username") as! String
        let password: String! = NSUserDefaults.standardUserDefaults().valueForKey("password") as! String
        
        if(throughAccessToken)
        {
            let access_token: String! = NSUserDefaults.standardUserDefaults().valueForKey("access_token") as! String
            let loginString = NSString(format: "%@:",access_token)
            let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
            base64LoginString = loginData.base64EncodedStringWithOptions([])
        }
        else
        {
            let loginString = NSString(format: "%@:%@", username, password)
            let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
            base64LoginString = loginData.base64EncodedStringWithOptions([])
        
        }
        let urlAsString = url
        let url = NSURL(string: urlAsString)
        print("URL =====\(url) ")
        var theConnection : NSURLConnection = NSURLConnection()
        let urlSession = NSURLSession.sharedSession()
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = HttpType
        if (sendData)
        {
            let dataOfString : NSData = dataToSend.dataUsingEncoding(NSUTF8StringEncoding)!
            request.HTTPBody = dataOfString
        }
        if(isHeader)
        {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
           // request.addValue("no-cache", forHTTPHeaderField: "Cache-Control")
            
        }
        print("URL Request is : \(request)")
        print("URL Request is : \(urlSession)")
        theConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
    }
    
    
    func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        // Received a new request, clear out the data object
        self.fetchedData = NSMutableData()
    }
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!)
    {
        // Append the received chunk of data to our data object
        self.fetchedData.appendData(data)
        //
    }
    func connection(connection: NSURLConnection!, didFailWithError error:NSError!)
    {
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK")
        } else {
            print("Internet connection FAILED")
            
            self.jpdelegate?.connectionInterruption()
        }
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!)
    {
        //var err: NSError
        fetchedJsonResult = NSDictionary()
        fetchedDataArray.removeAllObjects()
        // println(fetchedData)
        
        fetchedJsonResult = (try? NSJSONSerialization.JSONObjectWithData(fetchedData, options: NSJSONReadingOptions.MutableContainers)) as? NSDictionary
        print(fetchedJsonResult)
        if fetchedJsonResult == nil
        {
            print("API Problem")
        }
        else
        {
            fetchedDataArray.addObject(fetchedJsonResult["data"]!)
            //        println(fetchedDataArray)
            self.jpdelegate?.dataFound()
        }
        //    CoreDataFetchAndSave().insertData("User", dataArray:fetchedDataArray , tempKey: userKey)
        //    CoreDataFetchAndSave().fetchInfo("User", tempKey:userKey )
        //    CoreDataFetchAndSave().updateAndDelete("User", dataArray: array1, tempKey: userKey)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
