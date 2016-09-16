//
//  ViewController.swift
//  CruzyMovies
//
//  Created by Michael Cruz on 8/23/16.
//  Copyright © 2016 Michael Cruz. All rights reserved.
//

import UIKit
import CoreData
import SafariServices

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,SFSafariViewControllerDelegate {
    
    ///new stuff from json table view images
    
    var json_data_url = "http://cruzy.co/list2.json"
    var image_base_url = "http://cruzy.co/images/"
    
    var TableData:Array< datastruct > = Array < datastruct >()
    
    enum ErrorHandler:ErrorType
    {
        case ErrorFetchingResults
    }
    
    struct datastruct
    {
        
        var dname:String?
        var image:UIImage? = nil
        
        init(add: NSDictionary)
        {
            
            dname = add["mName"] as? String
        }
    }
    
    
    
   @IBOutlet var tableview: UITableView!
  
   override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
    
        //new
        tableview.dataSource = self
        tableview.delegate = self
    
        get_data_from_url(json_data_url)
    
        }
    
    
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            
            let data = TableData[indexPath.row]
            

            cell.textLabel?.text = data.dname
            if (data.image == nil)
            {
                cell.imageView?.image = UIImage(named:"image.jpg")
                load_image(image_base_url + data.dname! + ".jpg", imageview: cell.imageView!, index: indexPath.row)
            }
            else
            {
                cell.imageView?.image = TableData[indexPath.row].image
            }
            
            return cell
        }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        showVideo(TableData[indexPath.row].dname!)
    }
    
    func showVideo(which: String)
    {
        
        if let url = NSURL(string: "http://cruzy.co/images/\(which)" + ".mp4")
            {
            let vc = SFSafariViewController(URL: url, entersReaderIfAvailable: true)
            presentViewController(vc, animated: true, completion: nil)
            
            }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            return TableData.count
        }
    
        
    func get_data_from_url(url:String)
        {
            
            
            let url:NSURL = NSURL(string: url)!
            let session = NSURLSession.sharedSession()
            
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
            
            
            let task = session.dataTaskWithRequest(request) {
                (
                let data, let response, let error) in
                
                guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                    print("error")
                    return
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.extract_json(data!)
                    return
                })
                
            }
            
            task.resume()
            
        }
        
        
        func extract_json(jsonData:NSData)
        {
            let json: AnyObject?
            do {
                json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: [])
            } catch {
                json = nil
                return
            }
            
            if let list = json as? NSArray
            {
                for i in (0..<list.count)
                {
                    if let data_block = list[i] as? NSDictionary
                    {
                        
                        TableData.append(datastruct(add: data_block))
                    }
                }
                
                do_table_refresh()
                
            }
            
            
        }
        
        
        func do_table_refresh()
        {
            dispatch_async(dispatch_get_main_queue(), {
                self.tableview.reloadData()
                return
            })
        }
        
        
        func load_image(urlString:String, imageview:UIImageView, index:NSInteger)
        {
            
            let url:NSURL = NSURL(string: urlString)!
            let session = NSURLSession.sharedSession()
            
            let task = session.downloadTaskWithURL(url) {
                (
                let location, let response, let error) in
                
                guard let _:NSURL = location, let _:NSURLResponse = response  where error == nil else {
                    print("error")
                    return
                }
                
                let imageData = NSData(contentsOfURL: location!)
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.TableData[index].image = UIImage(data: imageData!)
                    imageview.image = self.TableData[index].image
                    return
                })
                
                
            }
            
            task.resume()
            
            
        }
 
        override func viewDidAppear(animated: Bool) {
            super.viewDidAppear(animated)
            tableview.reloadData()
        }
    
    }