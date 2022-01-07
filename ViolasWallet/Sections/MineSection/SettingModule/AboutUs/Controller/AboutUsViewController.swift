//
//  AboutUsViewController.swift
//  HKWallet
//
//  Created by palliums on 2019/7/25.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import MessageUI
class AboutUsViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_about_us_navigation_title")
        // 加载子View
        self.view.addSubview(detailView)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalTo(self.view)
            }
            make.top.left.right.equalTo(self.view)
        }
    }
    // tableView管理类
    lazy var tableViewManager: AboutUsTableViewManager = {
        let manager = AboutUsTableViewManager.init()
        manager.delegate = self
        return manager
    }()
    // 子View
    private lazy var detailView : AboutUsView = {
        let view = AboutUsView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        return view
    }()
    deinit {
        print("AboutUsViewController销毁了")
    }
}
extension AboutUsViewController: AboutUsTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath, content: String) {
        if indexPath.row == 0 {
            UIApplication.shared.open(URL.init(string: content)!, options: [:], completionHandler: nil)
        } else if indexPath.row == 1 {
            if MFMailComposeViewController.canSendMail() {
                let vc = MFMailComposeViewController()
                vc.mailComposeDelegate = self
                vc.setToRecipients([content])
                vc.setSubject("Violas")
                vc.setMessageBody("\n\n\n\n-------------------\nApp version: \(appversion)\niPhone model: \(getVersionCode())\nOS version:\(iosversion)",
                                  isHTML: false)
                present(vc, animated: true, completion: nil)
            } else {
                print("Oops...设备不能发送邮件")
//                showSendMailErrorAlert()
            }
        }
    }
}
extension AboutUsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue{
        case MFMailComposeResult.sent.rawValue:
            print("邮件已发送")
        case MFMailComposeResult.cancelled.rawValue:
            print("邮件已取消")
        case MFMailComposeResult.saved.rawValue:
            print("邮件已保存")
        case MFMailComposeResult.failed.rawValue:
            print("邮件发送失败")
        default:
            print("邮件没有发送")
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
}
