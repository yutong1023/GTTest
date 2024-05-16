import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the delegate to self if needed
        self.delegate = self
        
        // Create and set up your custom TabBar
        let customTabBar = CustomTabBar()
        self.setValue(customTabBar, forKey: "tabBar")
    }
    
    // Implement UITabBarControllerDelegate methods if needed
}

class CustomTabBar: UITabBar {
    
    var circularButton: UIButton!
    weak var customTabBarController: CustomTabBarController? // Keep a reference to the custom tab bar controller
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if circularButton == nil {
            setupCircularButton()
        }
    }
    
    func setupCircularButton() {
        let tabBarHeight = self.bounds.height
        let tabBarWidth = self.bounds.width
        let buttonSize = tabBarWidth/CGFloat(items!.count)
        let halfButtonSize = buttonSize / 2

        // Calculate the position for the circular button
        var buttonX: CGFloat
        var buttonY: CGFloat
        
        // Calculate the frame of the center tab bar item
        if let centerItem = items?[items!.count / 2].value(forKey: "view") as? UIView {
            let centerX = centerItem.frame.origin.x + centerItem.frame.size.width / 2
            let centerY = centerItem.frame.origin.y + centerItem.frame.size.height / 2
            buttonX = centerX - halfButtonSize
            buttonY = -20 //tabBarHeight - buttonSize
        } else {
            // If unable to calculate the center tab bar item, place the button at the center
            buttonX = (tabBarWidth - buttonSize) / 2
            buttonY = tabBarHeight - buttonSize
        }
        
        circularButton = UIButton(type: .custom)
        tintColor = UIColor(red: 236/255, green: 0, blue: 140/255, alpha: 12)
        circularButton.frame = CGRect(x: buttonX, y: buttonY, width: buttonSize, height: buttonSize)
//        circularButton.layer.cornerRadius = halfButtonSize
//        circularButton.backgroundColor = .white // Customize the appearance as needed
        circularButton.setImage(UIImage(named: "icTabbarHomeOff"), for: .normal)
        circularButton.addTarget(self, action: #selector(circularButtonTapped), for: .touchUpInside)
        self.addSubview(circularButton)
    }
    
    @objc func circularButtonTapped() {
        guard let tabBarVC = customTabBarController else {
            return
        }
        
        // Select the center tab bar item
        tabBarVC.selectedIndex = (tabBarVC.viewControllers?.count ?? 0) / 2
    }
}
