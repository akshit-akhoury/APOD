//
//  ViewController.swift
//  APOD
//
//  Created by Akshit Akhoury on 22/05/22.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var explanationTextView: UITextView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    var today:String?
    var yesterday:String?
    
    fileprivate func storeToCache(_ cacheData: ApodData)
    {
        do
        {
            let archivedData = try NSKeyedArchiver.archivedData(withRootObject: cacheData, requiringSecureCoding: false)
            UserDefaults.standard.set(archivedData, forKey: today!)
            UserDefaults.standard.removeObject(forKey: yesterday!)
        }
        catch
        {
            print(error)
        }
    }
    
    fileprivate func fetchImageFromAPIResponse(_ resp: APIResponse)
    {
        let imageTask = URLSession.shared.dataTask(with: resp.hdurl) { imageData, response, error in
            guard let imageData = imageData else {
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                self.imageView.image = UIImage(data: imageData)
                self.activityView.stopAnimating()
                let cacheData = ApodData(title: resp.title, explanation: resp.explanation, copyright: resp.copyright ?? "", imageData: imageData)
                self.storeToCache(cacheData)
            }
        }
        imageTask.resume()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.activityView.startAnimating()
        }
    }
    
    fileprivate func fetchFromInternet()
    {
        let url = URL(string: "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&date="+today!)!
        let urlTask = URLSession.shared.dataTask(with: url) { [weak self] data, resp, err in
            guard let self = self else { return }
            if(err == nil)
            {
                guard let data = data else {
                    return
                }
                let dec = JSONDecoder()
                do
                {
                    let resp = try dec.decode(APIResponse.self, from: data)
                    print(resp.title)
                    DispatchQueue.main.async
                    { [self] in
                        self.title = resp.title
                        self.copyrightLabel.text = resp.copyright ?? ""
                        self.explanationTextView.text = resp.explanation
                    }
                    self.fetchImageFromAPIResponse(resp)
                }
                catch {
                    print(error)
                }
            }
        }
        urlTask.resume()
    }
    
    fileprivate func getDates()
    {
        let date = Date()
        let dateDecoder = DateFormatter()
        dateDecoder.dateFormat = "yyyy-MM-dd"
        self.today = dateDecoder.string(from: date)
        self.yesterday = dateDecoder.string(from: date.dayBefore)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        imageView.contentMode = .scaleAspectFill
        activityView.hidesWhenStopped = true
        getDates()
        let cachedData = UserDefaults.standard.object(forKey: today!)
        if(cachedData != nil )
        {
            do
            {
                let decodedData = try NSKeyedUnarchiver.unarchivedObject(ofClass: ApodData.self, from: cachedData as! Data)
                guard let decodedData = decodedData else {
                    return
                }
                self.explanationTextView.text = decodedData.explanation
                self.copyrightLabel.text = decodedData.copyright
                self.title = decodedData.title
                self.imageView.image = UIImage(data: decodedData.imageData)
                
            }
            catch
            {
                //If we ran into issues with cache fetch, get it from the web
                fetchFromInternet()
            }
        }
        else
        {
            fetchFromInternet()
        }
    }
}
