//
//  ViewController.swift
//  NetFlixClone
//
//  Created by window1 on 2022/12/06.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray
        
        let vc1 = UINavigationController(rootViewController: HomeViewController())
        let vc2 = UINavigationController(rootViewController: UpcomingViewController())
        let vc3 = UINavigationController(rootViewController: SearchViewController())
        let vc4 = UINavigationController(rootViewController: DownloadViewController())
        let vc5 = UINavigationController(rootViewController: HistoryViewController())
        
        vc1.tabBarItem.image = UIImage(systemName: "house")
        vc2.tabBarItem.image = UIImage(systemName: "play.circle")
        vc3.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        vc4.tabBarItem.image = UIImage(systemName: "arrow.down.app")
        vc5.tabBarItem.image = UIImage(systemName: "clock")
        
        vc1.title = "홈"
        vc2.title = "공개예정"
        vc3.title = "찾기"
        vc4.title = "다운로드"
        vc5.title = "기록"
        
        tabBar.tintColor = .label
        setViewControllers([vc1, vc2, vc3, vc4], animated: true)
    }
}
