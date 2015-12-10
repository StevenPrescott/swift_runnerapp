/**
￼@class RunLapVC.swift
￼This file is used to count the time each runner takes to complete the run.
We have a list of Runners who take part in run. We tap on the "Tap To Start" button to start the time. When a Runner completes his or her run, tap on particular runner name, his or her time will be recorded. After all runners complete the run, press "Save Record" button to save data on Server.
Prescott | Neshagaran
@Copyright (c) 2015 Prescott | Neshagaran. All rights reserved.
*/

import UIKit
import iAd

class RunLapVC: UIViewController,JsonDelegete,ADBannerViewDelegate {
    
    /** This is the NSMutableArray Object which holds the list of all runners who take part in the Run */
    var runnerListArray: NSMutableArray = NSMutableArray()
    
   /** This is the NSMutableDictionary Object which holds the information about the Run */
    var runDetailDict: NSMutableDictionary = NSMutableDictionary()
    
    var timeDetailDict: NSMutableDictionary = NSMutableDictionary()
    
    
    @IBOutlet var runStartTblView : UITableView!
    @IBOutlet var hoursLbl : UILabel!
    @IBOutlet var minuteLbl : UILabel!
    @IBOutlet var secondsLbl : UILabel!
    @IBOutlet var tapToRun : UIButton!
    @IBOutlet var saveRecordBtn : UIButton!
    
    /** This is the Object of JsonParsing Class which is used to Call API. */
    let jsonParsing = JsonParsing(nibName:"JsonParsing.swift", bundle: nil)
    var dataToSend = NSString()
    var dataFetchingCase : Int = -1
    
    var runClearedCount : Int = 0
    var numberOfLaps : Int = 0
    
    var runnersArray:NSMutableArray = NSMutableArray()
    
    var runTimer : NSTimer = NSTimer()
    var count:Int = 1
    var seconds:Int = 1
    var minutes:Int = 0
    var hours:Int = 0
    
    @IBOutlet var adBannerView: ADBannerView!
    
    var timer:CADisplayLink = CADisplayLink()
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        runStartTblView.userInteractionEnabled = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationItem.title = "Start Run"
        
        tapToRun.layer.cornerRadius = 4.0
        saveRecordBtn.layer.cornerRadius = 4.0
        self.addLoadingIndicator(view)
        numberOfLaps = Int(runDetailDict.valueForKey("lapCount") as! String )!
        
        self.canDisplayBannerAds = true
        self.adBannerView.delegate = self
        self.adBannerView.hidden = true //hide until ad loaded
        
        
        // Do any additional setup after loading the view.
    }
    
    /** This is the Object of "CustomActivityIndicatorView" Class to show custom Indicator View */
    lazy private var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: "loading")!
        return CustomActivityIndicatorView(image: image)
        }()
    
    func addLoadingIndicator (tempView : UIView)
    {
        tempView.addSubview(activityIndicator)
        activityIndicator.center = self.view.center
        
    }
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController()){
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //MARK: - UITableView Delegete Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int)  -> Int
    {
        return runnerListArray.count  //return number of cell in UITableView
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell:RunLapCell = tableView.dequeueReusableCellWithIdentifier("RunCell") as! RunLapCell
        //Add a layer at bottom of each Cell.
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0.0, cell.frame.size.height - 1, cell.frame.size.width, 1.0);
        bottomBorder.backgroundColor = UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 1.0).CGColor
        cell.layer.addSublayer(bottomBorder)
        
        //Set Cell Properties
        cell.backgroundColor = UIColor(red: 251.0/255.0, green: 251.0/255.0, blue: 251.0/255.0, alpha: 1.0)
        cell.textLabel?.textColor = UIColor(red: 133.0/255.0, green: 133.0/255.0, blue: 133.0/255.0, alpha: 1.0)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        //Set Name of Runner on Cell
        cell.nameLbl.text = String(format: "%@", runnerListArray.objectAtIndex(indexPath.row).valueForKey("first_name") as! String )
        cell.runnerId.setString(String(format: "%@", runnerListArray.objectAtIndex(indexPath.row).valueForKey("id") as! String))
      
        return cell
    }
    func  tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)! as! RunLapCell
        
        cell.cellTapCount++
        
        var lapCount:Int = 0
        lapCount = count - cell.totalTimeCount
        
        print(lapCount)
        let tempLapRecord:NSMutableDictionary = NSMutableDictionary()
        tempLapRecord.setObject(String(format: "%d",lapCount), forKey: String(format: "lap%d", cell.cellTapCount))
        print(tempLapRecord)
        cell.lapRecord.addObject(tempLapRecord)
        if(cell.cellTapCount == numberOfLaps)
        {
            cell.userInteractionEnabled = false
            runClearedCount++
        }
        
        cell.totalTimeCount = count
        
        let timeString:NSMutableString = NSMutableString()
        timeString.setString(hoursLbl.text!)
        timeString.appendString(":")
        timeString.appendString(minuteLbl.text!)
        timeString.appendString(":")
        timeString.appendString(secondsLbl.text!)
        
        //timeDetailDict .setObject(timeString, forKey: String("%d",indexPath.row))
        timeDetailDict .setObject(timeString, forKey: indexPath.row)
        cell.timeLbl.text  = timeString as String
        cell.timeLbl.hidden = false
        
       // cell.userInteractionEnabled = false
        
        if runClearedCount == runnerListArray.count {        //saveRecordBtn enable when each runner completes the run.
            let runCompleteAlert: UIAlertView = UIAlertView()
            runCompleteAlert.delegate = self
            runCompleteAlert.title = "Congratulation"
            runCompleteAlert.message = "All Runner completes the Run."
            runCompleteAlert.addButtonWithTitle("Ok")
            runCompleteAlert.show()
            saveRecordBtn.userInteractionEnabled = true
            runTimer.invalidate()
        }
    }
    //MARK: - Start Run Method
    /**
    @brief This method is used to start the time.
    */
    @IBAction func startRunClicked(sender : AnyObject)
    {
        tapToRun.enabled = false
       runStartTblView.userInteractionEnabled = true
       secondsLbl.text = String(format: "%@", "01")
       runTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector:"update", userInfo:nil, repeats: true)
       NSRunLoop.currentRunLoop().addTimer(runTimer, forMode: NSRunLoopCommonModes)
        
    }
    //MARK: - Save Run Record on Saver
    /**
    @brief This method is used to Save Run Record on Saver.
    */
    @IBAction func saveRecordClicked(sender : AnyObject)
    {
        let data = NSMutableDictionary()
        let runDetail = NSMutableDictionary()
        let tempRunnersArray:NSMutableArray = NSMutableArray()
        tapToRun.enabled = true

        
        let coach_id: String! = NSUserDefaults.standardUserDefaults().valueForKey("user_id") as! String
       // let user_id = NSUserDefaults.standardUserDefaults().valueForKey("user_id")
        
        runDetail.setValue("not available", forKey: "run_id")
        runDetail.setValue(runDetailDict.valueForKey("runName"), forKey: "name")
        runDetail.setValue(runDetailDict.valueForKey("runLength"), forKey: "length")
        runDetail.setValue(runDetailDict.valueForKey("weatherCondition"), forKey: "weather")
        runDetail.setValue(runDetailDict.valueForKey("temprature"), forKey: "temperature")
        runDetail.setValue(runDetailDict.valueForKey("lapCount"), forKey: "lap_count")
        runDetail.setValue(coach_id, forKey: "coach_id")
        
        for (var i = 0 ; i < runnerListArray.count ; i++ )
        {
            let indexPath: NSIndexPath = NSIndexPath(forRow: i, inSection: 0)
            let cell = runStartTblView.cellForRowAtIndexPath(indexPath)! as! RunLapCell
            for (var lapCount = 1 ; lapCount <= numberOfLaps; lapCount++ )
            {
                //Gets each runner time taken in run.
            let tempLapRecord = cell.lapRecord.objectAtIndex(lapCount - 1)
            let lapTime = tempLapRecord.valueForKey(String(format: "lap%d",lapCount) as String)
                let runnnerDetail = NSMutableDictionary()
                runnnerDetail.setValue("not available", forKey: "run_id")
                runnnerDetail.setValue(coach_id, forKey: "runner_id")
              //  runnnerDetail.setValue(cell.runnerId, forKey: "runner_id")
                runnnerDetail.setValue(lapTime, forKey: "time")
                runnnerDetail.setValue(String(format: "%d", lapCount), forKey: "lap")
                tempRunnersArray.addObject(runnnerDetail)
            }
        }
        data.setValue(tempRunnersArray, forKey: "runners")
        data.setValue(runDetail, forKey: "run")
        dataToSend  = data.JSONRepresentation()       //Change data in Json Format
        print(dataToSend)
        //Call API to save Run Record on Server
        jsonParsing.loadData("POST", url:AddRunApi , isHeader: true,throughAccessToken : false,dataToSend : dataToSend as String,sendData : true)
        self.view.userInteractionEnabled = false
        self.view.alpha = 0.7

        jsonParsing.jpdelegate = self
        dataFetchingCase = ApiResponseValue.AddRunApiCalled.rawValue
        activityIndicator.startAnimating()
        
    }
    
    //MARK: - Update the time of Run
    /**
    @brief This method is used to update the time after start.
    */
    func update()
    {
        count++
        seconds++
        if seconds < 60{
            if (seconds <= 9) {
                secondsLbl.text = String(format: "%@%d", "0",seconds)
            }
            else{
               secondsLbl.text = String(format: "%d", seconds)
            }
        }
        else {
            seconds = 0
            secondsLbl.text = String(format: "%@", "00")
        }
        
        minutes = count / 60
        hours = count / 3600
        
        if (minutes <= 9) {
            minuteLbl.text = String(format: "%@%d", "0",minutes)
        }
        else{
            minuteLbl.text = String(format: "%d", minutes)
        }
        
        if (hours <= 9) {
            hoursLbl.text = String(format: "%@%d", "0",hours)
        }
        else{
            hoursLbl.text = String(format: "%d", hours)
        }
    }
    
    
    //MARK:- NSURLConnection Delegete Methods
    /** This is the Delegete Method of NSURLConnection Class, and gets called when we receive response of API */
    func dataFound(){
        
        let isSuccess : Int = 1
        activityIndicator.stopAnimating()
        self.view.userInteractionEnabled = true
        self.view.alpha = 1.0

        if (dataFetchingCase == ApiResponseValue.AddRunApiCalled.rawValue){
            if ((jsonParsing.fetchedJsonResult["success"] as! Int)  == isSuccess )  //test if we get response successfully.
            {
                //Parse data after receiving from API Response
                let access_token: NSString? = jsonParsing.fetchedDataArray.objectAtIndex(0)["access_token"] as? String
                NSUserDefaults.standardUserDefaults().setValue(access_token, forKey: "access_token")
                NSUserDefaults.standardUserDefaults().synchronize()
                NSUserDefaults.standardUserDefaults().setValue("false", forKey: "logout")
                NSUserDefaults.standardUserDefaults().synchronize()
                let user_email: NSString? = jsonParsing.fetchedDataArray.objectAtIndex(0)["email_id"] as? String
                NSUserDefaults.standardUserDefaults().setValue(user_email, forKey: "email_id")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                let homeVC:UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier("HomeScreen") as UIViewController!
                
                self.navigationController?.pushViewController(homeVC, animated: true)
            }
            else{
                
                
                

            }
            
        }
    }
    /** This is the Delegete Method of NSURLConnection Class,and get called when we there is some problem in data receiving */
    func connectionInterruption(){
        let alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
        activityIndicator.stopAnimating()
        self.view.userInteractionEnabled = true
        self.view.alpha = 1.0

  
    }
    
     // MARK: - iAD Banner View
    func bannerViewWillLoadAd(banner: ADBannerView!) {
        NSLog("bannerViewWillLoadAd")
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        NSLog("bannerViewDidLoadAd")
        self.adBannerView.hidden = false //now show banner as ad is loaded
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        NSLog("bannerViewDidLoadAd")
        
        //optional resume paused game code
        
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        NSLog("bannerViewActionShouldBegin")
        
        //optional pause game code
        
        return true
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        NSLog("bannerView")
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
