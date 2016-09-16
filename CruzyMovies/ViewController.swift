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
    
    enum ErrorHandler:Error
    {
        case errorFetchingResults
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
        
        tableview.dataSource = self
        tableview.delegate = self
        
        get_data_from_url(json_data_url)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let data = TableData[(indexPath as NSIndexPath).row]
        
        cell.textLabel?.text = data.dname
        if (data.image == nil)
        {
            cell.imageView?.image = UIImage(named:"image.jpg")
            load_image(image_base_url + data.dname! + ".jpg", imageview: cell.imageView!, index: (indexPath as NSIndexPath).row)
        }
        else
        {
            cell.imageView?.image = TableData[(indexPath as NSIndexPath).row].image
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        showVideo(TableData[(indexPath as NSIndexPath).row].dname!)
        //do_table_clear()
    }
    
    func showVideo(_ which: String)
    {
        
        if let url = URL(string: "http://cruzy.co/images/\(which)" + ".mp4")
        {
            let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
            present(vc, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return TableData.count
    }
    
    func get_data_from_url(_ url:String)
    {
        let url:URL = URL(string: url)!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let task = URLSession.shared.dataTask(with: request as URLRequest)
            {
            (data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response   , error == nil else {
                print("error")
                return
            }
            DispatchQueue.main.async(execute: {
                self.extract_json(data!)
                return
            })
        }
        task.resume()
    }
    
    func extract_json(_ jsonData:Data)
    {
        let json: AnyObject?
        do {
            json = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions()) as AnyObject?
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
        DispatchQueue.main.async(execute: {
            self.tableview.reloadData()
            return
        })
    }
    
    func load_image(_ urlString:String, imageview:UIImageView, index:NSInteger)
    {
        
        let url:URL = URL(string: urlString)!
        let session = URLSession.shared
        
        let task = session.downloadTask(with: url, completionHandler: {
            (location, response, error) in
            
            guard let _:URL = location, let _:URLResponse = response   , error == nil else {
                print("error")
                return
            }
            
            let imageData = try? Data(contentsOf: location!)
            
            DispatchQueue.main.async(execute: {
                
                self.TableData[index].image = UIImage(data: imageData!)
                imageview.image = self.TableData[index].image
                return
            })
        })
        task.resume()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableview.reloadData()
    }
    
}
