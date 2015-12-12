/**
￼@class SignUpSecond.swift
This file is used to accept the Email and Password of the Coach.
Firstly User add valid email,and password and confirm password.
Prescott | Neshagaran
@Copyright (c) 2015 Prescott | Neshagaran. All rights reserved.
*/

import UIKit

class SignUpSecond: UIViewController,JsonDelegete {
    
    /* This is the UITextField Object which holds the Email, Password and Confirm Password of the Coach */
    @IBOutlet var emailTF : UITextField!
    @IBOutlet var passWdTF : UITextField!
    @IBOutlet var confirmPassWdTF : UITextField!
    
    /** This is Boolean flag to hold information that View in currently Up or Down.*/
    var _MoveUp: Bool = true
    
    @IBOutlet var msgLblShow : UILabel!
    var timer : NSTimer = NSTimer()
    @IBOutlet var signUpBtn : UIButton!
    var receivedData:NSMutableArray = NSMutableArray()
    
     /** This is the Object of JsonParsing Class which is used to Call API. */
    var dataToSend = NSString()
    let jsonParsing = JsonParsing(nibName:"JsonParsing.swift", bundle: nil)
    var dataFetchingCase : Int = -1
    
    
    lazy private var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: "loading")!
        return CustomActivityIndicatorView(image: image)
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        print(receivedData)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationItem.title = "Sign Up"
        
        //add a bottom layer to UITextFields
        self.addBottomLayer(emailTF)
        self.addBottomLayer(passWdTF)
        self.addBottomLayer(confirmPassWdTF)
        addLoadingIndicator(self.view)
        msgLblShow.layer.masksToBounds = true
        msgLblShow.layer.cornerRadius = 4.0
        signUpBtn.layer.cornerRadius = 4.0
        
        // Do any additional setup after loading the view.
    }
    func addLoadingIndicator (tempView : UIView)
    {
        tempView.addSubview(activityIndicator)
        activityIndicator.center = self.view.center
        
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
    This method is called when time of error message show completes .
    */
    func update()
    {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.msgLblShow.alpha = 0.0
            self.timer.invalidate()
            self.view.userInteractionEnabled = true
            }, completion: nil)
    }
    
    //MARK:- Add a bottom layer Method
    func addBottomLayer(textField: UITextField)
    {
        let bottomBorder = CALayer()
         bottomBorder.frame = CGRectMake(0.0, textField.frame.size.height - 1, textField.frame.size.width, 1.0);
        bottomBorder.backgroundColor = UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 1.0).CGColor
        textField.layer.addSublayer(bottomBorder)
    }
    
    //MARK:- Sign Up  Method
    @IBAction func signUpBtnClicked(sender : AnyObject)
    {
        //validate that no field should be empty
        if emailTF.text == ""
        {
            msgLblShow.text = "Please enter your email address."
            self.errorLblShow()
        }
        else if (isValidEmail(emailTF.text!) == false)
        {
            msgLblShow.text = "Please enter a valid email address."
            self.errorLblShow()
        }
        else if passWdTF.text == ""
        {
            msgLblShow.text = "Please enter your password."
            self.errorLblShow()
        }
        else if confirmPassWdTF.text == ""
        {
            msgLblShow.text = "Please confirm your password"
            self.errorLblShow()
        }
        else if passWdTF.text != confirmPassWdTF.text
        {
            msgLblShow.text = "Password and confirmation must be same."
            self.errorLblShow()
        }
        else
        {
            NSUserDefaults.standardUserDefaults().setValue(emailTF.text, forKey: "username") //store Email for permanent storage
            NSUserDefaults.standardUserDefaults().synchronize()
            
            NSUserDefaults.standardUserDefaults().setValue(passWdTF.text, forKey: "password") //store Email for permanent storage

            
            print(receivedData)
            NSUserDefaults.standardUserDefaults().synchronize()
            NSUserDefaults.standardUserDefaults().setValue(receivedData.objectAtIndex(0).valueForKey("coachName"), forKey: "coach_name") //store Coach Name for permanent storage
            
            NSUserDefaults.standardUserDefaults().synchronize()
            
            let data = NSMutableDictionary()    //Data to send along with API
            if (receivedData.count > 0) {
                data.setValue("not available", forKey: "coach_id")
                data.setValue("not available", forKey: "userid")
                data.setValue(receivedData.objectAtIndex(0).valueForKey("userName") , forKey: "username")
                data.setValue(passWdTF.text, forKey: "password")
                data.setValue(emailTF.text, forKey: "email")
                data.setValue("not available", forKey: "first_name")
                data.setValue("not available", forKey: "last_name")
                data.setValue("not available", forKey: "weight")
                data.setValue("not available", forKey: "height")
                data.setValue("not available", forKey: "age")
                data.setValue("0000-00-00 00:00:00", forKey: "dob")
                data.setValue(receivedData.objectAtIndex(0).valueForKey("schoolName"), forKey: "school")
                data.setValue(receivedData.objectAtIndex(0).valueForKey("teamName"), forKey: "team")
                data.setValue(receivedData.objectAtIndex(0).valueForKey("coachName"), forKey: "coach_name")
                data.setValue("1", forKey: "role")
                data.setValue("NA", forKey: "intials")
                data.setValue("not available", forKey: "access_token")
                
                
                dataToSend  = data.JSONRepresentation()    //Change data in Json Format
            }
            //Call API to Sign Up the Coach and Save information to Server
            
            self.view.userInteractionEnabled = false
            self.view.alpha = 0.7

            jsonParsing.loadData("POST", url: SignUpApi, isHeader: true,throughAccessToken : false,dataToSend : dataToSend as String,sendData : true)
            jsonParsing.jpdelegate = self
            dataFetchingCase = ApiResponseValue.SignUpApiCalled.rawValue
            activityIndicator.startAnimating()
        }
    }
    
    //MARK:- Email Validation Method
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest : NSPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }

    //MARK:- UITextField Delegete Methods
    func textFieldDidBeginEditing(textField: UITextField)
    {
         self.viewMoveUp(60.0)   //Move View to Up
    }
    func textFieldDidEndEditing(textField: UITextField)
    {
        if textField == emailTF
        {
            emailTF.resignFirstResponder()
            passWdTF.becomeFirstResponder()
        }
        else if textField == passWdTF
        {
            passWdTF.resignFirstResponder()
            confirmPassWdTF.becomeFirstResponder()
        }
        else
        {
            self.viewMoveDown(60.0)   //Move View to Down 
            confirmPassWdTF.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
        
    }
    
    //MARK:- UIView Animation Methods
    /** This method is used to Up the View when user press on any UITextField */
    func viewMoveUp(value:CGFloat){
        if (_MoveUp){
            UIView.animateWithDuration( 0.3 , animations:
                {   //Perform animation to lift view upside
                    var f : CGRect  = self.view.bounds
                    f.origin.y += value
                    self.view.bounds = f
            })
            _MoveUp = false
        }
    }
    /** This method is used to Down the View when user press on any UITextField */
    func viewMoveDown(value:CGFloat){
        if (!_MoveUp){
            UIView.animateWithDuration( 0.3 , animations:
                {   //Perform animation to lift view upside
                    var f : CGRect  = self.view.bounds
                    f.origin.y -= value
                    self.view.bounds = f
            })
            _MoveUp = true
        }
    }
    
    //MARK:- NSURLConnection Delegete Methods
    /** This is the Delegete Method of NSURLConnection Class,and get called when we receive response of API */
    func dataFound(){
        let isSuccess : Int = 1
        activityIndicator.stopAnimating()
        self.view.userInteractionEnabled = true
        self.view.alpha = 1.0

        if (dataFetchingCase == ApiResponseValue.SignUpApiCalled.rawValue){
            if ((jsonParsing.fetchedJsonResult["success"] as! Int)  == isSuccess )
            {
                let access_token: NSString? = jsonParsing.fetchedDataArray.objectAtIndex(0)["access_token"] as? String
                let coach_id: Int? = jsonParsing.fetchedDataArray.objectAtIndex(0)["id"] as? Int  //Get unique Coach ID.
                
                let user_id: Int? = jsonParsing.fetchedDataArray.objectAtIndex(0)["userid"] as? Int  //Get unique User ID.
                
                let coach_team: String? = jsonParsing.fetchedDataArray.objectAtIndex(0)["team"] as? String
                
                NSUserDefaults.standardUserDefaults().setValue(String(format: "%d", user_id!), forKey: "user_id") //Save User ID for further use.
                NSUserDefaults.standardUserDefaults().synchronize()

                
                NSUserDefaults.standardUserDefaults().setValue(String(format: "%d", coach_id!), forKey: "coach_id") //Save Caoch ID for further use.
                NSUserDefaults.standardUserDefaults().synchronize()
                
                NSUserDefaults.standardUserDefaults().setValue(String(format: "%@", coach_team!), forKey: "coach_team") //Save Caoch ID for further use.
                NSUserDefaults.standardUserDefaults().synchronize()
                
                NSUserDefaults.standardUserDefaults().setValue(access_token, forKey: "access_token")
                NSUserDefaults.standardUserDefaults().synchronize()
                NSUserDefaults.standardUserDefaults().setValue("false", forKey: "logout")
                NSUserDefaults.standardUserDefaults().synchronize()
                let user_email: NSString? = jsonParsing.fetchedDataArray.objectAtIndex(0)["email_id"] as? String
                NSUserDefaults.standardUserDefaults().setValue(user_email, forKey: "email_id")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                //Pass Control to Home Screen.
                let homeVC:UIViewController = self.storyboard?.instantiateViewControllerWithIdentifier("HomeScreen") as UIViewController!
                self.navigationController?.pushViewController(homeVC, animated: true)
            }
            else{
                let alert = UIAlertView(title: "Alert", message: "Username/email already exist.", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                self.view.userInteractionEnabled = true
                self.view.alpha = 1.0
                activityIndicator.stopAnimating()
            }
        }
    }
    /** This is the Delegete Method of NSURLConnection Class, and gets called when we there is some problem in data receiving */
    func connectionInterruption(){
        let alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
        activityIndicator.stopAnimating()
        self.view.userInteractionEnabled = true
        self.view.alpha = 1.0

 
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
