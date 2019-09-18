//
//  ViewController.swift
//  LibraWallet
//
//  Created by palliums on 2019/8/29.
//  Copyright © 2019 palliums. All rights reserved.
//

import UIKit
import CryptoSwift
import SwiftEd25519
import BigInt
import SwiftGRPC
import SwiftProtobuf
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var Balance: UILabel!
    @IBAction func Balance(_ sender: Any) {
        getBalance()
    }
    
    @IBAction func receive(_ sender: Any) {
        guard let tempWallet = self.wallet else {
            self.view.makeToast("请创建钱包", position: .center)
            return
        }
        let vc = WalletReceiveViewController()
        vc.wallet = tempWallet
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func createWallet(_ sender: Any) {
        do {
            let mnemonic = try LibraMnemonic.generate()
            //有钱助词
//            let mnemonic = ["net", "dice", "divide", "amount", "stamp", "flock", "brave", "nuclear", "fox", "aim", "father", "apology"]
            // 没钱助词
//            let mnemonic = ["legal", "winner", "thank", "year", "wave", "sausage", "worth", "useful", "legal", "winner", "thank", "year", "wave", "sausage", "worth", "useful", "legal", "will"]

            guard self.wallet == nil else {
                self.view.makeToast("已创建钱包", position: .center)
                return
            }
            
            let seed = try LibraMnemonic.seed(mnemonic: mnemonic)
            let wallet = LibraWallet.init(seed: seed)
            self.wallet = wallet
            self.view.makeToast("创建成功", position: .center)
        } catch {
            print(error.localizedDescription)
        }
        
    }
    var sequenceNumber: Int?
    var wallet: LibraWallet?
    func getTransactionHistory() {
    }
    func getBalance() {
        guard let tempWallet = self.wallet else {
            self.view.makeToast("请创建钱包", position: .center)
            return
        }
        let channel = Channel.init(address: libraMainURL, secure:  false)
        
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

            let balance = LibraAccount.init(accountData: streamData).balance
            self.Balance.text = "\(balance ?? 0)"
            
        } catch {
            print(error.localizedDescription)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Transfer" {
//            let resultsViewController = segue.destination as! TransferViewController
//            resultsViewController.wallet = self.wallet
            
        }
    }
}
