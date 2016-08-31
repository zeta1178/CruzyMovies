//
//  ViewController.swift
//  Test
//
//  Created by Michael Cruz on 8/23/16.
//  Copyright © 2016 Michael Cruz. All rights reserved.
//

import UIKit
import CoreData
import SafariServices

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,SFSafariViewControllerDelegate {
    
    ///new stuff from json table view images
    
    var json_data_url = "http://cruzy.co/list.json"
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
                for (var i = 0; i < list.count ; i+=1 )
                {
                    if let data_block = list[i] as? NSDictionary
                    {
                        
                        TableData.append(datastruct(add: data_block))
                    }
                }
                
                do
                {
                    //try read()
                    print("")
                }
                catch
                {
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
                    self.save(index,image: self.TableData[index].image!)
                    
                    imageview.image = self.TableData[index].image
                    return
                })
                
                
            }
            
            task.resume()
            
            
        }
        
        
        
        
        
    
        func read() throws
        {
            
            do
            {
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let managedContext = appDelegate.managedObjectContext!
                let fetchRequest = NSFetchRequest(entityName: "Images")
                
                let fetchedResults = try managedContext.executeFetchRequest(fetchRequest)
                
                for (var i=0; i < 0; i+=1)
                //for (var i=0; i < fetchedResults.count; i+=1)
                    
                {
                    let single_result = fetchedResults[i]
                    let index = single_result.valueForKey("index") as! NSInteger
                    let img: NSData? = single_result.valueForKey("image") as? NSData
                    
                    TableData[index].image = UIImage(data: img!)
                    
                }
                
            }
            catch
            {
                print("error")
                throw ErrorHandler.ErrorFetchingResults
            }
            
        }
  
        
        func save(id:Int,image:UIImage)
        {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            
            let entity = NSEntityDescription.entityForName("Images",
                                                           inManagedObjectContext: managedContext)
            let options = NSManagedObject(entity: entity!,
                                          insertIntoManagedObjectContext:managedContext)
            
            let newImageData = UIImageJPEGRepresentation(image,1)
            
            options.setValue(id, forKey: "index")
            options.setValue(newImageData, forKey: "image")
            
            do {
                try managedContext.save()
            } catch
            {
                print("error")
            }
            
        }
    
        override func viewDidAppear(animated: Bool) {
            super.viewDidAppear(animated)
            tableview.reloadData()
        }
    
    }