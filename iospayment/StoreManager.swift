//
//  StoreManager.swift
//  iospayment
//
//  Created by Takahiko Funakubo on 2023/05/15.
//

import Foundation
import StoreKit

class StoreManager: NSObject, SKPaymentTransactionObserver, ObservableObject {

    // 購入したいProductIdを定義する
    let productsIdentifiers: Set<String> = ["testitem"]
    
    enum Status {
        case Normal
        case Purchasing
    }
    
    @Published var products: [SKProduct] = []
    @Published var status : Status = Status.Normal
    @Published var receipt = "receiptがここに表示されます"
    
    // product情報を取得する
    override init() {
        super.init()
        let request = SKProductsRequest(productIdentifiers: productsIdentifiers)
        request.delegate = self
        request.start()
    }
    
    // 購入
    func purchaseProduct(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        status = Status.Purchasing
        SKPaymentQueue.default().add(payment)
    }
    
    // transactionsが変わるたびに呼ばれる
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                break
            case .purchased:
                completeTransaction(transaction)
            case .restored:
                restoreTransaction(transaction)
            case .deferred:
                break
            case .failed:
                failedTransaction(transaction)
            default:
                break
            }
        }
    }
    
    private func completeTransaction(_ transaction: SKPaymentTransaction) {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                let receiptString = receiptData.base64EncodedString(options: [])
                receipt = receiptString
                print(receipt)
            } catch {
                print("Couldn't read receipt data with error: " + error.localizedDescription)
            }
        }
        finishTransaction(transaction)
    }

    private func restoreTransaction(_ transaction: SKPaymentTransaction) {
        finishTransaction(transaction)
    }

    private func failedTransaction(_ transaction: SKPaymentTransaction) {
        finishTransaction(transaction)
    }
    
    func finishTransaction(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        status = Status.Normal
    }
}

extension StoreManager: SKProductsRequestDelegate {
    // product情報の取得完了
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
    }

}
