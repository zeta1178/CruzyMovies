//
//  ViewController.swift
//  Test
//
//  Created by Michael Cruz on 8/23/16.
//  Copyright © 2016 Michael Cruz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
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
                               
                                //find the movie thumb tag
                                if let url = movie["mURL"] as? String {
                                
                                //print(name,year)
                                print(mname,thumb,url)
                                    
                                    }
                                }
                                
                            }
                        }
                        
                    }
                    
                }catch {
                    print("Error with Json: \(error)")
                }
                
            }
        }
        
        task.resume()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

