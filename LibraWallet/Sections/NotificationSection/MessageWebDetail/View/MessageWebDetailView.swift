//
//  MessageWebDetailView.swift
//  LibraWallet
//
//  Created by wangyingdong on 2021/1/12.
//  Copyright © 2021 palliums. All rights reserved.
//

import UIKit
import WebKit

class MessageWebDetailView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(webView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("MessageWebDetailView销毁了")
    }
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        webView.snp.makeConstraints { (make) in
//            make.top.equalTo(spaceLabel.snp.bottom).offset(20)
            make.top.equalTo(self)
            make.left.right.bottom.equalTo(self)
        }
    }
    // MARK: - 懒加载对象
    lazy var webView: WKWebView = {
        let webView = WKWebView.init()
        // 下面一行代码意思是充满的意思(一定要加，不然也会显示有问题)
        webView.autoresizingMask = [.flexibleHeight]
        return webView
    }()
    var model: MessageWebDetailModelDataModel? {
        didSet {
            guard let tempModel = model else {
                return
            }
            let date = timestampToDateString(timestamp: tempModel.date ?? 0, dateFormat: "yyyy-MM-dd HH:mm")
//            span.accentTextColor {
//                color:red;
//            }
            let htmlString = """
                            <html>
                            <meta charset="utf-8">
                            <meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no">
                            <head>
                            <style type='text/css'>
                                h1 {
                                    color:#333333;
                                    font-size:16px;
                                }
                                h2 {
                                    color:#999999;
                                    font-size:12px;
                                }
                                hr {
                                    border-style: none;
                                    width:\(mainWidth - 30);
                                    height:0.5px;
                                    background: #E0E0E0
                                }
                                body {
                                    font-size: 14px;
                                }
                            </style>
                            </head>
                            <h1>
                            \(tempModel.title ?? "")
                            </h1>
                            <h2>
                            \(date + "  " + (tempModel.author ?? ""))
                            </h2>
                            <hr>
                            <body>
                            <script type='text/javascript'>
                                window.onload = function () {
                                    var $img = document.getElementsByTagName('img');
                                    for (var p in $img) {
                                        $img[p].style.width = '100%';
                                        $img[p].style.height = 'auto';
                                    }
                                }
                            </script>
                            <div>
                            \(tempModel.content ?? "")
                            </div>
                            </body>
                            </html>
                            """
            self.webView.loadHTMLString(htmlString, baseURL: nil)
        }
    }
}
extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}
