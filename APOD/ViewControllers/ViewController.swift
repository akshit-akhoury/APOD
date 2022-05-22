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
            let archivedData = try NSKeyedArchiver.archivedData(withRootObject: cacheData, requiringSecureCoding: true)
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
        let url = URL(string: "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY")!
        let urlTask = URLSession.shared.dataTask(with: url) { [weak self] data, resp, err in
            guard let self = self else { return }
            guard let response = resp as? HTTPURLResponse else {return}
            if(err == nil && response.statusCode >= 200 && response.statusCode <= 299)
            {
                guard let data = data else {
                    return
                }
                let jsonDecoder = JSONDecoder()
                do
                {
                    let apiResponse = try jsonDecoder.decode(APIResponse.self, from: data)
                    print(apiResponse.title)
                    DispatchQueue.main.async
                    { [self] in
                        self.title = apiResponse.title
                        self.copyrightLabel.text = apiResponse.copyright ?? ""
                        self.explanationTextView.text = apiResponse.explanation
                    }
                    self.fetchImageFromAPIResponse(apiResponse)
                }
                catch {
                    self.presentAlert(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription)
                }
            }
            else
            {
                self.presentAlert(title: NSLocalizedString("Invalid response", comment: ""), message: "Code: \(response.statusCode)")
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
    
    fileprivate func configureWithCachedData(_ cachedData: Any?) {
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        imageView.contentMode = .scaleAspectFit
        activityView.hidesWhenStopped = true
        getDates()
        let connected = NetworkMonitor.shared.connected
        let todayData = UserDefaults.standard.object(forKey: today!)
        //Check if we already have today's data
        if(todayData != nil)
        {
            configureWithCachedData(todayData)
        }
        else if(!connected)
        {
            let yesterdayData = UserDefaults.standard.object(forKey: yesterday!)
            if(yesterdayData != nil)
            {
                self.presentAlert(title: NSLocalizedString("No Internet", comment: ""), message: NSLocalizedString("We are not connected to the internet, showing you the last image we have.", comment: ""))
                configureWithCachedData(yesterdayData)
            }
            else
            {
                //show a different error
                self.presentAlert(title: NSLocalizedString("No Internet", comment: ""), message: NSLocalizedString("No internet and no stored image found!", comment: ""))
            }
        }
        else
        {
            fetchFromInternet()
        }
    }
}
