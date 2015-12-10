/**
￼@class AddRunner.swift
This file is used to Add, Remove, or Edit the runners.
By default the Add Runner Tab is selected. You can select another tab to Remove/Edit a runner.
Prescott | Neshagaran
@Copyright (c) 2015 Prescott | Neshagaran. All rights reserved.
*/
import UIKit

class AddRunner: UIViewController,JsonDelegete,UIAlertViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate {
 
    /** This is the UITextField Object which holds information of Runner */
    @IBOutlet var firstNameTF : UITextField!
    @IBOutlet var LastNameTF : UITextField!
    @IBOutlet var heightTF : UITextField!
    @IBOutlet var weightTF : UITextField!
    @IBOutlet var ageTF : UITextField!
    
    var firstView:Int = 0
    
    /** This is the UILabel Object which is used to show alert message */
    @IBOutlet var alertMsgLbl : UILabel!
    
    @IBOutlet var doneBtn : UIButton!

    /** This is the UISegmentedControl Object which is used to show different options of Add/Remove/Edit Runner.*/
    @IBOutlet var addRemoveSegmant : UISegmentedControl!
    
    /** This is the UIView Object which is used as Subview to show two different view for Add/Remove Runner.*/
    @IBOutlet var addRunnerView : UIView!
    @IBOutlet var removeRunnerView : UIView!
    
    @IBOutlet var allRunnerTblView : UITableView!
    var runnerListArray:NSMutableArray = NSMutableArray()
    var selectedRunnerDict:NSMutableDictionary = NSMutableDictionary()
    var selectedRunnerSet:NSMutableSet = NSMutableSet()
    var dataToPass:NSMutableDictionary = NSMutableDictionary()
    
    /** This is flag to hold information that which segment is selected.*/
    var selectedSegmentOptn:Int = -1
    
    /** This is Boolean flag to hold information that View in currently Up or Down.*/
    var _MoveUp: Bool = true
    
    @IBOutlet var msgLblShow : UILabel!
    var timer : NSTimer = NSTimer()
    var selectorPickerView : UIPickerView!
    var pickerType:NSMutableString = NSMutableString()
    let toolBar = UIToolbar()
    var ageValueArray:NSMutableArray = NSMutableArray()
    var feetValueArray:NSMutableArray = NSMutableArray()
    var inchValueArray:NSMutableArray = NSMutableArray()
    var weightValueArray:NSMutableArray = NSMutableArray()
    
    
     /** This is the Object of JsonParsing Class which is used to Call API. */
    let jsonParsing = JsonParsing(nibName:"JsonParsing.swift", bundle: nil)
    var dataFetchingCase : Int = -1
    var dataToSend = NSString()
    
    /** This is the Object of "CustomActivityIndicatorView" Class to show custom Indicator View */
    lazy private var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: "loading")!
        return CustomActivityIndicatorView(image: image)
        }()

    override func viewDidLoad() {
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.navigationItem.title = "My Team"
        self.automaticallyAdjustsScrollViewInsets = false
        
        //Add a layer to bottom of each UITextfield
        self.addBottomLayer(firstNameTF)
        self.addBottomLayer(LastNameTF)
        self.addBottomLayer(heightTF)
        self.addBottomLayer(weightTF)
        self.addBottomLayer(ageTF)
        doneBtn.layer.cornerRadius = 4.0
        self.addLoadingIndicator(view)
        
        //add values for Picker View
        
        for (var ageValue:Int = 1 ; ageValue <= 100 ; ageValue++  )
        {
            ageValueArray.addObject(String(format: "%d",ageValue))
        }
        for (var feetValue:Int = 1 ; feetValue <= 10 ; feetValue++  )
        {
            feetValueArray.addObject(String(format: "%d",feetValue))
        }
        for (var inchValue:Int = 1 ; inchValue <= 11 ; inchValue++  )
        {
            inchValueArray.addObject(String(format: "%d",inchValue))
        }
        for (var weightValue:Int = 1 ; weightValue <= 100 ; weightValue++  )
        {
            weightValueArray.addObject(String(format: "%d",weightValue))
        }
        
        firstView = 0
        
        super.viewDidLoad()
    }
    func addLoadingIndicator (tempView : UIView)
    {
        tempView.addSubview(activityIndicator)
        activityIndicator.center = self.view.center
        
    }
    override func viewWillAppear(animated: Bool) {
        
        //Call API to get updated list of Runner from Server.
        
        if (firstView != 0)
        {
        jsonParsing.loadData("GET", url: RunnerListApi, isHeader: true,throughAccessToken : false,dataToSend : dataToSend as String,sendData : true)
        jsonParsing.jpdelegate = self
        self.view.userInteractionEnabled = false
        self.view.alpha = 0.7

        dataFetchingCase = ApiResponseValue.InitializeRunnerScreen.rawValue
        activityIndicator.startAnimating()
        }
        firstView = 1
        super.viewWillAppear(animated)
    }
    
    //MARK:- UISegmentedControl Method
    /**
    @brief This method is used to select different segment of UISegmentedControl.
    */
    @IBAction func segmentedBtnClicked(sender : AnyObject)
    {
        alertMsgLbl.hidden = false
        if sender.selectedSegmentIndex == 0
        {
            alertMsgLbl.text = "Fill information to add a Runner."
            addRunnerView.hidden = false
            removeRunnerView.hidden = true
            doneBtn.hidden = false
        }
        else if sender.selectedSegmentIndex == 1 {
            
            //Call API to get updated list of Runner from Server.
            jsonParsing.loadData("GET", url: RunnerListApi, isHeader: true,throughAccessToken : false,dataToSend : dataToSend as String,sendData : true)
            jsonParsing.jpdelegate = self
            dataFetchingCase = ApiResponseValue.RunnerListApiCalled.rawValue
            activityIndicator.startAnimating()
            self.view.userInteractionEnabled = false
            self.view.alpha = 0.7

            alertMsgLbl.text = "Select Runner to remove."
            addRunnerView.hidden = true
            removeRunnerView.hidden = true
            doneBtn.hidden = true
            selectedSegmentOptn = 0
            
        }
        else{
           
            //Call API to get updated list of Runner from Server.
            jsonParsing.loadData("GET", url: RunnerListApi, isHeader: true,throughAccessToken : false,dataToSend : dataToSend as String,sendData : true)
            jsonParsing.jpdelegate = self
            self.view.userInteractionEnabled = false
            self.view.alpha = 0.7

            dataFetchingCase = ApiResponseValue.RunnerListApiCalled.rawValue
            activityIndicator.startAnimating()
            alertMsgLbl.text = "Select Any Runner to Edit."
            addRunnerView.hidden = true
            removeRunnerView.hidden = true
            doneBtn.hidden = true
            selectedSegmentOptn = 1
        }
        
    }
    //MARK:- Add bottom layer Method
    /**
    @brief This method is used to add a layer at bottom to textField.
    */
    func addBottomLayer(textField: UITextField)
    {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0.0, textField.frame.size.height - 1, textField.frame.size.width, 1.0);
        bottomBorder.backgroundColor = UIColor.blackColor().CGColor
        textField.layer.addSublayer(bottomBorder)
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
    
    //MARK:- Add new Runner information to the Server.
    /**
    @brief This method is used to add New Runner information to the Server.
    */
    @IBAction func doneBtnClicked(sender : AnyObject)
    {
        //validate that no field should be empty
        if firstNameTF.text == ""
        {
            msgLblShow.text = "Please enter first name."
            self.errorLblShow()
            
        }
        else if LastNameTF.text == ""
        {
            msgLblShow.text = "Please enter last name."
            self.errorLblShow()
            
        }
        else if heightTF.text == ""
        {
            msgLblShow.text = "Please enter height"
            self.errorLblShow()
            
        }
        else if weightTF.text == ""
        {
            msgLblShow.text = "Please enter weight"
            self.errorLblShow()
        }
        else if weightTF.text == ""
        {
            msgLblShow.text = "Please enter age"
            self.errorLblShow()
        }
        else
        {
            let firstIndex = firstNameTF.text!.startIndex        //Find Initials of the Runner Name
            let firstChar:Character =   firstNameTF.text![firstIndex]
            let secondChar:Character = LastNameTF.text![firstIndex]
            let intials:String = addCharcters(firstChar, last: secondChar)
            let user_id = NSUserDefaults.standardUserDefaults().valueForKey("user_id")
            
            let data = NSMutableDictionary()     //Data to send along with API
            data.setValue("not available", forKey: "userid")
            data.setValue("not available", forKey: "username")
            data.setValue("not available", forKey: "password")
            data.setValue("not available", forKey: "email")
            data.setValue(firstNameTF.text, forKey: "first_name")
            data.setValue(LastNameTF.text, forKey: "last_name")
            data.setValue(weightTF.text, forKey: "weight")
            data.setValue(heightTF.text, forKey: "height")
            data.setValue(ageTF.text, forKey: "age")
            data.setValue("0000-00-00 00:00:00", forKey: "dob")
            data.setValue("not available", forKey: "school")
            data.setValue("not available", forKey: "team")
            data.setValue("2", forKey: "role")
            data.setValue(user_id, forKey: "coach_id")
            data.setValue("not available", forKey: "coach_name")
            data.setValue(intials, forKey: "intials")
            data.setValue("not available", forKey: "access_token")
            
            
            dataToSend  = data.JSONRepresentation()     //Change data in Json Format
            print(dataToSend)
            //Call API to save runner information on the server.
            jsonParsing.loadData("POST", url: SignUpApi, isHeader: true,throughAccessToken : false,dataToSend : dataToSend as String,sendData : true)
            
            self.view.userInteractionEnabled = false
            self.view.alpha = 0.7

            
            jsonParsing.jpdelegate = self
            dataFetchingCase = ApiResponseValue.AddRunnerApiCalled.rawValue
            activityIndicator.startAnimating()
        }
    }
    
    //MARK: - Obtain Initials from Name Methods
    func addCharcters (first:Character, last:Character) -> String {
    return "\(first)\(last)"
    }
   
    
    //MARK: - UITableView Delegete Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int)  -> Int
    {
        return runnerListArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        //Create a UITableViewCell Object
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        cell.frame = CGRectMake(0.0, 100.0, tableView.frame.size.width, 44.0);
        
        //Add a layer at bottom of each Cell.
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0.0, cell.frame.size.height - 1, cell.frame.size.width, 1.0);
        bottomBorder.backgroundColor = UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 1.0).CGColor
        cell.layer.addSublayer(bottomBorder)
        
        //Set Cell Properties
        cell.backgroundColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        cell.textLabel?.textColor = UIColor(red: 133.0/255.0, green: 133.0/255.0, blue: 133.0/255.0, alpha: 1.0)
        
        //Set Name of Runner on Cell
        if (runnerListArray.count > 0){
           cell.textLabel?.text = String(format: "%@", runnerListArray.objectAtIndex(indexPath.row).valueForKey("first_name") as! String )
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    func  tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        //get selected runner detail
        selectedRunnerDict.removeAllObjects()
        selectedRunnerDict.addEntriesFromDictionary(runnerListArray.objectAtIndex(indexPath.row) as! NSDictionary as [NSObject : AnyObject])
        
        if(selectedSegmentOptn == 0){
            //Show alert for remove runner
            let removeRunnerAlert: UIAlertView = UIAlertView()
            removeRunnerAlert.delegate = self
            removeRunnerAlert.title = "Alert"
            removeRunnerAlert.message = "Do you want to remove runner!"
            removeRunnerAlert.addButtonWithTitle("Ok")
            removeRunnerAlert.addButtonWithTitle("Cancel")
            removeRunnerAlert.show()
        }
        else if(selectedSegmentOptn == 1){
            //Forward to Edit Runner View Controller
           
            let editVC = self.storyboard?.instantiateViewControllerWithIdentifier("EditVC") as! EditRunnerVC
            editVC.dataReceived = selectedRunnerDict
            self.navigationController?.pushViewController(editVC, animated: true)
        }
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
            return true
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // handle delete (by removing the data from your array and updating the tableview)
        }
    }
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?  {
        // 1
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Edit" , handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
           // self.editTaskAcn(indexPath.row)
            
        })
        // 3
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete" , handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
            // 4
            let deleteMenu = UIAlertController(title: nil, message: "Do u really want to delete", preferredStyle: .ActionSheet)
            
            let deleteYesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
                
              //  self.deleteTaskAcn(indexPath.row)
                
            })
            let deleteNoAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil)
            //    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            
            deleteMenu.addAction(deleteYesAction)
            deleteMenu.addAction(deleteNoAction)
            //   deleteMenu.addAction(cancelAction)
            
            
            self.presentViewController(deleteMenu, animated: true, completion: nil)
        })
        editAction.backgroundColor = UIColor(red : 1/255, green: 161/255, blue: 219/255, alpha: 1.0)
        deleteAction.backgroundColor = UIColor(red : 1/255, green: 161/255, blue: 219/255, alpha: 1.0)
        
        return [editAction,deleteAction]
    }
    
    //MARK: - Prepare For Segue Method
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        let destinationVC = segue.destinationViewController as! EditRunnerVC
        destinationVC.dataReceived = dataToPass
    }
    //MARK: - UIAlertView Delegete Method
    func alertView(View: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        
       switch buttonIndex{
        case 1:
            break;
        case 0:
            //Call API to remove runner from server.
            print(selectedRunnerDict)
            let data : String = String(format:"id=%@?", selectedRunnerDict.objectForKey("id") as! String)
            jsonParsing.loadData("POST", url: RemoveRunnerApi + data, isHeader: true,throughAccessToken : false,dataToSend : dataToSend as String,sendData : true)
            self.view.userInteractionEnabled = false
            self.view.alpha = 0.7

            jsonParsing.jpdelegate = self
            dataFetchingCase = ApiResponseValue.RemoveRunnerApiCalled.rawValue
            activityIndicator.startAnimating()
            break;
        default:
            NSLog("Default");
            break;
        }
    }
    
    //MARK: - UITextField Delegete Methods
    func textFieldDidBeginEditing(textField: UITextField)
    {
        
       self.viewMoveUp(90.0)
        if (textField == heightTF)
        {
            pickerType = "heightPicker"
            self.addPickerView(heightTF)
            selectorPickerView.selectRow(5, inComponent: 0, animated: false)
            selectorPickerView.selectRow(5, inComponent: 2, animated: false)
            
        }
        else  if (textField == weightTF)
        {
            pickerType = "weightPicker"
            self.addPickerView(weightTF)
            selectorPickerView.selectRow(50, inComponent: 0, animated: false)
            
        }
        else  if (textField == ageTF)
        {
            pickerType = "agePicker"
            self.addPickerView(ageTF)
            selectorPickerView.selectRow(50, inComponent: 0, animated: false)
            
        }
      
 //add a toolbar with keyboard
//        let toolbar:UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 44))
//        toolbar.barStyle = UIBarStyle.BlackTranslucent
//        let doneItem: UIBarButtonItem = UIBarButtonItem(title:"Done", style:UIBarButtonItemStyle.Plain, target: self, action: "doneNumberPad:")
//        let array:NSArray = [doneItem]
//        toolbar.items = array as? [UIBarButtonItem]
//        toolbar.sizeToFit()
//        
//        if textField == weightTF || textField == heightTF || textField == ageTF {
//            textField.inputView = selectorPickerView
//            textField.inputAccessoryView = toolbar
//        }
        
        
    }
    func textFieldDidEndEditing(textField: UITextField)
    {
        if textField == firstNameTF
        {
            firstNameTF.resignFirstResponder()
            LastNameTF.becomeFirstResponder()
        }
        else if textField == LastNameTF
        {
            LastNameTF.resignFirstResponder()
            heightTF.becomeFirstResponder()
        }
        else if textField == heightTF
        {
            heightTF.resignFirstResponder()
            weightTF.becomeFirstResponder()
        }
        else if textField == weightTF
        {
            weightTF.resignFirstResponder()
            ageTF.becomeFirstResponder()
            
        }
        else{
            ageTF.resignFirstResponder()
            self.viewMoveDown(90.0)
        }
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
        
    }
    
    @IBAction func doneNumberPad(sender : AnyObject)
    {
        heightTF.resignFirstResponder()
        weightTF.resignFirstResponder()
        ageTF.resignFirstResponder()
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
                {   //Perform animation to lift view downside
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

        
        if(dataFetchingCase == ApiResponseValue.RunnerListApiCalled.rawValue)        //test for dataFecthing Case.
        {
            if ((jsonParsing.fetchedJsonResult["success"] as! Int)  == isSuccess )   //test if we get response successfully.
            {
                runnerListArray.removeAllObjects()
                var tempArray:NSArray = NSArray()
                tempArray = (jsonParsing.fetchedDataArray.objectAtIndex(0) as! NSArray)
                let predicate =  NSPredicate(format: "role == %@", "2" )
                runnerListArray.addObjectsFromArray(tempArray.filteredArrayUsingPredicate(predicate))
                removeRunnerView.hidden = false
                allRunnerTblView.reloadData()
            }
        }
        else if(dataFetchingCase == ApiResponseValue.AddRunnerApiCalled.rawValue)
        {
            if ((jsonParsing.fetchedJsonResult["success"] as! Int)  == isSuccess )
            {
                firstNameTF.text = ""
                LastNameTF.text = ""
                heightTF.text = ""
                weightTF.text = ""
                ageTF.text = ""
                msgLblShow.text = "Runner Added Successfully."
                self.errorLblShow()
            }
            else{
                msgLblShow.text = "There is a problem,Please try later."
                self.errorLblShow()
            }
        }
        else if(dataFetchingCase == ApiResponseValue.RemoveRunnerApiCalled.rawValue)
        {
            if ((jsonParsing.fetchedJsonResult["success"] as! Int)  == isSuccess )
            {
                //Call API to get updated list of runners
                jsonParsing.loadData("GET", url: RunnerListApi, isHeader: true,throughAccessToken : false,dataToSend : dataToSend as String,sendData : true)
                jsonParsing.jpdelegate = self
                dataFetchingCase = ApiResponseValue.RunnerListApiCalled.rawValue
                activityIndicator.startAnimating()
            }
        }
       else if(dataFetchingCase == ApiResponseValue.InitializeRunnerScreen.rawValue)
        {
            if ((jsonParsing.fetchedJsonResult["success"] as! Int)  == isSuccess )
            {
                runnerListArray.removeAllObjects()
                var tempArray:NSArray = NSArray()
                tempArray = (jsonParsing.fetchedDataArray.objectAtIndex(0) as! NSArray)
                let predicate =  NSPredicate(format: "role == %@", "2" )
                runnerListArray.addObjectsFromArray(tempArray.filteredArrayUsingPredicate(predicate))
                allRunnerTblView.reloadData()
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
    
    func addPickerView(textField:UITextField)
    {
        selectorPickerView = UIPickerView(frame: CGRectMake(0, view.frame.height / 2 + 50, view.frame.width, 300))
        selectorPickerView.backgroundColor = .whiteColor()
        selectorPickerView.showsSelectionIndicator = true
        selectorPickerView.delegate = self
        selectorPickerView.dataSource = self
        
        
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "donePickerAction")
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelPickerAction")
        
        doneButton.tintColor = UIColor.blackColor()
        cancelButton.tintColor = UIColor.blackColor()
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        textField.inputView = selectorPickerView
        textField.inputAccessoryView = toolBar
        selectorPickerView.reloadAllComponents()
        
        

    }
    func donePickerAction()
    {
        if(pickerType .isEqualToString("heightPicker"))
        {
            let heightString:NSMutableString = NSMutableString()
            heightString .setString(feetValueArray.objectAtIndex(selectorPickerView.selectedRowInComponent(0)) as! String)
            heightString.appendString(" feet ")
            heightString .appendString(inchValueArray.objectAtIndex(selectorPickerView.selectedRowInComponent(2)) as! String)
            heightString.appendString(" inch")
            heightTF.text = heightString as String
            heightTF.resignFirstResponder()
        }
        else  if(pickerType .isEqualToString("weightPicker"))
        {
            let weightString:NSMutableString = NSMutableString()
        weightString.setString(weightValueArray.objectAtIndex(selectorPickerView.selectedRowInComponent(0)) as! String)
            weightString.appendString(" pounds")
            weightTF.text = weightString as String
            weightTF.resignFirstResponder()
        }
        else
        {
            let ageString:NSMutableString = NSMutableString()
            ageString.setString(ageValueArray.objectAtIndex(selectorPickerView.selectedRowInComponent(0)) as! String)
            ageString.appendString(" years")
            ageTF.text = ageString as String
            ageTF.resignFirstResponder()
        }
    }
    func cancelPickerAction()
    {
        selectorPickerView.removeFromSuperview()
        toolBar
        weightTF.resignFirstResponder()
        heightTF.resignFirstResponder()
        ageTF.resignFirstResponder()
        
    }
    //MARK: - UIPicker Delegates and data sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if(pickerType .isEqualToString("heightPicker"))
        {
            return 4
        }
        else
        {
            return 2
        }
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         if(pickerType .isEqualToString("heightPicker"))
         {
            if (component == 0)
            {
                return feetValueArray.count
            }
            else if (component == 1)
            {
               return 1
            }
            else if (component == 2)
            {
                return inchValueArray.count
            }
            else if (component == 3)
            {
                return 1
            }
         }
         else  if(pickerType .isEqualToString("weightPicker"))
         {
            if (component == 0)
            {
            return weightValueArray.count
            }
            else
            {
                return 1
            }
         }
         else
         {
            if (component == 0)
            {
                return ageValueArray.count
            }
            else
            {
                return 1
            }
            
         }
        return 1
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerType .isEqualToString("heightPicker"))
        {
            if (component == 0)
            {
                 return feetValueArray[row] as? String
            }
            else if (component == 1)
            {
                return "Feet"
            }
            else if (component == 2)
            {
               return inchValueArray[row] as? String
            }
            else if (component == 3)
            {
                 return "Inch"
            }
        }
        else  if(pickerType .isEqualToString("weightPicker"))
        {
            if (component == 0)
            {
            return weightValueArray[row] as? String
            }
            else
            {
                return "Pounds"
            }
        }
        else
        {
            if (component == 0)
            {
                return ageValueArray[row] as? String
            }
            else
            {
                return "Years"
            }
           
        }
        return "N.A"
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
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
//extension String {
//    
//    subscript (i: Int) -> Character {
//        return self[self.startIndex.advancedBy(i)]
//    }
//    
//}
