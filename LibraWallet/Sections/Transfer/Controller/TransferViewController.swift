//
//  TransferViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/9/5.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import SwiftGRPC
import SwiftProtobuf
class TransferViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    var wallet: LibraWallet?
    @IBOutlet weak var AddressTextField: UITextField!
    @IBOutlet weak var AmountTextField: UITextField!
    var sequenceNumber: Int64? {
        didSet {

            
            guard let address = self.AddressTextField.text else {
                return
            }
            guard let amount = self.AmountTextField.text else {
                return
            }
            let request = LibraTransaction.init(receiveAddress: address, amount: Double(amount)!, wallet: self.wallet!, sequenceNumber: UInt64(self.sequenceNumber ?? 0))
            
            let channel = Channel.init(address: libraMainURL, secure: false)
            
            
            let client = AdmissionControl_AdmissionControlServiceClient.init(channel: channel)
            do {
                //           _ = try client.submitTransaction(mission, completion: { (Response, request) in
                //                print(Response?.acStatus as Any)
                //                print(request.resultData ?? "")
                //            })
                let response = try client.submitTransaction(request.request)
                print(response.acStatus.code)
                self.view.hideToastActivity()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

   
    
    @IBAction func scan(_ sender: Any) {
        let vc = ScanViewController()
        vc.actionClosure = { address in
            self.AddressTextField.text = address
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    @IBAction func confirm(_ sender: Any) {
//        let semaphore = DispatchSemaphore.init(value: 1)
//        semaphore.wait()
        self.view.makeToastActivity(.center)
        
        self.getBalance()
        
//        semaphore.signal()
        
    }
    func getBalance() {
        guard let tempWallet = self.wallet else {
            self.view.makeToast("请创建钱包", position: .center)
            return
        }
        let channel = Channel.init(address: libraMainURL, secure: false)
//        let channel = Channel.init(address: "18.220.66.235:34042", secure:  false)
        
        
        let client = AdmissionControl_AdmissionControlServiceClient.init(channel: channel)
        do {
            var jjj = Types_GetAccountStateRequest()
            jjj.address = Data.init(hex: tempWallet.publicKey().toAddress())
            
            var item = Types_RequestItem()
            item.getAccountStateRequest = jjj
            
            var sequenceNumber = Types_UpdateToLatestLedgerRequest()
            sequenceNumber.requestedItems = [item]
            
            let gaaa = try client.updateToLatestLedger(sequenceNumber)
            
            guard let response = gaaa.responseItems.first else {
                return
            }
            let streamData = response.getAccountStateResponse.accountStateWithProof.blob.blob
            self.sequenceNumber = LibraAccount.init(accountData: streamData).sequenceNumber
            
        } catch {
            print(error.localizedDescription)
        }
    }
}
