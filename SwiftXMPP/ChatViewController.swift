//
//  ChatViewController.swift
//  SwiftXMPP
//
//  Created by Felix Grabowski on 10/06/14.
//  Copyright (c) 2014 Felix Grabowski. All rights reserved.
//

import UIKit
import XMPPFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageDelegate {
    
    @IBOutlet var messageField: UITextField?
    @IBOutlet var container : UIView!
    @IBOutlet var bottomContainerConstraint : NSLayoutConstraint?
    var chatWithUser: String = "teste03@local"
    @IBOutlet var tView: UITableView?
    var messages: NSMutableArray = []
    
    //  init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    //    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    //    // Custom initialization
    //  }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tView!.dataSource = self
        tView!.delegate = self
        //self.messageField.becomeFirstResponder()
        var del = appDelegate()
        del.messageDelegate = self
        messageField!.becomeFirstResponder()
        
        // Do any additional setup after loading the view.
        
        registerForKeyboardNotifications()
        
    }
    
    func registerForKeyboardNotifications () {
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        nc.addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWasShown(aNotification: NSNotification) {
        print("wohoo keyboards")
        var constraint = bottomContainerConstraint
        print("before: \(view.constraints)")
        var info: NSDictionary = aNotification.userInfo!
        var kbSize : CGRect = info.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue
        
        var visualString = "V:[container]-\(kbSize.height)-|"
        
        var newConstraint: NSArray = NSLayoutConstraint.constraintsWithVisualFormat(visualString, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["container" : container])
        
        view.removeConstraint(constraint!)
        view.addConstraints(newConstraint as! [NSLayoutConstraint])
        
        view.updateConstraints()
        
        print("\n after: \(view.constraints)")
        print("old constraint: \(constraint)")
        print("new constraint: \(newConstraint[0])")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func sendMessage() {
        var messageStr: String = messageField!.text!
        print(messageStr)
        if messageStr.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            var body = DDXMLElement.elementWithName("body") as! DDXMLElement
            body.setStringValue(messageStr)
            var message = DDXMLElement.elementWithName("message") as! DDXMLElement
            message.addAttributeWithName("type", stringValue: "chat")
            message.addAttributeWithName("to", stringValue: chatWithUser as String)
            message.addChild(body)
            xmppStream().sendElement(message)
            messageField!.text = ""
            
            var m: NSMutableDictionary = [:]
            m["msg"] = messageStr
            m["sender"] = "you"
            //      println("m: \(m) and message: \(messageStr)")
            
            messages.addObject(m)
            tView!.reloadData()
            
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var s = messages.objectAtIndex(indexPath.row) as! NSDictionary
        let cellIdentifier = "MessageCellIdentifier"
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if !(cell != nil) {
            cell = UITableViewCell(style: .Value1, reuseIdentifier: cellIdentifier)
        }
        
        if let c = cell {
            //      println(s)
            c.textLabel!.text = s["msg"] as? String
            c.detailTextLabel!.text = s["sender"] as? String
            c.accessoryType = .None
            c.userInteractionEnabled = false
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    @IBAction func closeChat() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func appDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    func xmppStream () -> XMPPStream {
        return appDelegate().xmppStream!
    }
    
    func newMessageReceived(messageContent: NSDictionary) {
        print("receivedMessage")
        messages.addObject(messageContent)
        tView!.reloadData()
        var topIndexPath = NSIndexPath(forRow: (messages.count - 1), inSection: 0)
        tView!.scrollToRowAtIndexPath(topIndexPath, atScrollPosition: .Middle, animated: true)
    }
    
    
    
    
    
    
    
    /*
    // #pragma mark - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}
