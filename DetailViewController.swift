/**
￼@class DetailViewController.swift
This file is used to all Runners list along with their Alias.
We call an API to get updated list of all Runners and show in a UITableView
Prescott | Neshagaran
@Copyright (c) 2015 Prescott | Neshagaran. All rights reserved.
*/

import UIKit

class DetailViewController: UIViewController,JsonDelegete {
    
     @IBOutlet var memberDetailTblView : UITableView!
     @IBOutlet var addRunnerBtn : UIButton!
     @IBOutlet var teamNameLbl : UILabel!
    
     /** This is the Object of NSMutableArray which is used to hold list of all Runners. */
     var memberDetailArray:NSMutableArray = NSMutableArray()
    
     /** This is the Object of JsonParsing Class which is used to Call API. */
     let jsonParsing = JsonParsing(nibName:"JsonParsing.swift", bundle: nil)
     var dataToSend = NSString()
     var dataFetchingCase : Int = -1
     var firstView:Int = 0
    
    /** This is the Object of "CustomActivityIndicatorView" Class to show custom Indicator View */
    lazy private var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: "loading")!
        return CustomActivityIndicatorView(image: image)
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Team Members"
        self.addLoadingIndicator(view)
         self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        let teamNameString:NSMutableString = "My Team: "
        teamNameString.appendString((NSUserDefaults.standardUserDefaults().valueForKey("coach_team") as? String)!)
        teamNameLbl.text = teamNameString as String
        
        self.automaticallyAdjustsScrollViewInsets = false
        memberDetailTblView.reloadData()
    }

    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController()){
        }
    }
    override func viewWillAppear(animated: Bool)
    {
        //Call API to get updated List of all Runners.
        if( firstView != 0)
        {
        
        jsonParsing.loadData("GET", url: RunnerListApi, isHeader: true,throughAccessToken : false,dataToSend : dataToSend as String,sendData : true)
        jsonParsing.jpdelegate = self
        self.view.userInteractionEnabled = false
        self.view.alpha = 0.7

        dataFetchingCase = ApiResponseValue.RunnerListApiCalled.rawValue
        activityIndicator.startAnimating()
            
        }
        firstView = 1
        super.viewWillAppear(animated)
    }
    func addLoadingIndicator (tempView : UIView)
    {
        tempView.addSubview(activityIndicator)
        activityIndicator.center = self.view.center
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- Push to AddRunnerVC Method
    @IBAction func addRunnerBtnClicked(sender : AnyObject)
    {
        //Push to AddRunnerVC
        let addRunnerVC:UIViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("AddRunner") as UIViewController!)
        self.navigationController?.pushViewController(addRunnerVC, animated: true)
    }
    
    //MARK: - UITableView Delegete Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int)  -> Int
    {
         return memberDetailArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell:MemberDetailCell = tableView.dequeueReusableCellWithIdentifier("MemberDetailCell") as! MemberDetailCell
        //Add a bottom Layer to each cell.
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0.0, cell.frame.size.height - 1, cell.frame.size.width, 1.0);
        bottomBorder.backgroundColor = UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 1.0).CGColor
        cell.layer.addSublayer(bottomBorder)
        
        //Set Cell Properties
        cell.backgroundColor = UIColor(red: 251.0/255.0, green: 251.0/255.0, blue: 251.0/255.0, alpha: 1.0)
        cell.textLabel?.textColor = UIColor(red: 133.0/255.0, green: 133.0/255.0, blue: 133.0/255.0, alpha: 1.0)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        //Set Runner Name and Alias on Cell.
        cell.nameLbl?.text = memberDetailArray.objectAtIndex(indexPath.row).valueForKey("first_name") as? String
        cell.aliasLbl?.text = memberDetailArray.objectAtIndex(indexPath.row).valueForKey("intials") as? String
        return cell
    }
    
    //MARK:- NSURLConnection Delegete Methods
    /** This is the Delegete Method of NSURLConnection Class,and get called when we receive response of API */
    func dataFound()
    {
        let isSuccess : Int = 1
        activityIndicator.stopAnimating()
        self.view.userInteractionEnabled = true
        self.view.alpha = 1.0

        if(dataFetchingCase == ApiResponseValue.RunnerListApiCalled.rawValue)
        {
            if ((jsonParsing.fetchedJsonResult["success"] as! Int)  == isSuccess )  //test if we get response successfully.
            {
                memberDetailArray.removeAllObjects()
                var tempArray:NSArray = NSArray()
                tempArray = (jsonParsing.fetchedDataArray.objectAtIndex(0) as! NSArray)
                let predicate =  NSPredicate(format: "role == %@", "2" )  //Filter all the runners with role = 2,Since the role of Runner is 2 and role of Coach is 1.
                memberDetailArray.addObjectsFromArray(tempArray.filteredArrayUsingPredicate(predicate))
                memberDetailTblView.reloadData()
            }
        }
    }
    /** This is the Delegete Method of NSURLConnection Class,and get called when we there is some problem in data receiving */
    func connectionInterruption(){
        let alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
        self.view.userInteractionEnabled = true
        self.view.alpha = 1.0
        activityIndicator.stopAnimating()

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
