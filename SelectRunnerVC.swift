/**
￼SelectRunnerVC.swift
￼This file is used to display a list of all the runners and the user can select any runner by tap on their name.
We display the list of Runner in a UITableView object and user can select runner by a tap on the runner's name.
Prescott | Neshagaran
@Copyright (c) 2015 Prescott | Neshagaran. All rights reserved.
*/

import UIKit



class SelectRunnerVC: UIViewController,UITableViewDelegate,UITableViewDataSource,JsonDelegete {

    @IBOutlet var runnerListTblView: UITableView!
    
    /** This is the NSMutableArray Object which holds the list of all Runners */
    var runnerListArray:NSMutableArray = NSMutableArray()
    
    /** This is the NSMutableSet Object which holds the list of all Selected Runners */
    var selectedRunnerSet:NSMutableSet = NSMutableSet()
    
    @IBOutlet var msgLblShow : UILabel!
    var timer : NSTimer = NSTimer()
    
    /** This is the Object of JsonParsing Class which is used to Call API. */
    let jsonParsing = JsonParsing(nibName:"JsonParsing.swift", bundle: nil)
    var dataToSend = NSString()
    var dataFetchingCase : Int = -1
    
    
    var selectedRunnersArray:NSMutableArray = NSMutableArray()
    var tempRunDetail:NSMutableDictionary = NSMutableDictionary()
    
  
    
    lazy private var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: "loading")!
        return CustomActivityIndicatorView(image: image)
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationItem.title = "Select Runner"
        self.automaticallyAdjustsScrollViewInsets = false
        msgLblShow.layer.masksToBounds = true
        msgLblShow.layer.cornerRadius = 4.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //MARK:- Show Error Message Method
    /**
    @brief This method is used to show error message for some predefine time only.
    */
    func errorLblShow()
    {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.msgLblShow.alpha = 1.0
            self.view.userInteractionEnabled = false
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1.2, target: self, selector:"update", userInfo:nil, repeats: false)
            }, completion: nil)
        
        
    }
    /**
    @brief This method is called when time of error message show completes .
    */
    func update()
    {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            
            self.msgLblShow.alpha = 0.0
            self.timer.invalidate()
            self.view.userInteractionEnabled = true
            }, completion: nil)
    }
    
    //MARK:- Start Session Method
    @IBAction func startSessionBtnClicked(sender : AnyObject)
    {
        if (selectedRunnerSet.count <= 0)  //Check that atleast One runner must be selected to start a Run.
        {
            msgLblShow.text = "Please select any runner first."
            self.errorLblShow()
        }
        else{
            
            //Push to runVc
            let runVC = self.storyboard?.instantiateViewControllerWithIdentifier("TimeLapStart") as! RunLapVC
            runVC.runnerListArray = selectedRunnersArray
            runVC.runDetailDict = tempRunDetail
            self.navigationController?.pushViewController(runVC, animated: true)
        }
    }
    //MARK: - UITableView Delegete Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int)  -> Int
    {
        return runnerListArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        cell.frame = CGRectMake(0.0, 100.0, tableView.frame.size.width, 44.0);
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0.0, cell.frame.size.height - 1, cell.frame.size.width, 1.0);
        bottomBorder.backgroundColor = UIColor(red: 97.0/255.0, green: 97.0/255.0, blue: 97.0/255.0, alpha: 1.0).CGColor
        cell.layer.addSublayer(bottomBorder)
        cell.backgroundColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        cell.textLabel?.textColor = UIColor(red: 133.0/255.0, green: 133.0/255.0, blue: 133.0/255.0, alpha: 1.0)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.textLabel?.text = String(format: "%@", runnerListArray.objectAtIndex(indexPath.row).valueForKey("first_name") as! String )
        return cell
    }
    func  tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell:UITableViewCell = tableView .cellForRowAtIndexPath(indexPath)!
        if selectedRunnerSet .containsObject(indexPath.row){
            selectedRunnerSet.removeObject(indexPath.row)
            cell.accessoryType = UITableViewCellAccessoryType.None
            selectedRunnersArray.removeObject(runnerListArray.objectAtIndex(indexPath.row))
        }
        else{
            selectedRunnerSet.addObject(indexPath.row)
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            selectedRunnersArray.addObject(runnerListArray.objectAtIndex(indexPath.row))
        }
    }
    
    //MARK:- NSURLConnection Delegete Methods
    /** This is the Delegete Method of NSURLConnection Class,and get called when we receive response of API */
    func dataFound(){
        let isSuccess : Int = 1
        activityIndicator.stopAnimating()
        if ((jsonParsing.fetchedJsonResult["success"] as! Int)  == isSuccess )  //test if we get response successfully.
        {
            let startRunVC:UIViewController? = (self.storyboard?.instantiateViewControllerWithIdentifier("TimeLapStart") as UIViewController!)
            self.navigationController?.pushViewController(startRunVC!, animated: true)
        }
        else{
            msgLblShow.text = "Your email or password is incorrect"
            self.errorLblShow()
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
