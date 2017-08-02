# UIView+UIAppearance+Private

[![](https://img.shields.io/travis/rust-lang/rust.svg?style=flat)](https://github.com/Modool)
[![](https://img.shields.io/badge/language-Object--C-1eafeb.svg?style=flat)](https://developer.apple.com/Objective-C)
[![](https://img.shields.io/badge/license-MIT-353535.svg?style=flat)](https://developer.apple.com/iphone/index.action)
[![](https://img.shields.io/badge/platform-iOS-lightgrey.svg?style=flat)](https://github.com/Modool)
[![](https://img.shields.io/badge/QQ群-662988771-red.svg)](http://wpa.qq.com/msgrd?v=3&uin=662988771&site=qq&menu=yes)

## Introduction

- This framework is dedicated to implementing multi-theme solutions with the implementation of the system.
- The system solution is flawed, which can't synchronous theme for these views is being displayed.
- It's an extension for UIAppearance protocol with private method and properties of _UIAppearance.

## How To Get Started

* Download `UIView+UIAppearance+Private` and try run example app

## Installation


* Installation with CocoaPods

```
source 'https://github.com/Modool/cocoapods-specs.git'
platform :ios, '8.0'

target 'TargetName' do
pod 'UIView+UIAppearance+Private', '~> 1.0'
end
```

* Installation with Carthage

```
github "Modool/UIView-UIAppearance" ~> 1.0
```

* Manual Import

```
drag “UIView+UIAppearance+Private” directory into your project

```

## Requirements
- Requires ARC

## Architecture
### UIView (UIAppearance)
* `hook methods`
	* `allocWithZone:`

### _UIAppearance (Private class)
* `hook methods`
	* `forwardInvocation:`
	* `methodSignatureForSelector:`
* `private properties`
	* `_appearanceInvocations`
	* `_customizableClassInfo`
	
### _UIAppearanceCustomizableClassInfo (Private class)
* `private properties`
	* `_classReferenceKey`
	* `_customizableViewClass`
	* `_guideClass`
	* `_superClassInfo`

## Usage

* Demo FYI 

## License
`UIView+UIAppearance+Private` is released under the MIT license. See LICENSE for details.

## Communication

<img src="./images/qq_1000.png" width=200><img style="margin:0px 50px 0px 50px" src="./images/wechat_1000.png" width=200><img src="./images/github_1000.png" width=200>
