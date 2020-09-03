
# Change Log
<!---
Template: 
https://gist.github.com/juampynr/4c18214a8eb554084e21d6e288a18a2c

All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).
--->

<!-- ## Unreleased -->
## [1.1.2] - 2020-09-03

### Fixed 
- Updated some access modifiers for response Codable classes to support Objective-C (and React Native)

## [1.1.1] - 2020-08-27
### Fixed 
- Fixed bug in saveShopperCard, listCards

## [1.1.0] - 2020-08-25
### Changed
- Converted .framework to .xcframwork to support both simulator and physical device.
### Fixed 
- OTP Page doesn't load correctly with some card providers
- Fixed error messages, in case of validation errors in saveShopperCard
- Added extra validation for card expiry date

### Updated
- README section for **ErrorData**
#
## [1.0.3] - 2020-07-20
The Core change in that version is added support for Objective-C for the existing swift code. The necessary code changes were made to make that possible.
There's no need to upgrade to this version if you're using the previous one with swift.
 
### Added
- Support for Objective-C.
 
### Changed
Since Objective-C doesn't support enums defined inside classes in swift, the following enums were moved outside the class and prefixed with **KASHIER_** 

Enums were changed as the following:

| < 1.0.3 | 1.0.3 |
| ------ | ------ |
| Kashier.DISPLAY_LANG | KASHIER_DISPLAY_LANG|
| Kashier.SDK_MODE  | KASHIER_SDK_MODE|
| Kashier.RESPONSE_STATUS | KASHIER_RESPONSE_STATUS|
| Kashier.TOKEN_VALIDITY | KASHIER_TOKEN_VALIDITY|
