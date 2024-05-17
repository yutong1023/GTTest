import UIKit

class FriendsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var mainTableView: UITableView!
//    private var viewModel = FriendsViewModel()
    @IBOutlet weak var atmBarBtn: UIBarButtonItem!
    @IBOutlet weak var sTransBarBtn: UIBarButtonItem!
    @IBOutlet weak var scanBarBtn: UIBarButtonItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var okIdBtn: UIButton!
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainTableViewBottomConstraint: NSLayoutConstraint!
    
    var originSearchBarHeightConstant:CGFloat = 0
    var originAddFriendButtonHeightConstant:CGFloat = 0
    var originalTableViewBottomConstant:CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        AppDelegate.friendVC = self
        // Do any additional setup after loading the view.
//        AppDelegate.friendsVM.fetchPersonData(from: "https://dimanyen.github.io/man.json") { [weak self] success in
//            if success {
//                DispatchQueue.main.async {
//                    self?.nameLabel.text = AppDelegate.friendsVM.person?.name
//                    self?.okIdBtn.setTitle("KOKO ID : \(AppDelegate.friendsVM.person?.kokoid ?? "設定")", for: .normal)
//                }
//            }
//        }
        nameLabel.text = AppDelegate.friendsVM.person?.name
        okIdBtn.setTitle("KOKO ID : \(AppDelegate.friendsVM.person?.kokoid ?? "設定")", for: .normal)
        atmBarBtn.tintColor = dotView.backgroundColor
        sTransBarBtn.tintColor = dotView.backgroundColor
        scanBarBtn.tintColor = dotView.backgroundColor
        dotView.layer.cornerRadius = dotView.bounds.width/2
        searchBar.backgroundImage = UIImage()
        
        // 設置下拉更新控件
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        mainTableView.separatorStyle = .none
        mainTableView.refreshControl = refreshControl

        // 加載資料
//        loadData()
        // 注册键盘弹出和收起的通知
        originSearchBarHeightConstant = searchBarHeightConstraint.constant
        originalTableViewBottomConstant = mainTableViewBottomConstraint.constant
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func refreshData(_ sender: UIRefreshControl) {
        // 重新載入資料
        loadData()
    }

    func loadData() {
        resetMainData()
    }

    var mainData:[Any] = []
//    var searchData:[String] = []
    var searchMode:Bool? { didSet{
        if searchMode! {
            searchBarHeightConstraint.constant = originSearchBarHeightConstant
        } else {
            searchBarHeightConstraint.constant = 0
        }
        searchBarView.isHidden = !searchMode!
    }}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchMode = false
        resetMainData()
    }
    
    func resetMainData() {
        mainData = []
        mainData.append("FunctionCell")
        if AppDelegate.moneyVC?.stateSegCtrl.selectedSegmentIndex == 0 {
            mainData.append("NoFriendCell")
        } else {
            mainData.append("SearchCell")
        }
        mainTableView.reloadData()
        AppDelegate.moneyVC?.fetchJSONData(AppDelegate.moneyVC?.stateSegCtrl.selectedSegmentIndex ?? 0)
    }
    
    func refreshMainTable() {
        self.mainTableView.reloadData()
        // 停止下拉更新控件
        self.mainTableView.refreshControl?.endRefreshing()
        // 自動收合下拉更新控件
//        self.mainTableView.setContentOffset(CGPoint(x: 0, y: 0 - (self.mainTableView.contentInset.top)), animated: true)

    }
    
    func resetFriendsTable() {
        let counts = [AppDelegate.friendsVM.invitedFriends.count, 100]
        for (index, value) in mainData.enumerated() {
            if let oldValue = value as? String, oldValue == "FunctionCell" {
                mainData[index] = counts
                break
            }
        }

        if self.mainData.last is String {
            self.mainData.append(AppDelegate.friendsVM.friends)
        } else if self.mainData.last != nil {
            self.mainData[self.mainData.count-1] = AppDelegate.friendsVM.friends
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // 根據搜尋文字篩選好友列表
        if searchText.isEmpty {
            // 如果搜索文字為空，使用原始的好友列表資料
            mainData[mainData.count - 1] = AppDelegate.friendsVM.friends
        } else {
            // 根據搜尋文字篩選好友列表
            if let friends = mainData.last as? [Friend] {
                let filteredFriends = friends.filter { $0.name.lowercased().contains(searchText.lowercased()) }
                mainData[mainData.count - 1] = searchMode! ? filteredFriends :friends
            }
        }
        mainTableView.reloadData()
    }
    
    //MARK: - UITableView
    func numberOfSections(in tableView: UITableView) -> Int {
        print("mainData: \(mainData)")
        return searchMode! ? 1 : mainData.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchMode! {
            searchBar.becomeFirstResponder()
            return (mainData[mainData.count-1] as? [Friend])?.count ?? 1
        }
        if let secName = mainData[section] as? String {
            return secName == "InvitedCell" ? 0 : 1
        } else if let friends = mainData[section] as? [Friend] {
            return friends.count
        }
        return 1
    }

    var searchCell:SearchCell?
    var searchIndexPath:IndexPath?
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchMode! {
            return mainFriendCell(IndexPath(row: indexPath.row, section: mainData.count-1))
        }
        if let secName = mainData[indexPath.section] as? String {
            if secName == "SearchCell" {
                searchIndexPath = indexPath
                let cell = tableView.dequeueReusableCell(withIdentifier: secName, for: indexPath) as! SearchCell
                cell.friendsVC = self
                cell.searchBar.text = searchBar.text
                searchCell = cell
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: secName, for: indexPath)
            return cell
        } else if let friends = mainData[indexPath.section] as? [Friend] {
            if indexPath.section == tableView.numberOfSections-1 {
                return mainFriendCell(indexPath)
            } else {
                if collapsedIndexPaths.count == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "InvitedCell", for: indexPath) as! InvitedCell
                    cell.setData(friend: friends[indexPath.row])
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CollapsedCell", for: indexPath) as! CollapsedCell
                    cell.setData(friend: friends.first!)
//                    collapsedIndexPaths.removeAll()
                    return cell
                }
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FunctionCell", for: indexPath) as! FunctionCell
            cell.setCounts(mainData[indexPath.section] as! [Int])
            return cell
        }
    }
    
    func mainFriendCell(_ indexPath:IndexPath) -> UITableViewCell{
        if let friends = mainData[indexPath.section] as? [Friend] {
            let friend = friends[indexPath.row]
            if friend.status == 1 {
                let cell = mainTableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendCell
                cell.setData(friend: friend)
                return cell
            }
            let cell = mainTableView.dequeueReusableCell(withIdentifier: "InvitingCell", for: indexPath) as! InvitingCell
            cell.setData(friend: friend)
            return cell
        }
        return mainTableView.dequeueReusableCell(withIdentifier: "noDataCell", for: indexPath)
    }
    
    var collapsedIndexPaths: [IndexPath] = []
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchMode = false
        searchBar.resignFirstResponder()
        if tableView.cellForRow(at: indexPath) is CollapsedCell {
            collapsedIndexPaths.removeAll()
//            collapsedIndexPaths.removeAll(where: { $0 == indexPath })
            expandCells(at: indexPath)
        } else if tableView.cellForRow(at: indexPath) is InvitedCell {
            tableView.deselectRow(at: indexPath, animated: true)
            
            if collapsedIndexPaths.contains(indexPath) {
                // 如果已經是收合的狀態，則展開
//                collapsedIndexPaths.removeAll(where: { $0 == indexPath })
//                expandCells(at: indexPath)
            } else {
                // 如果是展開的狀態，則收合
//                collapsedIndexPaths.append(indexPath)
//                collapseCells(at: indexPath)
            }
            collapsedIndexPaths.removeAll()
            collapsedIndexPaths.append(indexPath)
            collapseCells(at: indexPath)
        }
        mainTableView.reloadData()
    }

    // 收合UITableViewCell
    func collapseCells(at indexPath: IndexPath) {
        print("collapseCells at: \(indexPath)")
        // 要收合的cell的index
        var indexPathsToRemove: [IndexPath] = []
        for i in 1..<AppDelegate.friendsVM.invitedFriends.count {
            indexPathsToRemove.append(IndexPath(row: i, section: indexPath.section))
        }
        
        // 從mainData中刪除相應的數據行
        if let friends = mainData[indexPath.section] as? [Friend] {
            mainData[indexPath.section] = [friends[indexPath.row]]
        }
        
        // 執行收合的動畫
        mainTableView.beginUpdates()
        print("indexPathsToRemove: \(indexPathsToRemove)")
        mainTableView.deleteRows(at: indexPathsToRemove, with: .fade)
        mainTableView.endUpdates()
    }

    // 展開UITableViewCell
    func expandCells(at indexPath: IndexPath) {
        // 要展開的cell的index
        var indexPathsToAdd: [IndexPath] = []
        for i in 0..<AppDelegate.friendsVM.invitedFriends.count {
            indexPathsToAdd.append(IndexPath(row: i, section: indexPath.section))
        }
        
        if let friends = AppDelegate.friendsVM.invitedFriends as [Friend]? {
            mainData[indexPath.section] = friends
        }
        
        // 執行展開的動畫
        mainTableView.beginUpdates()
        mainTableView.deleteRows(at: [IndexPath(row: 0, section: indexPath.section)], with: .none)
        mainTableView.insertRows(at: indexPathsToAdd, with: .fade)
        mainTableView.endUpdates()
    }
    
    func scrollSearchCellToTop() {
        mainTableView.scrollToRow(at: searchIndexPath!, at: .top, animated: true)
    }
    
    func startSearch(){
        searchMode = true
        mainTableView.reloadData()
    }
    
    func endSearch(){
        searchMode = false
        mainTableView.reloadData()
    }

    // 键盘弹出时调整底部约束
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            // 更新 mainTableView 的底部约束
            mainTableViewBottomConstraint.constant = keyboardHeight - (tabBarController?.tabBar.frame.height ?? 0)
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        searchMode = true
//        mainTableView.reloadData()
//        scrollSearchCellToTop()
    }

    // 键盘收起时恢复底部约束
    @objc func keyboardWillHide(_ notification: Notification) {
        // 恢复原始底部约束
        mainTableViewBottomConstraint.constant = originalTableViewBottomConstant
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        searchMode = false
    }

}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        let image = image(withColor: color)
        setBackgroundImage(image, for: state)
    }

    private func image(withColor color: UIColor) -> UIImage {
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}


//MARK: - UITableViewCell
class FunctionCell: UITableViewCell {
    @IBOutlet weak var friendButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var friendBarView: UIView!
    @IBOutlet weak var chatBarView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        friendButton.setBackgroundColor(.clear, for: .selected)
        friendButton.setTitleColor(.label, for: .selected)
        chatButton.setBackgroundColor(.clear, for: .selected)
        chatButton.setTitleColor(.label, for: .selected)
        friendBarView.layer.cornerRadius = 2
        chatBarView.layer.cornerRadius = 2
        chatBarView.isHidden = true
        
        // 添加灰色分隔线
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor.gray.withAlphaComponent(0.2) // 设置分隔线的颜色
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separatorView)
        
        // 设置分隔线的约束
        separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
//        friendButton.titleLabel?.layer.borderColor = UIColor.red.cgColor
//        chatButton.titleLabel?.layer.borderColor = UIColor.red.cgColor
//        friendButton.titleLabel?.layer.borderWidth = 1
//        chatButton.titleLabel?.layer.borderWidth = 1
    }
    
    @IBAction func friendButtonTouchUpIn(_ sender: Any) {
//        friendButton.isSelected = true
        friendBarView.isHidden = false
//        chatButton.isSelected = false
        chatBarView.isHidden = true
    }
    
    @IBAction func chatButtonTouchUpIn(_ sender: Any) {
//        friendButton.isSelected = false
        friendBarView.isHidden = true
//        chatButton.isSelected = true
        chatBarView.isHidden = false
    }
        
    func createBadge(_ num:Int, onButton:UIButton) -> UILabel {
        let badgeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        badgeLabel.backgroundColor = UIColor(red: 249/255, green: 178/255, blue: 220/255, alpha: 1)
        badgeLabel.textColor = .white
        badgeLabel.font = UIFont.systemFont(ofSize: 12)
        badgeLabel.textAlignment = .center
        let badgeTxt = num>99 ? "+99" : "\(num)"
        badgeLabel.text = "\(badgeTxt)" // 設置badge的文字
        badgeLabel.layer.cornerRadius = badgeLabel.bounds.height / 2
        badgeLabel.layer.masksToBounds = true
        badgeLabel.center = CGPoint(x: onButton.frame.maxX, y: onButton.frame.minY + badgeLabel.bounds.width/2)
        badgeLabel.sizeToFit()
        badgeLabel.frame.size.width += 8
        badgeLabel.isHidden = num == 0
        return badgeLabel
    }

    var friendBadge:UILabel?
    var chatBadge:UILabel?
    func setCounts(_ counts:[Int]){
        // 創建一個UILabel來表示badge
        friendBadge?.removeFromSuperview()
        friendBadge = createBadge(counts[0], onButton: friendButton)
        contentView.addSubview(friendBadge!)
        chatBadge?.removeFromSuperview()
        chatBadge = createBadge(counts[1], onButton: chatButton)
        contentView.addSubview(chatBadge!)
    }
}

class InvitedCell: UITableViewCell {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 6
        bgView.layer.shadowColor = UIColor.black.cgColor
        bgView.layer.shadowOpacity = 0.1
        bgView.layer.shadowOffset = CGSize(width: 0, height: 4)
        bgView.layer.shadowRadius = 16
    }
    
    func setData(friend: Friend) {
        nameLabel.text = friend.name
    }
}

class CollapsedCell: InvitedCell {
    @IBOutlet weak var collapsedView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collapsedView.layer.cornerRadius = 6
        collapsedView.layer.shadowColor = UIColor.black.cgColor
        collapsedView.layer.shadowOpacity = 0.1
        collapsedView.layer.shadowOffset = CGSize(width: 0, height: 4)
        collapsedView.layer.shadowRadius = 16
    }
}

class InvitingCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var startImgView: UIImageView!
    @IBOutlet weak var transButton: UIButton!
    @IBOutlet weak var invitingButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        transButton.layer.borderColor = transButton.tintColor.cgColor
        transButton.layer.borderWidth = 1
        
        invitingButton.layer.borderColor = invitingButton.tintColor.cgColor
        invitingButton.layer.borderWidth = 1

        let separatorView = UIView()
        separatorView.backgroundColor = UIColor.gray.withAlphaComponent(0.2) // 设置分隔线的颜色
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separatorView)
        
        // 设置分隔线的约束
//        separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
//        separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true // 设置分隔线的高度
        separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 90).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true

    }
    
    func setData(friend: Friend) {
        nameLabel.text = friend.name
        startImgView.isHidden = friend.isTop != "1"
    }
}

class FriendCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var startImgView: UIImageView!
    @IBOutlet weak var transButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        transButton.layer.borderColor = transButton.tintColor.cgColor
        transButton.layer.borderWidth = 1

        // 添加灰色分隔线
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor.gray.withAlphaComponent(0.2) // 设置分隔线的颜色
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separatorView)
        
        // 设置分隔线的约束
//        separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
//        separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true // 设置分隔线的高度
        separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 90).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true

    }
    
    func setData(friend: Friend) {
        nameLabel.text = friend.name
    }
}


class SearchCell: UITableViewCell, UISearchBarDelegate {
    var friendsVC:FriendsVC?
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        searchBar.backgroundImage = UIImage()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
//        friendsVC?.scrollSearchCellToTop()
        friendsVC?.startSearch()
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        friendsVC?.endSearch()
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // 根據搜尋文字篩選好友列表
        friendsVC?.searchBar(searchBar, textDidChange: searchText)
    }
}

class NoFriendCell: UITableViewCell {
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var setIdButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = addFriendButton.bounds
        gradientLayer.colors = [
            UIColor(red: 86/255, green: 179/255, blue: 11/255, alpha: 1).cgColor,
            UIColor(red: 166/255, green: 204/255, blue: 66/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 20
        addFriendButton.layer.insertSublayer(gradientLayer, at: 0)
        addFriendButton.backgroundColor = UIColor.white
        addFriendButton.layer.cornerRadius = 20.0
        addFriendButton.layer.shadowColor = UIColor(red: 121/255, green: 196/255, blue: 27/255, alpha: 0.4).cgColor
        addFriendButton.layer.shadowRadius = 8.0
        addFriendButton.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        addFriendButton.layer.shadowOpacity = 1.0
        addFriendButton.tintColor = UIColor.white

        let label = UILabel()
        label.text = addFriendButton.titleLabel?.text
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 16)
        label.frame = CGRect(x: 0, y: 0, width: addFriendButton.frame.width, height: addFriendButton.frame.height)
        addFriendButton.addSubview(label)

        let image = addFriendButton.imageView?.image
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleToFill
        imageView.frame = CGRect(x: addFriendButton.frame.width - 24-10, y: (addFriendButton.frame.height-24)/2, width: 24, height: 24)
        addFriendButton.addSubview(imageView)
        addFriendButton.setTitle("", for: .normal)
        addFriendButton.imageView?.isHidden = true
        
        // 創建一個NSAttributedString，給文字添加底線
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.foregroundColor: AppDelegate.friendVC?.dotView.backgroundColor ?? UIColor.systemPink,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)
        ]

        let attributedText = NSAttributedString(string: setIdButton.titleLabel!.text!, attributes: attributes)

        // 設置UIButton的標題為NSAttributedString
        setIdButton.setAttributedTitle(attributedText, for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}



//MARK: - ViewModel
class FriendsViewModel {
    var person: Person?
    var friends: [Friend] = []
    var invitedFriends:[Friend] = []

    func fetchPersonData(from url: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: url) else {
            print("Invalid URL")
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(false)
                return
            }

            do {
                let decoder = JSONDecoder()
                let responseData = try decoder.decode(Response<Person>.self, from: data)
                print("fetchFriendsData: \(responseData)")
                self?.person = responseData.response.first
                completion(true)
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                completion(false)
            }
        }.resume()
    }

    func fetchFriendsData(from url: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: url) else {
            print("Invalid URL")
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(false)
                return
            }

            do {
                let decoder = JSONDecoder()
                let responseData = try decoder.decode(Response<Friend>.self, from: data)
                print("fetchFriendsData: \(responseData)")
                self?.friends = responseData.response
                self!.invitedFriends = []
                var removeIs:[Int] = []
                for i in 0..<self!.friends.count {
                    if self!.friends[i].status == 2 {
                        self!.invitedFriends.append(self!.friends[i])
                        removeIs.insert(i, at: 0)
                    }
                }
                for i in removeIs {
                    self!.friends.remove(at: i)
                }
                completion(true)
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                completion(false)
            }
        }.resume()
    }
}

//MARK: - struct
struct Response<T: Decodable>: Decodable {
    let response: [T]
}

struct Person: Decodable {
    let name: String
    let kokoid: String
}

struct Friend: Decodable {
    let name: String
    let status: Int
    let isTop: String
    let fid: String
    let updateDate: String
}
