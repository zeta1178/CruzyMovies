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
    
    var json_data_url = "http://cruzy.co/movlist12.json"
    var image_base_url = "http://cruzy.co/images/"
    
    var TableData:Array< datastruct > = Array < datastruct >()
    
    enum ErrorHandler:ErrorType
    {
        case ErrorFetchingResults
    }
    
    struct datastruct
    {
        var dthumb:String?
        var dname:String?
        var image:UIImage? = nil
        var durl:String?
        
        init(add: NSDictionary)
        {
            dthumb = add["mThumb"] as? String
            dname = add["mName"] as? String
            durl = add["mURL"] as? String
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
                load_image(image_base_url + data.dthumb!, imageview: cell.imageView!, index: indexPath.row)
            }
            else
            {
                cell.imageView?.image = TableData[indexPath.row].image
            }
            
            return cell
        }
    
    //try here Michael
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
            {
                showTutorial(indexPath.row)
            }
    
    func showTutorial(which: Int) {
        if let url = NSURL(string: "http://cruzy.co/images/Frozen.mp4")
            //if let url = NSURL(string: data.durl)
        {
            let vc = SFSafariViewController(URL: url, entersReaderIfAvailable: true)
            presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    //try here Michael ends
    
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
                    try read()
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
                
                for (var i=0; i < fetchedResults.count; i+=1)
                    //for (i in 0 ..< fetchedResults.count)
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
    
    /*
        //external json array starts
     
        let requestURL: NSURL = NSURL(string: "http://cruzy.co/movlist5.json")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                print("Everyone is fine, file downloaded successfully.")
                
                do{
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    
                    
                    //creates moviesArray
                    if let movies = json["movies"] as? [[String: AnyObject]] {
                        
                        //for each movie in the moviesArray
                        for movie in movies {
                            
                            //find the movie name tag
                            if let mname = movie["mName"] as? String {
                                
                                //find the movie thumb tag
                                if let thumb = movie["mThumb"] as? String {
                                    
                                    //find the movie url tag
                                    if let url = movie["mURL"] as? String {
                                        
                                        //print(name,year)
                                        print(mname,thumb,url)
                                        
                                        //temp make array
                                        
                                     
                                    //end of movie url tag
                                    }
                                //end of movie thumb tag
                                }
                            //end of movie name tag
                            }
                        //end of for loop
                        }
                    //end of movies array
                    }
                //end of do while loop
                }
                
                catch {
                    print("Error with Json: \(error)")
                //end of catch
                }
            //end of if for JSON download
            }
        //end of task
        }
        
        task.resume()
        
        //external json array ends
    */
        
        
    //end of viewDidLoad()

}