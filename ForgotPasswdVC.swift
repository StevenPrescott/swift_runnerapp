//
//  ForgotPasswdVC.swift
//  RunnerApp
//
//  Created by Prescott | Neshagaran on 11/15/15.
//  Copyright © 2015 Prescott | Neshagaran. All rights reserved.
//

import UIKit

class ForgotPasswdVC: UIViewController,JsonDelegete {

    @IBOutlet var emailTF : UITextField!
    @IBOutlet var submitBtn : UIButton!
    
    let jsonParsing = JsonParsing(nibName:"JsonParsing.swift", bundle: nil)
    var dataFetchingCase : Int = -1
    var dataToSend = NSString()
    @IBOutlet var msgLblShow : UILabel!
    var timer : NSTimer = NSTimer()
    
    /** This is the Object of "CustomActivityIndicatorView" Class to show custom Indicator View */
    lazy private var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: "loading")!
        return CustomActivityIndicatorView(image: image)
        }()
    
    override func viewDidLoad() {
        
        self.navigationItem.title = "Forgot Password"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.addLoadingIndicator(view)
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
        
    }

    //MARK: - Validate Email Method
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest : NSPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    func addLoadingIndicator (tempView : UIView)   //To Add Custom Indicator on this View
    {
        tempView.addSubview(activityIndicator)
        activityIndicator.center = self.view.center
        
    }
    @IBAction func submitBtnClicked(sender : AnyObject)
    {
        if (isValidEmail(emailTF.text!) == false)
        {
            msgLblShow.text = "Please enter a  Email-id"
            self.errorLblShow()
        }
        else  if (isValidEmail(emailTF.text!) == false)
        {
            msgLblShow.text = "Please enter a valid Email-id"
            self.errorLblShow()
            
        }
        else
        {
        let data = NSMutableDictionary()
        data.setValue(emailTF.text, forKey: "email")
        dataToSend  = data.JSONRepresentation()  //Change data in Json Format
        jsonParsing.loadData("POST", url: ForgetPasswordApi  , isHeader: true,throughAccessToken : false,dataToSend : dataToSend as String,sendData : true)
        print(dataToSend)
            self.view.userInteractionEnabled = false
            self.view.alpha = 0.7

        jsonParsing.jpdelegate = self
        dataFetchingCase = ApiResponseValue.ForgetPasswordApiCalled.rawValue
        activityIndicator.startAnimating()
        }
    }
    /** This method is used to show any error alert on the screen */
    func errorLblShow()
    {
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {                         //Show message Label.
            
            self.msgLblShow.alpha = 1.0
            self.view.userInteractionEnabled = false
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1.2, target: self, selector:"update", userInfo:nil, repeats: false)     //Start Timer to show alert for a specific time.
            }, completion: nil)
        
        
    }
    
    /** This method is called when timer completes and to hide the error label  */
    func update()
    {
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {                       //Hides the message Label
            self.msgLblShow.alpha = 0.0
            self.timer.invalidate()
            self.view.userInteractionEnabled = true
            }, completion: nil)
    }
    
    //MARK:- NSURLConnection Delegete Methods
    /** This is the Delegete Method of NSURLConnection Class,and gets called when we receive response of API */
    func dataFound(){
        
        let isSuccess : Int = 1
        activityIndicator.stopAnimating()
        self.view.userInteractionEnabled = true
        self.view.alpha = 1.0

        if (dataFetchingCase == ApiResponseValue.ForgetPasswordApiCalled.rawValue){
            if ((jsonParsing.fetchedJsonResult["success"] as! Int)  == isSuccess ) //test if we get response successfully.
            {
                let mailSentAlert: UIAlertView = UIAlertView()
                mailSentAlert.delegate = self
                //mailSentAlert.title = "Congratulation"
                mailSentAlert.message = "Mail succssfully sent to your Email-ID."
                mailSentAlert.addButtonWithTitle("Ok")
                mailSentAlert.show()
                print("Email Sent.")
            }
            else{
                
            }
            
        }
    }
    
    /** This is the Delegete Method of NSURLConnection Class,and get called when there is some problem in data receiving */
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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
