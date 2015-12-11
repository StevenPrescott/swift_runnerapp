/**
￼@class SignIn.swift
This file is used to Login in the application,if user already registerd OR Sign Up As a new user.
Prescott | Neshagaran
@Copyright (c) 2015 Prescott | Neshagaran. All rights reserved.
*/


import UIKit

class SignIn: UIViewController,UITextFieldDelegate,JsonDelegete {
 
    /* This is the UITextField Object which holds Email,Password of Coach */
     @IBOutlet var userNameTF : UITextField!
     @IBOutlet var passwordTF : UITextField!
    
     @IBOutlet var loginBtn : UIButton!
     @IBOutlet var signUpBtn : UIButton!
     @IBOutlet var forgotPasswdBtn : UIButton!
     @IBOutlet var loadingIndicator : UIActivityIndicatorView!
     @IBOutlet var loadingView : UIView!
     @IBOutlet var msgLblShow : UILabel!

    
    /** This is the Object of JsonParsing Class which is used to Call API. */
     let jsonParsing = JsonParsing(nibName:"JsonParsing.swift", bundle: nil)
     var dataFetchingCase : Int = -1
     var dataToSend = NSString()
    
    
     var timer : NSTimer = NSTimer()
    
    /** This is Boolean flag to hold information that View in currently Up or Down.*/
     var _MoveUp: Bool = true
    
    
    lazy private var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: "loading")!
        return CustomActivityIndicatorView(image: image)
        }()


    override func viewDidLoad() {
        super.viewDidLoad()
       self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationItem.setHidesBackButton(true, animated: false)
       // navigationController!.navigationBar.barTintColor = UIColor(red: 100.0/255.0, green: 119.0/255.0, blue: 149.0/255.0, alpha:1.0)
        self.navigationItem.title = "Sign in or create a free account."
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

        addLoadingIndicator(self.view)
        self.addBottomLayer(userNameTF)
        self.addBottomLayer(passwordTF)
      //  self.addBottomLayer(forgotPasswdBtn)
      //  self.addBottomLayer(signUpBtn)
        msgLblShow.layer.masksToBounds = true
        msgLblShow.layer.cornerRadius = 4.0
        loginBtn.layer.cornerRadius = 4.0
        signUpBtn.layer.cornerRadius = 4.0
        
        }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addLoadingIndicator (tempView : UIView)
    {
        tempView.addSubview(activityIndicator)
        activityIndicator.center = self.view.center
    }
 
    //MARK:- Add a bottom layer Method
    func addBottomLayer(object:AnyObject)
    {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0.0, object.frame.size.height - 1, object.frame.size.width, 1.0);
     //   bottomBorder.backgroundColor = UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 1.0).CGColor
        bottomBorder.backgroundColor = UIColor.whiteColor().CGColor
        object.layer.addSublayer(bottomBorder)
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
    
    //MARK:- Sign Up Method
    @IBAction func signInBtnClicked(sender : AnyObject)
    {
        //Validate so that no field in empty.
        if userNameTF.text == ""
        {
            msgLblShow.text = "Please enter your Email-id"
            self.errorLblShow()
            
        }
        else if (isValidEmail(userNameTF.text!) == false)
        {
            msgLblShow.text = "Please enter a valid Email-id"
            self.errorLblShow()
            
        }
        else if passwordTF.text == ""
        {
            msgLblShow.text = "Please enter your password"
            self.errorLblShow()
            
        }
        else
        {
        NSUserDefaults.standardUserDefaults().setValue(userNameTF.text, forKey: "username") //Save username permanently for future access
        NSUserDefaults.standardUserDefaults().synchronize()
        
        NSUserDefaults.standardUserDefaults().setValue(passwordTF.text, forKey: "password")
            //Save username permanently for future access
        NSUserDefaults.standardUserDefaults().synchronize()
        self.view.alpha = 0.7
        self.view.userInteractionEnabled = false
            //Call API to Login inti o the application
        jsonParsing.loadData("POST", url: LoginApi, isHeader: true,throughAccessToken : false,dataToSend : dataToSend as String,sendData : true)
        jsonParsing.jpdelegate = self
        dataFetchingCase = ApiResponseValue.LoginApiCalled.rawValue
        activityIndicator.startAnimating()
        }
    }
    //MARK: - Validate Email Method
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest : NSPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    //MARK: - UITextField Delegete Methods
    func textFieldDidBeginEditing(textField: UITextField)
    {
        if (textField == userNameTF || textField == passwordTF ){
            self.viewMoveUp(60.0)
        }
    }
    func textFieldDidEndEditing(textField: UITextField)
    {
        if textField == userNameTF {
            userNameTF.resignFirstResponder()
            passwordTF.becomeFirstResponder()
        }
        else if textField == passwordTF {
            self.viewMoveDown(60.0)
        }
    }
//    func textField(textField: UITextField,shouldChangeCharactersInRange range: NSRange,replacementString string: String)
//        -> Bool
//    {
//        if userNameTF.text!.isEmpty ||  passwordTF.text!.isEmpty {
//            loginBtn.titleLabel?.textColor = UIColor(red: 170.0/255.0, green: 170.0/255.0, blue: 170.0/255.0, alpha: 1.0)
//        }
//        else
//        {
//            loginBtn.titleLabel?.textColor = UIColor.whiteColor()
//        }
//        return true
//    }
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
                {   //Perform animation to lift view upSide
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
                {   //Perform animation to lift view downSide
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
        if ((jsonParsing.fetchedJsonResult["success"] as! Int)  == isSuccess ) //test if get response from server successfully.
        {
            userNameTF.resignFirstResponder()
            passwordTF.resignFirstResponder()
           
            
            let access_token: NSString? = jsonParsing.fetchedDataArray.objectAtIndex(0)["access_token"] as? String
            
            let coach_id: Int? = jsonParsing.fetchedDataArray.objectAtIndex(0)["id"] as? Int
            NSUserDefaults.standardUserDefaults().setValue(String(format: "%d", coach_id!), forKey: "coach_id")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            
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

class ButtonFormatting: UIButton {
    @IBInspectable var borderColor: UIColor = UIColor.whiteColor() {
        didSet {
            layer.borderColor = borderColor.CGColor
        }
    }
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}