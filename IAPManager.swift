//
//  IAPManager.swift
//  Conjugator
//
//  Created by localadmin on 04.05.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import StoreKit
import Combine

class IAPManager: NSObject {
  
  static let shared = IAPManager()
  
  var onReceiveProductsHandler: ((Result<[SKProduct], IAPManagerError>) -> Void)?
  var onBuyProductHandler: ((Result<Bool, Error>) -> Void)?
  
  private override init() {
    super.init()
  }
  
  enum IAPManagerError: Error {
    case noProductIDsFound
    case noProductsFound
    case paymentWasCancelled
    case productRequestFailed
  }
  
  func buy(product: SKProduct, withHandler handler: @escaping ((_ result: Result<Bool, Error>) -> Void)) {
    let payment = SKPayment(product: product)
    SKPaymentQueue.default().add(payment)
 
    // Keep the completion handler.
    onBuyProductHandler = handler
  }
  
  func canMakePayments() -> Bool {
    return SKPaymentQueue.canMakePayments()
  }
  
  func startObserving() {
    SKPaymentQueue.default().add(self)
  }
 
 
  func stopObserving() {
    SKPaymentQueue.default().remove(self)
  }
  
  func getProducts(withHandler productsReceiveHandler: @escaping (_ result: Result<[SKProduct], IAPManagerError>) -> Void) {
    onReceiveProductsHandler = productsReceiveHandler
    guard let productIDs = getProductIDs() else {
      productsReceiveHandler(.failure(.noProductIDsFound))
      return
    }
    let request = SKProductsRequest(productIdentifiers: Set(productIDs))
    request.delegate = self
    request.start()
  }
  
  fileprivate func getProductIDs() -> [String]? {
    return ["ch.cqd.moreVerbs"]
  }
  
  func getPriceFormatted(for product: SKProduct) -> String? {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = product.priceLocale
    return formatter.string(from: product.price)
  }
  
  func purchase(product: SKProduct) -> Bool {
    if !IAPManager.shared.canMakePayments() {
        return false
    } else {
//        delegate?.willStartLongProcess()
        IAPManager.shared.buy(product: product) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                  print("ok ",product)
//                  do update self.updateGameDataWithPurchasedProduct(product)
                case .failure(let error):
                  print("error ",error)
//                    show error self.delegate?.showIAPRelatedError(error)
                }
            }
        }
        return true
    }
}
}

extension IAPManager.IAPManagerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noProductIDsFound: return "No In-App Purchase product identifiers were found."
        case .noProductsFound: return "No In-App Purchases were found."
        case .productRequestFailed: return "Unable to fetch available In-App Purchase products at the moment."
        case .paymentWasCancelled: return "In-App Purchase process was cancelled."
        }
    }
}

extension IAPManager: SKProductsRequestDelegate {
  func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    let products = response.products
    if products.count > 0 {
      onReceiveProductsHandler?(.success(products))
    } else {
      onReceiveProductsHandler?(.failure(.noProductsFound))
    }
  }
  
  func request(_ request: SKRequest, didFailWithError error: Error) {
    onReceiveProductsHandler?(.failure(.productRequestFailed))
  }
  
  func requestDidFinish(_ request: SKRequest) {
 
  }
  
}

extension IAPManager: SKPaymentTransactionObserver {
  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    transactions.forEach { (transaction) in
      switch transaction.transactionState {
      case .purchased:
        onBuyProductHandler?(.success(true))
        SKPaymentQueue.default().finishTransaction(transaction)
      case .restored:
        break
      case .failed:
        if let error = transaction.error as? SKError {
          if error.code != .paymentCancelled {
            onBuyProductHandler?(.failure(error))
          } else {
            onBuyProductHandler?(.failure(IAPManagerError.paymentWasCancelled))
          }
          print("IAP Error:", error.localizedDescription)
        }
        SKPaymentQueue.default().finishTransaction(transaction)
      case .deferred, .purchasing: break
      @unknown default: break
      }
    }
  }
}
