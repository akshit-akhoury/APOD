//
//  ViewController.swift
//  APOD
//
//  Created by Akshit Akhoury on 22/05/22.
//

import UIKit

struct APIResponse:Decodable
{
    let date:String?
    let explanation:String
    let hdurl:URL
    let media_type:String
    let copyright:String?
    let title:String
    let url:URL
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let activityView = UIActivityIndicatorView.init(frame: self.view.bounds)
        self.view.addSubview(activityView)
        let imageView = UIImageView.init(frame: self.view.safeAreaLayoutGuide.layoutFrame)
        imageView.contentMode = .scaleAspectFit
        self.view.addSubview(imageView)
        
        let date = Date()
        let dateDecoder = DateFormatter()
        dateDecoder.dateFormat = "yyyy-MM-dd"
        let today = dateDecoder.string(from: date)
        let yesterday = dateDecoder.string(from: date.dayBefore)
        print(today)
        print(yesterday)
        let cachedData = UserDefaults.standard.object(forKey: today)
        if(cachedData != nil && false)
        {
            imageView.image = UIImage(data: (cachedData as? Data)!)
        }
        else
        {
            let url = URL(string: "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&date="+yesterday)!
            let urlTask = URLSession.shared.dataTask(with: url) { data, resp, err in
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
                        let imageTask = URLSession.shared.dataTask(with: resp.hdurl) { imageData, response, error in
                            guard let imageData = imageData else {
                                return
                            }
                            
                            DispatchQueue.main.async
                            {
                                imageView.image = UIImage(data: imageData)
                                UserDefaults.standard.set(imageData, forKey: today)
                                activityView.stopAnimating()
                            }
                        }
                        imageTask.resume()
                        DispatchQueue.main.async {activityView.startAnimating()}
                    }
                    catch {
                        print(error)
                    }
                }
            }
            urlTask.resume()
        }
    }
}

extension Date
{
    static var yesterday: Date { return Date().dayBefore }
    var dayBefore: Date
    {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var noon: Date
    {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
}
