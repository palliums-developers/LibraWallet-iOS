//
//  SettingViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/10/23.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import Localize_Swift
import MessageUI
import Device
class SettingViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置标题
        self.title = localLanguage(keyString: "wallet_setting_navigation_title")
        // 加载子View
        self.view.addSubview(self.detailView)
        // 加载数据
        self.getLocalData()
        // 添加语言变换通知
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        detailView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.top.equalTo(self.view)
            }
            make.left.right.bottom.equalTo(self.view)
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(LCLLanguageChangeNotification), object: nil)
        print("SettingViewController销毁了")
    }
    func getLocalData() {
        self.tableViewManager.dataModel = self.dataModel.getSettingLocalData()
        self.detailView.tableView.reloadData()
    }
    //网络请求、数据模型
    lazy var dataModel: SettingModel = {
        let model = SettingModel.init()
        return model
    }()
    //tableView管理类
    lazy var tableViewManager: SettingTableViewManager = {
        let manager = SettingTableViewManager.init()
        manager.delegate = self
        return manager
    }()
    //子View
    lazy var detailView : SettingView = {
        let view = SettingView.init()
        view.tableView.delegate = self.tableViewManager
        view.tableView.dataSource = self.tableViewManager
        return view
    }()
    @objc func setText() {
        // 设置标题
        self.title = localLanguage(keyString: "wallet_setting_navigation_title")
        // 加载数据
        self.getLocalData()
    }
}
extension SettingViewController: SettingTableViewManagerDelegate {
    func tableViewDidSelectRowAtIndexPath(indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let vc = LanguageViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            } else if indexPath.row == 1 {
                let vc = ServiceLegalViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = PrivateLegalViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if indexPath.section == 1 {
            let vc = AboutUsViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
//            let vc = HelpCenterViewController()
//            self.navigationController?.pushViewController(vc, animated: true)
            if MFMailComposeViewController.canSendMail() {
                let vc = MFMailComposeViewController()
                vc.mailComposeDelegate = self
                vc.setToRecipients(["violas_blockchain@violas.io"])
                vc.setSubject("Violas Feedback")
                vc.setMessageBody("\n\n\n\n-------------------\nApp version: \(appversion)\niPhone model: \(getVersionCode())\nOS version:\(iosversion)",
                                  isHTML: false)
                present(vc, animated: true, completion: nil)
            } else {
                print("Whoop...设备不能发送邮件")
//                showSendMailErrorAlert()
            }
        }
    }
}
extension SettingViewController: MFMailComposeViewControllerDelegate {
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
