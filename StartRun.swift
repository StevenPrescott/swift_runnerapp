/**
￼@class StartRun.swift
￼This file is used to accept information about the Run Condition.
In this user have to give the Run Name,Length,Weather conditions.Then have to select all the runners who take part in run by press Select Runner button.
Prescott | Neshagaran
@Copyright (c) 2015 Prescott | Neshagaran. All rights reserved.
*/

import UIKit

class StartRun: UIViewController,JsonDelegete {

    /** This is the UITextField Object which holds information about Run */
    @IBOutlet var milesTF : UITextField!
    @IBOutlet var feetTF : UITextField!
    @IBOutlet var runNameTF : UITextField!
    @IBOutlet var tempTF : UITextField!
    @IBOutlet var numOfLapsTF : UITextField!
    
    @IBOutlet var selectRunnerBtn : UIButton!
    @IBOutlet var weatherConditionBtn : UIButton!
    @IBOutlet var sunnyConditionBtn : UIButton!
    @IBOutlet var cloudyConditionBtn : UIButton!
    @IBOutlet var foggyConditionBtn : UIButton!
    
    @IBOutlet var msgLblShow : UILabel!
    
    /** This is the NSMutableString Object which holds information about currentWeather */
    var currentWeatherCondition:NSMutableString = "sunny"
    
    var allRunnerArray:NSMutableArray = NSMutableArray()
    var runDetailDict:NSMutableDictionary = NSMutableDictionary()
    

    var timer : NSTimer = NSTimer()
    
    /** This is the Object of JsonParsing Class which is used to Call API. */
    let jsonParsing = JsonParsing(nibName:"JsonParsing.swift", bundle: nil)
    var dataToSend = NSString()
    var dataFetchingCase : Int = -1
    
    /** This is the Object of "CustomActivityIndicatorView" Class to show custom Indicator View */
    lazy private var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: "loading")!
        return CustomActivityIndicatorView(image: image)
        }()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationItem.title = "Start Run"
        //Add a bottom layer to each textField
        self.addBottomLayer(milesTF)
        self.addBottomLayer(feetTF)
        self.addBottomLayer(runNameTF)
        self.addBottomLayer(tempTF)
        
        addLoadingIndicator(self.view)
        
        //Give a corner radius ro all UIButtons
        sunnyConditionBtn.layer.cornerRadius = 4.0
        cloudyConditionBtn.layer.cornerRadius = 4.0
        foggyConditionBtn.layer.cornerRadius = 4.0
        selectRunnerBtn.layer.cornerRadius = 4.0
        
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.setHidesBackButton(false, animated: false)
        super.viewWillAppear(animated);
        
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
    @IBAction func doneNumberPad(sender : AnyObject)
    {
        milesTF.resignFirstResponder()
        feetTF.resignFirstResponder()
        tempTF.resignFirstResponder()
        numOfLapsTF.resignFirstResponder()
    }
    
    //MARK:- Add bottom layer Method
    /**
    This method is used to add a layer at bottom to textField.
    */
    func addBottomLayer(textField: UITextField)
    {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0.0, textField.frame.size.height - 1, textField.frame.size.width, 1.0);
        bottomBorder.backgroundColor = UIColor.blackColor().CGColor
        textField.layer.addSublayer(bottomBorder)
    }
    
    //MARK:- Select Current Weather Condition Method
    /**
    This method is used to select the current weather condition.
    */
    @IBAction func selectWeatherConditionBtnClicked(sender : AnyObject)
    {
        //Change the background color of selected weather condition button.
        if (sender.tag == 1){
            sunnyConditionBtn.backgroundColor = UIColor(red: 33.0/255.0, green: 130.0/255.0, blue: 190.0/255.0, alpha: 1.0)
            foggyConditionBtn.backgroundColor = UIColor(red: 170.0/255.0, green: 170.0/255.0, blue: 170.0/255.0, alpha: 1.0)
            cloudyConditionBtn.backgroundColor = UIColor(red: 170.0/255.0, green: 170.0/255.0, blue: 170.0/255.0, alpha: 1.0)
            currentWeatherCondition.setString("sunny")
        }
        else if(sender.tag == 2){
            cloudyConditionBtn.backgroundColor = UIColor(red: 33.0/255.0, green: 130.0/255.0, blue: 190.0/255.0, alpha: 1.0)
            foggyConditionBtn.backgroundColor = UIColor(red: 170.0/255.0, green: 170.0/255.0, blue: 170.0/255.0, alpha: 1.0)
            sunnyConditionBtn.backgroundColor = UIColor(red: 170.0/255.0, green: 170.0/255.0, blue: 170.0/255.0, alpha: 1.0)
            currentWeatherCondition.setString("cloudy")
        }
        else{
            foggyConditionBtn.backgroundColor = UIColor(red: 33.0/255.0, green: 130.0/255.0, blue: 190.0/255.0, alpha: 1.0)
            cloudyConditionBtn.backgroundColor = UIColor(red: 170.0/255.0, green: 170.0/255.0, blue: 170.0/255.0, alpha: 1.0)
            sunnyConditionBtn.backgroundColor = UIColor(red: 170.0/255.0, green: 170.0/255.0, blue: 170.0/255.0, alpha: 1.0)
           currentWeatherCondition.setString("foggy")
        }
    }
    
    //MARK:- Select Runner Method
    /**
    This method is used to select the runner who take part in run.
    */
    @IBAction func selectRunnerBtnClicked(sender : AnyObject)
    {
        //Adding Constraint so that no field should be empty.
        if(runNameTF.text == "" )
        {
            msgLblShow.text = "Please enter run name."
            self.errorLblShow()
        }
        else if(milesTF.text == "")
        {
            msgLblShow.text = "Please enter run miles."
            self.errorLblShow()
            
        }
        else if(feetTF.text == "")
        {
            msgLblShow.text = "Please enter run feet."
            self.errorLblShow()
        }
        else if(tempTF.text == "")
        {
            msgLblShow.text = "Please enter temprature in fahrenheit."
            self.errorLblShow()
        }
        else if(numOfLapsTF.text == "")
        {
            msgLblShow.text = "Please enter number of laps in run."
            self.errorLblShow()
        }
        else{
            
            let runLength:NSMutableString = NSMutableString()  //Make a string of RunLength
            runLength.setString(milesTF.text!)
            runLength.appendString("miles")
            runLength.appendString(feetTF.text!)
            runLength.appendString("feet")
            
            runDetailDict.setObject(runNameTF.text!, forKey: "runName")    //Store Run Conditions for future use.
            runDetailDict.setObject(runLength, forKey: "runLength")
            runDetailDict.setObject(tempTF.text!, forKey: "temprature")
            runDetailDict.setObject(numOfLapsTF.text!, forKey: "lapCount")
            runDetailDict.setObject(currentWeatherCondition, forKey: "weatherCondition")
            
            //Call API to get updated list of all runners
            jsonParsing.loadData("GET", url: RunnerListApi, isHeader: true,throughAccessToken : false,dataToSend : dataToSend as String,sendData : true)
            self.view.userInteractionEnabled = false
            self.view.alpha = 0.7

            jsonParsing.jpdelegate = self
            dataFetchingCase = ApiResponseValue.RunnerListApiCalled.rawValue
            activityIndicator.startAnimating()
           
        }
    }
    
    //MARK:- Show Error Message Method
    /**
    This method is used to show error messages for some predefine time only.
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
    This method is called when time of the error message show completes .
    */
    func update()
    {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.msgLblShow.alpha = 0.0
            self.timer.invalidate()
            self.view.userInteractionEnabled = true
            }, completion: nil)
    }
    
    //MARK: - UITextField Delegete Methods
    func textFieldDidBeginEditing(textField: UITextField)
    {
        //add a toolbar with keyboard
        let toolbar:UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 44))
        toolbar.barStyle = UIBarStyle.BlackTranslucent
        let doneItem: UIBarButtonItem = UIBarButtonItem(title:"Done", style:UIBarButtonItemStyle.Plain, target: self, action: "doneNumberPad:")
        let array:NSArray = [doneItem]
        toolbar.items = array as? [UIBarButtonItem]
        toolbar.sizeToFit()
        if textField == milesTF || textField == feetTF || textField == tempTF || textField == numOfLapsTF{
            textField.inputAccessoryView = toolbar
        }
        
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField == milesTF || textField == feetTF || textField == tempTF {
            let inverseSet = NSCharacterSet(charactersInString:"0123456789.").invertedSet
            
            let components = string.componentsSeparatedByCharactersInSet(inverseSet)
            
            let filtered = components.joinWithSeparator("")
            let countdots = textField.text!.componentsSeparatedByString(".").count - 1
            
            if countdots > 0 && string == "."
            {
                return false
            }
            return string == filtered
        }
        return true
        
    }
    
    
    //MARK:- NSURLConnection Delegete Methods
    /** This is the Delegete Method of NSURLConnection Class,and get called when we receive response of API */
    func dataFound(){
        let isSuccess : Int = 1
        activityIndicator.stopAnimating()
        self.view.userInteractionEnabled = true
        self.view.alpha = 1.0

        if ((jsonParsing.fetchedJsonResult["success"] as! Int)  == isSuccess )  //test if we get response successfully.
        {
            var tempArray:NSArray = NSArray()
            tempArray = (jsonParsing.fetchedDataArray.objectAtIndex(0) as! NSArray)
            let predicate =  NSPredicate(format: "role == %@", "2" ) //Filter all the runners with role = 2,Since the role of Runner is 2 and role of Coach is 1.
            let allRunnerArray = tempArray.filteredArrayUsingPredicate(predicate)
            let selectRunnerVC = self.storyboard?.instantiateViewControllerWithIdentifier("SelectRunner") as! SelectRunnerVC
            selectRunnerVC.tempRunDetail = runDetailDict    //Pass Run Detail information to SelectRunnerVC
            selectRunnerVC.runnerListArray.addObjectsFromArray(allRunnerArray) //Pass Updated Runner list to SelectRunnerVC
            self.navigationController?.pushViewController(selectRunnerVC, animated: true)
        }
        else{
            if(jsonParsing.fetchedJsonResult["data"]?.count > 0){
                let message = jsonParsing.fetchedJsonResult.valueForKey("data")?.valueForKey("message") as! String
                let alert = UIAlertView(title: "Alert", message: message, delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                activityIndicator.stopAnimating()
                self.view.userInteractionEnabled = true
                self.view.alpha = 1.0
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
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */

}

