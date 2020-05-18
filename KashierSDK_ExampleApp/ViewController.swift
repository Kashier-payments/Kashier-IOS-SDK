//
//  ViewController.swift
//  PaymentSDK-Dev
//
//  Created by Meena on 4/21/20.
//  Copyright © 2020 Elements. All rights reserved.
//

import UIKit

import  KashierPaymentSDK

class ViewController: UIViewController {
	
	@IBOutlet weak var lblTemp: UILabel!
	@IBOutlet weak var switchTokenTypeTempPerm: UISwitch!
	@IBOutlet weak var lblPerm: UILabel!
	
	@IBOutlet weak var lblUse3DS_yes: UILabel!
	@IBOutlet weak var switch_3ds: UISwitch!
	@IBOutlet weak var lblUse3DS_no: UILabel!
	
	func setToken(_ token : Kashier.TOKEN_VALIDITY) -> Void {
		switch token {
			case .PERMANENT :
				tokenType = .PERMANENT
				switchTokenTypeTempPerm.isOn = true
			
			case .TEMPORARY:
				tokenType = .TEMPORARY
				switchTokenTypeTempPerm.isOn = false
		}
	}
	func set3Ds (_ isUsing3DS : Bool) -> Void {
		//		Logger.log(.i, "3DS: \(isUsing3DS)")
		if isUsing3DS {
			use3Ds = true
			switch_3ds.isOn = true
		}else {
			use3Ds = false
			switch_3ds.isOn = false
		}
		setCardData()
	}
	
	@IBAction func switchTokenTypeToggle(_ sender: Any) {
		setToken(switchTokenTypeTempPerm.isOn ? .PERMANENT : .TEMPORARY)
	}
	
	@IBAction func switchUse3Ds(_ sender: Any) {
		set3Ds(switch_3ds.isOn)
	}
	
	@objc func lbl_temp_pressed() {
		setToken(Kashier.TOKEN_VALIDITY.TEMPORARY)
	}
	@objc func lbl_perm_pressed() {
		setToken(Kashier.TOKEN_VALIDITY.PERMANENT)
	}
	@objc func lbl_3ds_yes_pressed() {
		set3Ds(true)
	}
	@objc func lbl_3ds_no_pressed() {
		set3Ds(false)
	}
	
	@IBAction func onNewOrderId(_ sender: Any) {
		orderId = generateRandomString()
		print( "New order ID: \(orderId)")
	}
	
	@IBAction func onNewShopper(_ sender: Any) {
		shopperReference = generateRandomString()
		print("New shopper reference: \(shopperReference)")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// MARK Initialization
		let lblTempTap = UITapGestureRecognizer(target: self, action: #selector(lbl_temp_pressed))
		let lblPermTap = UITapGestureRecognizer(target: self, action: #selector(lbl_perm_pressed))
		let lbl3dsYesTap = UITapGestureRecognizer(target: self, action: #selector(lbl_3ds_yes_pressed))
		let lbl3dsNoTap = UITapGestureRecognizer(target: self, action: #selector(lbl_3ds_no_pressed))
		
		lblTemp.isUserInteractionEnabled = true
		lblPerm.isUserInteractionEnabled = true
		lblUse3DS_no.isUserInteractionEnabled = true
		lblUse3DS_yes.isUserInteractionEnabled = true
		
		lblTemp.addGestureRecognizer(lblTempTap)
		lblPerm.addGestureRecognizer(lblPermTap)
		lblUse3DS_yes.addGestureRecognizer(lbl3dsYesTap)
		lblUse3DS_no.addGestureRecognizer(lbl3dsNoTap)
		
		//For proper initialization
		setToken(tokenType)
		set3Ds(use3Ds)
		setCardData()
		
		
		Kashier.initialize(merchantId: merchantId, apiKey:apiKey, sdkMode: sdkMode)
	}
	
	let _paymentCallback = PaymentCallback(onResponse: { (succ) -> (Void) in
		print("Payment with Token Success: \(succ.getResponseMessageTranslated())")
	}) { (error) -> (Void) in
		print("Payment with Token Error: \(error.getErrorMessage())")
	}
		
	func showTokensList(_ tokens : [Token]) -> Void {
		if tokens.count > 0 {
			func onTokenClickAction(_ token : Token) -> Void {
				print("Selected card token : \(token.token ?? "" )")
				Kashier.payWithPermToken(
					shopperReference: shopperReference,
					orderId: orderId,
					amount: Amount,
					cardToken: token.token ?? "",
					paymentCallback: PaymentCallback(onResponse: { (paymentResponse) -> (Void) in
						print("Payment with perm token success: \(paymentResponse.getResponseMessageTranslated())")
					}, onFailure: { (errorData) -> (Void) in
						print("Payment with perm token failed: \(errorData.getErrorMessage())")
					}))
			}
			
			let alert = UIAlertController(title: "Available Cards",
										  message: "You can select one of the cards to pay with token",
										  preferredStyle: .alert)
			
			for token in tokens {
				let tokenMessage = "\(token.cardNumber ?? "" ) - \(token.cardExpiryMonth ?? "")/\(token.cardExpiryYear ?? "" )\n\(token.token ?? "" )\n"
				let tokenButton = UIAlertAction(title:tokenMessage, style: .default,  handler: { (action) -> Void in
					onTokenClickAction(token)
				})
				alert.addAction(tokenButton)
			}
			let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
			alert.addAction(cancel)
			present(alert, animated: true, completion: nil)
		}
	}
	
	@IBAction func createToken(_ sender: Any) {
		Kashier.saveShopperCard(cardData: cardData,
								shopperReference: shopperReference,
								tokenValidity: tokenType,
								tokenizationCallback: TokenizationCallback(
									onResponse:{
										(TokenizationResponse) -> (Void) in
										
										debugPrint("Save Shopper Card Success")
										debugPrint("Card Token: \(TokenizationResponse.cardData?.cardToken ?? "")")
										debugPrint("CVV Token: \(TokenizationResponse.cardData?.ccvToken ?? "NO CCV TOKEN FOR PERM TOKENS")")
										cardToken = TokenizationResponse.cardData?.cardToken ?? ""
										ccvToken = TokenizationResponse.cardData?.ccvToken ?? ""
								},
									onFailure: {
										(tokenizationError :ErrorData) -> (Void) in

										debugPrint("Tokenization failed \(tokenizationError.getErrorMessage())")
								}
		))
	}
	@IBAction func listCards(_ sender: Any) {
		Kashier.listShopperCards(shopperReference:shopperReference,
								 userCallBack: TokensListCallback(
									onResponse: {
										(tokensResponse ) -> (Void) in
										debugPrint("Login Tokens List Resposne succ")
										if let _tokens = tokensResponse.response?.tokens {
											for token in _tokens {
												print("Card: \(token.cardNumber ?? "") \( token.cardExpiryMonth ?? "" )/\(token.cardExpiryYear ?? "") \(token.token ?? "")")
											}
											self.showTokensList( _tokens)
										}
								}, onFailure: {
									(tokensListError) -> (Void) in
									debugPrint("Error in tokens list response:  \(tokensListError.getErrorMessage())")
								}))
	}
	@IBAction func PayWithToken(_ sender: Any) {
		
		switch tokenType {
			case .PERMANENT:
				Kashier.payWithPermToken(
					shopperReference: shopperReference,
					orderId: orderId,
					amount: Amount,
					cardToken: cardToken,
					paymentCallback: _paymentCallback)
			case .TEMPORARY:
				Kashier.payWithTempToken(
					shopperReference: shopperReference,
					orderId: orderId,
					amount: Amount,
					cardToken: cardToken,
					cvvToken: ccvToken,
					paymentCallback: _paymentCallback)
		}
	}
	@IBAction func PayUsingCard(_ sender: Any) {
		Kashier.payWithCard(cardData: cardData,
							orderId: orderId,
							amount: Amount,
							shopperReference: shopperReference,
							shouldSaveCard: tokenType == .PERMANENT ,
							paymentCallback: _paymentCallback)
	}
	
}
