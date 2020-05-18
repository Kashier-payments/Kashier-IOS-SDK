![Kashier](https://uploads-ssl.webflow.com/5e7783f66312835b392f3113/5e7783f6631283939f2f3189_Group%25205330-p-500.png)

# Kashier-iOS-SDK
Create seamless checkout experience for your customers !



[Kashier](https://kashier.io/) is a payments platform built to empower 
and simplify your business by providing you with 
simple and efficient tools to make it easier to 
run your business.

- [Features](#Features)
- [Prerequisites](#Prerequisites)
- [API Documentation](https://test-api.kashier.io/api-docs/#/)
- [SDK Installation](#SDK-Installation)
- [Getting Started](#Getting-Started)
- [Save Shopper Card](#Save-Shopper-Card)
- [List Shopper Card](#List-Shopper-Card)
- [Pay With Token](#Pay-With-Token)
    - [Pay with Temp Token](#Pay-With-Temp-Token)
    - [Pay with Perm Token](#Pay-With-Perm-Token)
- [Payment with Card](#Payment-with-Card)
- [Payment with Form (Coming Soon)](#Payment-with-Form-(Coming-Soon))
- [Testing Data](#Testing-Data)
    - [Card Holder Name](#Card-Holder-Name)
    - [Test Cards](#Test-Cards)
        - [Card Numbers](#Card-Numbers)
        - [CVV](#CVV)
        - [Expiry Date](#Expiry-Date)
- [Data Models](#Data-Models)
- [Example App](#example-app)


## Features
- Pay via kashier Payment API
- Save user Card as Token (Perm/Temp)
- List user Cards
- Pay & Save Card via kashier API (One Action)
- Pay With Token via API (Perm/Temp)
<!-- - Pay via Kashier Form. (Coming Soon) -->

# Getting Started
## Prerequisites
You’ll need an **API Key**, and a **Merchant ID**.

To geth both
To get those 2 items:
- Login to your [dashboard](https://merchant.kashier.io/en/login)
- Go to **Integrate Now** -> **Customizable Forms** -> **Get the API key**. 
  - (Please make sure that you are using the right mode(Live/Test) before copying the API Key).
  - On the top-right corner of the dashboard, you will find your **MID**. 



### Verify Transaction Status
 - use the [**Authentication endpoint**](https://test-api.kashier.io/api-docs/#/Authenticate)
 -  Then, use [**Transactions endpoint**](https://test-api.kashier.io/api-docs/#/transactions) to get the transaction.
    - You will need your sent order id and the second parameter is the transaction id




## SDK Installation
Please note that all the methods are of type 'Void'

- Get our latest framework version from [Releases](https://github.com/Kashier-payments/Kashier-IOS-SDK/releases)
- Extract the .zip file to get the **.framework**
- Drag the .framework to your project 
![Add to project](./Docs/01-Add-to-project.png)
- Choose Copy Items
![Copy Items](Docs/02-copy-items.png)
- From the left side, make sure your project is selected, 
    - Select your **Target**
    - Under **Frameworks, Libraries, and Embedded Content**, find **KashierPaymentSdk.framework**
    - choose (Embed Without Signing, or Embed & Sign)
![Embed Framework](Docs/03-Embed-framework.png)
- Import the SDK to your code
```swift
import  KashierPaymentSDK
```
- [Initialize](#Initialization) the SDK


## Initialization
You'll need to initialize the SDK once before using any of the APIs


```swift
Kashier.initialize(merchantId: String,
            apiKey: String,
			sdkMode: SDK_MODE,
			currency: CURRENCY? = CURRENCY.EGP,
			displayLang: DISPLAY_LANG? = DISPLAY_LANG.EN)
```

```swift
let merchantId : String = "MID-XXXX-XXXX"
let apiKey : String = "XXXXXXXX-XXXX-XXX-XXXXX-XXXXXXXXXXXX"
var shopperReference :String = "XXXXXXXXXXXX"

let sdkMode : Kashier.SDK_MODE = .DEVELOPMENT

Kashier.initialize(merchantId: merchantId, apiKey:apiKey, sdkMode: sdkMode)
```

| Parameters | Type | Description|
| ------ | ------ | ------ |
| merchantId | String | [Merchant ID](#Prerequisites) |
| apiKey | String | [API Key](#Prerequisites) |
| sdkMode | [SDK_MODE](#SDK_MODE) | To switch between testing and live modes |
| currency | [CURRENCY?](#CURRENCY) | Currently only supports EGP |
| displayLang | [DISPLAY_LANG?](#DISPLAY_LANG) | To get the translated message from response|


# Save Shopper Card
Use this API to save a user card (Create a token), for later usage as [Pay With Token](#Pay-With-Token)

There are 2 Types of [tokens](#TOKEN_VALIDITY)
- **Temporary**: Used for Multiple page checkout, expires within a limited time
- **Permanent**: Card data is Saved at Kashier, can be used for any future transactions


```swift
Kashier.saveShopperCard(
		cardData : Card,
		shopperReference: String,
		tokenValidity : Kashier.TOKEN_VALIDITY,
		tokenizationCallback : TokenizationCallback) 
```

**Example**
```swift
var cardData : Card = Card(cardHolderName: name, cardNumber: numCard, cardCcv: cvv, cardExpiryMonth: month , cardExpiryYear: year)
var shopperReference :String = "XXXXXX"
var tokenType :Kashier.TOKEN_VALIDITY = .PERMANENT

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
```

| Parameters | Type | Description|
| ------ | ------ | ------ |
| cardData | [Card](#Card) | Card Details |
| shopperReference | String | User Unique ID in your system |
| tokenValidity | [TOKEN_VALIDITY](#TOKEN_VALIDITY) | Wheter to use a temp or perm token |
| tokenizationCallback | [TokenizationCallback?](#TokenizationCallback) | Callback that returns success or failure for Saving the card |




# List Shopper Card
Used to get a list of previously saved cards
Tokens are saved with one of the following conditions should be available in this api
- Tokens saved with [Save Shopper Card](#Save-Shopper-Card), with [**tokenValidity**](#TOKEN_VALIDITY) set to **PERMANENT**
- Tokens saved with [Payment with Card](#Payment-with-Card), with **shouldSaveCard** set to **true**


NOTE: Temp tokens are not saved, so they are not listed in this API

```swift
Kashier.listShopperCards(shopperReference: String, userCallBack : TokensListCallback)
```
**Example**
```swift
Kashier.listShopperCards(
    shopperReference:shopperReference,
    userCallBack: TokensListCallback(
        onResponse: { (tokensResponse ) -> (Void) in
            debugPrint("Login Tokens List Resposne succ")
            if let _tokens = tokensResponse.response?.tokens {
                for token in _tokens {
                    print("Card: \(token.cardNumber ?? "") \( token.cardExpiryMonth ?? "" )/\(token.cardExpiryYear ?? "") \(token.token ?? "")")
                }
            }
    }, onFailure: { (tokensListError) -> (Void) in
        debugPrint("Error in tokens list response:  \(tokensListError.getErrorMessage())")
    }))
```
| Parameters | Type | Description|
| ------ | ------ | ------ |
| shopperReference | String | User Unique ID in your system |
| tokenValidity | [TOKEN_VALIDITY](#TOKEN_VALIDITY) | Wheter to use a temp or perm token |
| TokensListCallback | [TokensListCallback?](#TokensListCallback) | Callback that returns success with list of cards, or failure |

# Pay With Token
## Pay with Temp Token
Used to pay using a card token created using [Save Shopper Card](#Save-Shopper-Card) with [tokenValidity](#TOKEN_VALIDITY) set to **TEMPORARY** 
```swift
Kashier.payWithTempToken(shopperReference : String,
                        orderId: String,
                        amount : String,
                        cardToken: String,
                        cvvToken : String,
                        paymentCallback : PaymentCallback)
```

**Example**
```swift
Kashier.payWithTempToken(
					shopperReference: shopperReference,
					orderId: orderId,
					amount: Amount,
					cardToken: cardToken,
					cvvToken: ccvToken,
					paymentCallback: PaymentCallback(onResponse: { (succ) -> (Void) in
						print("Payment with Token Success: \(succ.getResponseMessageTranslated())")
					}) { (error) -> (Void) in
						print("Payment with Token Error: \(error.getErrorMessage())")
				})
```
| Parameters | Type | Description|
| ------ | ------ | ------ |
| shopperReference | String | User Unique ID in your system |
| orderId | String | User Order ID in your system |
| amount | String | Amount as a string, with max 2 Decimal digits |
| cardToken | String | cardToken from [Save Shopper Card](#Save-Shopper-Card) |
| cvvToken | String | cvvToken from [Save Shopper Card](#Save-Shopper-Card) |
| paymentCallback | [PaymentCallback?](#PaymentCallback) | Callback that returns success or failure for the payment |


## Pay with Perm Token
Used to pay using a card token created using [Save Shopper Card](#Save-Shopper-Card) with [tokenValidity](#TOKEN_VALIDITY) set to **PERMANENT** 
```swift
		Kashier.payWithPermToken(
					shopperReference: shopperReference,
					orderId: orderId,
					amount: Amount,
					cardToken: cardToken,
					paymentCallback: PaymentCallback(onResponse: { (succ) -> (Void) in
						print("Payment with Token Success: \(succ.getResponseMessageTranslated())")
					}) { (error) -> (Void) in
						print("Payment with Token Error: \(error.getErrorMessage())")
				})

```

```swift
Kashier.payWithPermToken(shopperReference : String,
                        orderId: String,
                        amount : String,
                        cardToken: String,
                        paymentCallback : PaymentCallback)

```
| Parameters | Type | Description|
| ------ | ------ | ------ |
| shopperReference | String | User Unique ID in your system |
| orderId | String | User Order ID in your system |
| amount | String | Amount as a string, with max 2 Decimal digits |
| cardToken | String | cardToken from [Save Shopper Card](#Save-Shopper-Card) or  [List Shopper Card](#List-Shopper-Card)|
| paymentCallback | [PaymentCallback?](#PaymentCallback) | Callback that returns success or failure for the payment |


# Payment with Card
Used to pay using card data directly, can be customized with your Payment Form

```swift
 Kashier.payWithCard(
		cardData : Card,
		orderId : String,
		amount : String,
		shopperReference : String,
		shouldSaveCard : Bool,
		paymentCallback : PaymentCallback)
```
**Example**
```swift
Kashier.payWithCard(cardData: cardData,
                    orderId: orderId,
                    amount: Amount,
                    shopperReference: shopperReference,
                    shouldSaveCard: true,
                    paymentCallback: PaymentCallback(onResponse: { (succ) -> (Void) in
                        print("Payment with card Success: \(succ.getResponseMessageTranslated())")
                    }) { (error) -> (Void) in
                        print("Payment with card Error: \(error.getErrorMessage())")
})
```

| Parameters | Type | Description|
| ------ | ------ | ------ |
| cardData | [Card](#Card) | Card Details |
| orderId | String | User Order ID in your system |
| amount | String | Amount as a string, with max 2 Decimal digits |
| shopperReference | String | User Unique ID in your system |
| shouldSaveCard | Bool | Wheter to save the card after the transaction or not |
| paymentCallback | [PaymentCallback?](#PaymentCallback) | Callback that returns success or failure for the payment |

# Payment with Form (Coming Soon)
- Coming Soon ...
# Testing Data
You can use the following testing data
## Card Holder Name
John Doe
## Test Cards
### Card Numbers
| Test Cards | Card Number | 3-D Secure Enabled|
| ------ | ------ | ------ |
| MasterCard | 5123450000000008 | Yes |
|  | 2223000000000007 | Yes |
|  | 5111111111111118 | No |
|  | 2223000000000023 | No |
| Visa | 4508750015741019 | Yes |
|  | 4012000033330026 | No |
### CVV
| CSC/CVV |  CSC/CVV Response GW Code |
| ------ | ------ |
| 100 |  Match |
| 101 |  NOT_PROCESSED |
| 100 |  NO_MATCH |

### Expiry Date
| Expiry Date |  Transaction Response GW Code |
| ------ | ------ |
| 05/21 |  APPROVED |
| 02/22 |  DECLINED |
| 04/27 |  EXPIRED_CARD |
| 08/28 |  TIMED_OUT |
| 01/37 |  ACQUIRER_SYSTEM_ERROR |
| 02/37 |  UNSPECIFIED_FAILURE |
| 05/37 |  UNKNOWN |


# Data Models
## Enums
### SDK_MODE
```swift
	public enum SDK_MODE {
		case DEVELOPMENT
		case PRODUCTION
	}
```
### DISPLAY_LANG
```swift
	public enum DISPLAY_LANG : String{
		case AR = "ar"
		case EN = "en"
	}
```
### CURRENCY	
```swift
	public enum CURRENCY : String{
		case EGP = "EGP"
	}
```
### RESPONSE_STATUS
```swift
	public enum RESPONSE_STATUS {
		case
		UNKNOWN,
		SUCCESS,
		FAILURE,
		INVALID_REQUEST,
		PENDING,
		PENDING_ACTION
	}
```
### TOKEN_VALIDITY
```swift
	public enum TOKEN_VALIDITY :String{
		case TEMPORARY = "temp"
		case PERMANENT = "perm"
	}
```
## Classes
### Card
```swift
init(cardHolderName: String,
cardNumber: String,
cardCcv: String,
cardExpiryMonth: String,
cardExpiryYear: String)

//OR
init(cardHolderName: String,
cardNumber: String,
cardCcv: String,
cardExpiryDate: String)

//Usage Example

var name : String = "kashier testing user";
var month : String = "09";
var year  : String = "21";
var cvv : String = ""
var numCard : String = ""

var cardData : Card = Card(cardHolderName: name, cardNumber: numCard, cardCcv: cvv, cardExpiryMonth: month , cardExpiryYear: year)
```
### TokenizationCallback
Please refer to example

### TokensListCallback
please refer to example

### PaymentCallback
please refer to example

### ErrorData



# Example App
This is a quick example app used to provide quick testing for functions provided by our payment SDK

![Copy Items](Docs/04-Example-app.png)
 To use the example app provided in this repo
 ```sh
git clone https://github.com/Kashier-payments/Kashier-IOS-SDK.git
 ```
- Open the project using xCode
- Go to KashierSDK_ExampleApp/DevConfig.swift
- Modify the following parameters and run
- Check [Prerequisites](#Prerequisites) to get **merchantId** and **apiKey**
- **shopperReference** is the user unique ID in your system
```swift
/// Edit these parameters to start using our Example app
let merchantId : String = ""
let apiKey : String = ""
var shopperReference :String = ""
```
- Run the project
### Example App usage
- **Token Type**: Used to toggle between temp/perm tokens
    - Affects the 'Create Token'
- The **Use 3DS**: switch toggles the used card in the the testing, the cards used are from our [Testing Data](#Testing-Data)
- **New Order ID**: Generates a new random order id to be used with transactions
- **New Shopper**: Used to use a new random generated shopper reference to start testing as a different user
- **Create Token**: The token created  is used by the "Pay with token"
- **List Cards**: To get list of saved cards by the "Create Token"(**Perm ONLY**)
- **Pay With Token**: Pay using generated token from **Create Token**
- **Pay With Card**: Pay using Card data directly
    - If TokenType is set to Perm -> Will pay and save the card data, can be found in 'List Cards' after the successful payment
    - If TokenType is set to Temp -> Will pay without saving the card 


- Feel free to put breakpoints in KashierSDK_ExampleApp/ViewController.swift to 
check the behavior of the SDK