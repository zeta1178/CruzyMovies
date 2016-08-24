//
//  ViewController.swift
//  Test
//
//  Created by Michael Cruz on 8/23/16.
//  Copyright © 2016 Michael Cruz. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
@IBOutlet var tableview: UITableView!
    
    //your lifecycle code
    
    //temp array
    let myarray = ["item1", "item2", "item3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        

        
        
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
                                        //let array2 = [@mName,@mThumb,@mURL]
                                     
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
        
    //end of viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //1 snippet - NumberofRowsInSection Method
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //To be updated for movie array
        
        return myarray.count
    }
    //1 snippet end
    
    
    //2nd snippet - cellForRowAtIndexPath
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("customcell", forIndexPath: indexPath)
        //as! UITableViewCell
        cell.textLabel?.text = myarray[indexPath.item]
        return cell
    }
    //2nd snippet end
    
    //3 snippet
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableview.reloadData()
    }
    //3 snippet end

}



