//
//  ViewController.swift
//  APOD
//
//  Created by Akshit Akhoury on 22/05/22.
//

import UIKit
import Network

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

    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var explanationTextView: UITextView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        imageView.contentMode = .scaleAspectFill
        
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
            let url = URL(string: "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&date=2022-05-17")!
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
                        DispatchQueue.main.async
                        { [self] in
                            self.title = resp.title
                            self.copyrightLabel.text = resp.copyright != nil ? "Copyright:"+resp.copyright! : ""
                            self.explanationTextView.text = resp.explanation
                        }
                        let imageTask = URLSession.shared.dataTask(with: resp.hdurl) { imageData, response, error in
                            guard let imageData = imageData else {
                                return
                            }
                            
                            DispatchQueue.main.async
                            { [self] in
                                imageView.image = UIImage(data: imageData)
                                UserDefaults.standard.set(imageData, forKey: today)
                                UserDefaults.standard.removeObject(forKey: yesterday)
                                activityView.stopAnimating()
                            }
                        }
                        imageTask.resume()
                        DispatchQueue.main.async { [self] in activityView.startAnimating()}
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
