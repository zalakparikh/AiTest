//
//  ViewController.swift
//  ExamAi
//
//  Created by PCQ183 on 05/08/19.
//  Copyright © 2019 PCQ183. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    //MARK:- IBOutlet
    @IBOutlet private weak var tableViewDetail  : UITableView!
    @IBOutlet private var viewFooter            : UIView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    
    //MARK:- Variables
    private var postData        : [PostModel]           = []
    private var pageCount       : Int                   = 0
    private var isPageCompleted : Bool!                 = false
    private var refreshControl  : UIRefreshControl?


    //MARK:- ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshControl?.beginRefreshing()
        pageCount = 0
        callPostAPI()
    }

    //MARK:- Setup Methods
    private func prepareView() {
        self.setNavigationTitle()
        self.addRefreshControl()
    }
    
    //MARK:-
    private func setNavigationTitle()  {
        let arrPostDataFilter = self.postData.filter { (post) -> Bool in
            return post.isPostSelected
        }
        if arrPostDataFilter.count == 0 {
            self.title = "Number of selected posts: 0"
        } else {
            self.title = arrPostDataFilter.count > 1 ? "Number of selected posts: " + "\(arrPostDataFilter.count)" : "Number of selected post: " + "\(arrPostDataFilter.count)"
        }
    }
    
    // MARK:- Refresh Control Methods
    private func addRefreshControl() {
        if self.refreshControl == nil
        {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
            self.refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
            self.tableViewDetail.addSubview(self.refreshControl!)
        }
    }
    
    @objc private func pullToRefresh() {
        self.pageCount = 0
        self.callPostAPI()
    }
    
}
 //MARK:- API methods
extension ViewController {
   
    private func callPostAPI() {
        
        let sourceURL = "https://hn.algolia.com/api/v1/search_by_date?tags=story&page=" + "\(self.pageCount)"
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        Alamofire.request(sourceURL, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            switch(response.result) {
            case .success(let value):
                let json = JSON(value)
                
                if self.pageCount == 0 {
                    self.refreshControl?.endRefreshing()
                    self.postData.removeAll()
                    self.setNavigationTitle()
                }
                
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 200:
                        let postList: Array<JSON> = json["hits"].arrayValue
                        let totalCount = json["nbPages"].intValue
                        
                        if self.pageCount < totalCount {
                            self.isPageCompleted = false
                            for i in 0..<postList.count {
                                let dictPost = JSON(postList[i].dictionaryValue)
                                let post = PostModel.init(dictionary: dictPost)
                                self.postData.append(post)
                            }
                            self.activityIndicator.stopAnimating()
                        } else {
                            self.isPageCompleted = true
                        }
                        self.tableViewDetail.reloadData()
                        break
                    default:
                        break
                    }
                }
                break
            case .failure:
                print("Failure")
                self.refreshControl?.endRefreshing()
                break
            }
        }
    }
}
 //MARK:- Tableview Delegates
extension ViewController : UITableViewDelegate , UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailTableCell", for: indexPath) as! DetailTableCell
        cell.postData = self.postData[indexPath.row]
        if indexPath.row == self.postData.count - 1 && !self.isPageCompleted {
            pageCount = pageCount + 1
            activityIndicator.startAnimating()
            self.callPostAPI()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = self.postData[indexPath.row]
        post.isPostSelected = !post.isPostSelected
        tableView.reloadRows(at: [indexPath], with: .automatic)
        self.setNavigationTitle()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if self.isPageCompleted == true || self.postData.count == 0 {
            return UIView()
        }
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.isPageCompleted == true || self.postData.count == 0 {
            return 0.0001
        }
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
}
