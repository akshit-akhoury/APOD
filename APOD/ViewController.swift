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

class apodImage: NSObject,NSSecureCoding
{
    static var supportsSecureCoding: Bool {
           return true
    }
    
    let title:String
    let explanation:String
    let copyright:String
    let imageData:Data
    
    func encode(with coder: NSCoder)
    {
        coder.encode(title,forKey: "title")
        coder.encode(explanation,forKey: "explanation")
        coder.encode(copyright,forKey: "copyright")
        coder.encode(imageData,forKey: "imageData")
    }
    
    required init?(coder: NSCoder)
    {
        title = coder.decodeObject(forKey: "title") as? String ?? ""
        explanation = coder.decodeObject(forKey: "explanation") as? String ?? ""
        copyright = coder.decodeObject(forKey: "copyright") as? String ?? ""
        imageData = coder.decodeObject(forKey: "imageData") as? Data ?? Data()
    }
    
    init(title:String,explanation:String,copyright:String,imageData:Data)
    {
        self.title = title
        self.explanation = explanation
        self.copyright = copyright
        self.imageData = imageData
        super.init()
    }
    
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
        activityView.hidesWhenStopped = true
        
        let date = Date()
        let dateDecoder = DateFormatter()
        dateDecoder.dateFormat = "yyyy-MM-dd"
        let today = dateDecoder.string(from: date)
        let yesterday = dateDecoder.string(from: date.dayBefore)
        print(today)
        print(yesterday)
        let cachedData = UserDefaults.standard.object(forKey: today)
        if(cachedData != nil )
        {
            do
            {
                let decodedData = try NSKeyedUnarchiver.unarchivedObject(ofClass: apodImage.self, from: cachedData as! Data)
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
                print(error)
            }
        }
        else
        {
            let url = URL(string: "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY")!
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
                            self.copyrightLabel.text = resp.copyright ?? ""
                            self.explanationTextView.text = resp.explanation
                        }
                        let imageTask = URLSession.shared.dataTask(with: resp.hdurl) { imageData, response, error in
                            guard let imageData = imageData else {
                                return
                            }
                            
                            DispatchQueue.main.async
                            { [weak self] in
                                guard let self = self else {return}
                                self.imageView.image = UIImage(data: imageData)
                                self.activityView.stopAnimating()
                                let cacheData = apodImage(title: resp.title, explanation: resp.explanation, copyright: resp.copyright ?? "", imageData: imageData)
                                do
                                {
                                    let archivedData = try NSKeyedArchiver.archivedData(withRootObject: cacheData, requiringSecureCoding: false)
                                    UserDefaults.standard.set(archivedData, forKey: today)
                                    UserDefaults.standard.removeObject(forKey: yesterday)
                                }
                                catch
                                {
                                    print(error)
                                }
                            }
                        }
                        imageTask.resume()
                        DispatchQueue.main.async {
                            [weak self] in
                            guard let self = self else {return}
                            self.activityView.startAnimating()}
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
