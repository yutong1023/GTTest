//
//  MoneyVC.swift
//  GTTest
//
//  Created by yutong on 2024/2/29.
//

import UIKit

class MoneyVC: UIViewController {

    @IBOutlet weak var stateSegCtrl: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        AppDelegate.moneyVC = self
        AppDelegate.friendsVM.fetchPersonData(from: "https://dimanyen.github.io/man.json") { success in
            if success {
                DispatchQueue.main.async {
                    AppDelegate.friendVC?.nameLabel.text = AppDelegate.friendsVM.person?.name
                    AppDelegate.friendVC?.okIdBtn.setTitle("KOKO ID : \(AppDelegate.friendsVM.person?.kokoid ?? "設定")", for: .normal)
                }
            }
        }
        for i in 0...2 {
            fetchJSONData(i)
        }
    }
    
    func fetchJSONData(_ index:Int) {
        switch (index) {
        case 1:
            AppDelegate.friendsVM.fetchFriendsData(from: "https://dimanyen.github.io/friend2.json") {  success in
                if success {
                    DispatchQueue.main.async {
                        AppDelegate.friendVC?.resetFriendsTable()
                        AppDelegate.friendVC?.refreshMainTable()
                    }
                }
            }
        case 2:
            AppDelegate.friendsVM.fetchFriendsData(from: "https://dimanyen.github.io/friend3.json") { success in
                if success {
                    DispatchQueue.main.async {
                        if AppDelegate.friendsVM.invitedFriends.count > 0 {
                            AppDelegate.friendVC?.mainData.insert(AppDelegate.friendsVM.invitedFriends, at: 0)
                        }
                        AppDelegate.friendVC?.resetFriendsTable()
                        AppDelegate.friendVC?.refreshMainTable()
                    }
                }
            }
        default:
            AppDelegate.friendsVM.fetchFriendsData(from: "https://dimanyen.github.io/friend4.json") { success in
                if success {
                    DispatchQueue.main.async {
                        AppDelegate.friendVC?.mainTableView.reloadData()
                    }
                }
            }
        }
    }

}
