//
//  IAPManager.swift
//  Conjugator
//
//  Created by localadmin on 04.05.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import StoreKit
import Combine


final class ProductsDB: ObservableObject, Identifiable {
  
  static let shared = ProductsDB()
  var items:[SKProduct] = []
  {
      willSet {
        DispatchQueue.main.async {
          self.objectWillChange.send()
        }
      }
  }
}

class IAPManager: NSObject {
  
  static let shared = IAPManager()
  
//  var onReceiveProductsHandler: ((Result<[SKProduct], IAPManagerError>) -> Void)?
//  var onBuyProductHandler: ((Result<Bool, Error>) -> Void)?
  var totalRestoredPurchases: Int = 0
  
  private override init() {
    super.init()
  }
  
//  enum IAPManagerError: Error {
//    case noProductIDsFound
//    case noProductsFound
//    case paymentCancelled
//    case requestFailed
//  }
  
  func buyV5(product: SKProduct) {
    let payment = SKPayment(product: product)
    SKPaymentQueue.default().add(payment)
  }
  
//  func buy(product: SKProduct, withHandler handler: @escaping ((_ result: Result<Bool, Error>) -> Void)) {
//    let payment = SKPayment(product: product)
//    SKPaymentQueue.default().add(payment)
// 
//    // Keep the completion handler.
//    onBuyProductHandler = handler
//  }
  
  func canMakePayments() -> Bool {
    return SKPaymentQueue.canMakePayments()
  }
  
  func startObserving() {
    SKPaymentQueue.default().add(self)
  }
 
 
  func stopObserving() {
    SKPaymentQueue.default().remove(self)
  }
    
  func getProductsV5() {
    let productIDs = Set(returnProductIDs())
    let request = SKProductsRequest(productIdentifiers: Set(productIDs))
    request.delegate = self
    request.start()
  }
  
  func returnProductIDs() -> [String] {
    return ["ch.cqd.noun","ch.cqd.moreVerbs","ch.cqd.encoreVerbe"]
  }
  
  
//  func getProducts(withHandler productsReceiveHandler: @escaping (_ result: Result<[SKProduct], IAPManagerError>) -> Void) {
//    onReceiveProductsHandler = productsReceiveHandler
//    let productIDs = Set(getProductIDs()!)
//    let request = SKProductsRequest(productIdentifiers: Set(productIDs))
//    request.delegate = self
//    request.start()
//  }
//
//  fileprivate func getProductIDs() -> [String]? {
//    return ["ch.cqd.noun","ch.cqd.moreVerbs","ch.cqd.encoreVerbe"]
//  }
  
  func formatPrice(for product: SKProduct) -> String? {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = product.priceLocale
    return formatter.string(from: product.price)
  }
  
  func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
    if totalRestoredPurchases != 0 {
        purchasePublisher.send(("IAP: Purchases successfull restored!",true))
    } else {
        purchasePublisher.send(("IAP: No purchases to restore!",true))
    }
  }

  func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
    if let error = error as? SKError {
        if error.code != .paymentCancelled {
            purchasePublisher.send(("IAP Restore Error: " + error.localizedDescription,false))
        } else {
            purchasePublisher.send(("IAP Error: " + error.localizedDescription,false))
        }
    }
  }
  
  //  func paymentQueueRestoreCompletedTransactionsFinishedB(_ queue: SKPaymentQueue) {
//    if totalRestoredPurchases != 0 {
//        showIAPMessage.send("IAP: Purchases successfull restored!")
//        onBuyProductHandler?(.success(true))
//    } else {
//        showIAPMessage.send("IAP: No purchases to restore!")
//        onBuyProductHandler?(.success(false))
//    }
//  }
  
//  func paymentQueueB(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
//    if let error = error as? SKError {
//        if error.code != .paymentCancelled {
//            showIAPMessage.send("IAP Restore Error: " + error.localizedDescription)
//            onBuyProductHandler?(.failure(error))
//        } else {
//            showIAPMessage.send("IAP Error: " + error.localizedDescription)
//            onBuyProductHandler?(.failure(IAPManagerError.paymentCancelled))
//        }
//    }
//  }
  
  func restorePurchasesV5() {
    totalRestoredPurchases = 0
    SKPaymentQueue.default().restoreCompletedTransactions()
  }
  
//  func restorePurchases(withHandler handler: @escaping ((_ result: Result<Bool, Error>) -> Void)) {
//    onBuyProductHandler = handler
//    totalRestoredPurchases = 0
//    SKPaymentQueue.default().restoreCompletedTransactions()
//  }
  
  func purchaseV5(product: SKProduct) -> Bool {
    if !IAPManager.shared.canMakePayments() {
        return false
    } else {
      let payment = SKPayment(product: product)
      SKPaymentQueue.default().add(payment)
    }
    return true
  }
  
//  func purchase(product: SKProduct) -> Bool {
//    if !IAPManager.shared.canMakePayments() {
//        return false
//    } else {
//        IAPManager.shared.buy(product: product) { (result) in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(_):
//                  print("ok ",product.productIdentifier)
//                  purchasedPublisher.send(true)
////                  do update self.updateGameDataWithPurchasedProduct(product)
//                case .failure(let error):
//                  print("error ",error.localizedDescription)
////                  purchasedGoodPublisher.send(false)
//                  showIAPError.send(error.localizedDescription)
////                    show error self.delegate?.showIAPRelatedError(error)
//                }
//            }
//        }
//        return true
//    }
//   }
}


//extension IAPManager.IAPManagerError: LocalizedError {
//    var errorDescription: String? {
//        switch self {
//        case .noProductIDsFound: return "No In-App Purchase product identifiers were found."
//        case .noProductsFound: return "No In-App Purchases were found."
//        case .requestFailed: return "Unable to fetch available In-App Purchase products at the moment."
//        case .paymentCancelled: return "In-App Purchase process was cancelled."
//        }
//    }
//}

extension IAPManager: SKProductsRequestDelegate, SKRequestDelegate {
  func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    let badProducts = response.invalidProductIdentifiers
    let goodProducts = response.products
    
    if goodProducts.count > 0 {
      ProductsDB.shared.items = response.products
      print("bon ",ProductsDB.shared.items)
    }
    
    print("badProducts ",badProducts)
    
//    let products = response.products
//    if products.count > 0 {
//      onReceiveProductsHandler?(.success(products))
//      for product in products {
//        print("success ",product.productIdentifier)
//      }
//    } else {
//      onReceiveProductsHandler?(.failure(.noProductsFound))
//      print("failure ")
//    }
//    if !response.invalidProductIdentifiers.isEmpty {
//      onReceiveProductsHandler?(.failure(.noProductIDsFound))
//      print("fucked ",response.invalidProductIdentifiers)
//    }
  }
  
  func request(_ request: SKRequest, didFailWithError error: Error) {
    print("didFailWithError ",error)
    purchasePublisher.send(("Purchase request failed ",true))
//    onReceiveProductsHandler?(.failure(.requestFailed))
  }
  
  func requestDidFinish(_ request: SKRequest) {
    print("request did finish ")
  }
  
}

extension IAPManager: SKPaymentTransactionObserver {
  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
     transactions.forEach { (transaction) in
      switch transaction.transactionState {
      case .purchased:
        SKPaymentQueue.default().finishTransaction(transaction)
        purchasePublisher.send(("Purchased ",true))
      case .restored:
        totalRestoredPurchases += 1
        SKPaymentQueue.default().finishTransaction(transaction)
        purchasePublisher.send(("Restored ",true))
      case .failed:
        if let error = transaction.error as? SKError {
          purchasePublisher.send(("Payment Error \(error.code) ",false))
          print("Payment Failed \(error.code)")
        }
        SKPaymentQueue.default().finishTransaction(transaction)
      case .deferred:
        print("Ask Mom ...")
        purchasePublisher.send(("Payment Diferred ",false))
      case .purchasing:
        print("working on it...")
        purchasePublisher.send(("Payment in Process ",false))
      default:
        break
      }
    }
  }
}


//  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//    transactions.forEach { (transaction) in
//      switch transaction.transactionState {
//      case .purchased:
//        onBuyProductHandler?(.success(true))
//        SKPaymentQueue.default().finishTransaction(transaction)
//      case .restored:
//        totalRestoredPurchases += 1
//        SKPaymentQueue.default().finishTransaction(transaction)
//      case .failed:
//        if let error = transaction.error as? SKError {
//          if error.code != .paymentCancelled {
//            onBuyProductHandler?(.failure(error))
//          } else {
//            onBuyProductHandler?(.failure(IAPManagerError.paymentCancelled))
//          }
//          print("IAP Error:", error.localizedDescription)
//        }
//        SKPaymentQueue.default().finishTransaction(transaction)
//      case .deferred, .purchasing: break
//        @unknown default: break
//      }
//    }
//  }
//}
