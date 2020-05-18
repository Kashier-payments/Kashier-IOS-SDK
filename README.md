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
- [Payment with Card](#Payment-with-Card)
- [Payment with Form (Coming Soon)](#Payment-with-Form-(Coming-Soon))
- [Testing Data](#Testing-Data)
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
- Choose Copy Items![Copy Items](Docs/02-copy-items.png)
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
initialize(merchantId: String,
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
# List Shopper Card
# Payment with Card
# Payment with Form (Coming Soon)
# Testing Data
# Data Models
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
/// Edit these parameters to start usign our Example app
let merchantId : String = ""
let apiKey : String = ""
var shopperReference :String = ""
///-------------------------------------
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