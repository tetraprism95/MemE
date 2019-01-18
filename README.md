# Memer 

Take a picture ONLY if you think it's meme worthy. Post it with a caption to make it even funnier.

## Quick Look (NOTE: BETTER TO USE REAL DEVICE FOR SIGN-UP)

<pre>
If you're too lazy to sign-up and prefer loading with iPhone simulator instead of using a real device 
then I have an existing account just for your convenience.  

Already populated with few posts on the meme feed. 
Obviously, user won't be able to access the camera and take a picture unless one has a real device to take it with.

username: Marcochun21@gmail.com 
password: nurichun21

</pre>

## Demo

![memerloginsignup](https://user-images.githubusercontent.com/36717095/51081106-f1046700-16b5-11e9-9353-6851f5b61297.gif)
![memerloggedin](https://user-images.githubusercontent.com/36717095/51081107-f2ce2a80-16b5-11e9-9167-7329e332d0d7.gif)
![memerprofilespics](https://user-images.githubusercontent.com/36717095/51081108-f5c91b00-16b5-11e9-9c60-d4d46a7913bb.gif)
![memerfeed](https://user-images.githubusercontent.com/36717095/51081109-f8c40b80-16b5-11e9-9d25-191fbb6e89cc.gif)
![memercamera](https://user-images.githubusercontent.com/36717095/51081110-fa8dcf00-16b5-11e9-82ad-c2e4be5768d5.gif)
![memereditprofile](https://user-images.githubusercontent.com/36717095/51081111-fc579280-16b5-11e9-868a-5735bda8d6b3.gif)

## Built Programmatically (NO STORYBOARD)

I don't have any bias towards building apps with storyboard, it's just that I feel more comfortable coding programmatically. 
Maybe in the near future I'll build couple of apps with storyboard.

## Requirements

<pre>
IDE: Xcode (NEEDED TO OPEN)
Language&Version: Swift 4.2 
Developing software for mainly, macOS, iOS, watchOS, and tvOS.
</pre>

### What Is Firebase?

It is is BaaS or Backend-as-a-Service as an app development platform on Google Cloud.
For example, the backend holds all users data and can either write to or retrieve from Google Cloud Platform; it can do a lot more than that. 

Heres the link to get started! **https://firebase.google.com/**

Heres the link how to setup Firebase to your iOS Project! **https://firebase.google.com/docs/ios/setup**

## Features

Meme app was created to understand different concepts such as...

- Imports throughout VC'S : UIKit(Default), Photos, AVFoundation, Firebase 

- **AVFoundation**: Camera Implementation displayed in custom UI.

- **Photos**: If one wanted to upload photos from Photo Album, this would my idea for photos import.
 
- **Firebase**: Learned how to use observe(), updateVal(), Snapshot data to convert to swift, create and update to specific root ref, Fetch data from specific ref. ref = "reference" 

- **Dynamic Cell Sizing**: Learned how to create dynamic cell size depending on size of data input. For example, if text is more than 1 line, then the label is able to adjust to that height and will reflect the cell as well.

- **CollectionViewController**: Creating UICollectionViewController() && Cell Programmatically. Prefer it over UITableViewController due to flexibility.

- **UIViewControllerAnimatedTransitioning**: Learned how to create custom animation transitions between controllers, .to and .from. Learning the positioning and how to animate using UIView.animate() and ending the completion.

- **UIViewController/ UITextField Login**: In welcome/login controller I learned how to adjust the UITextFields positions, x and y, when blocked by keyboard. 

- **NSNotificationCenter** to post and observe: When posting a post, another controller will observe the action and handle it accordingly. 

- **Custom Protocol Delegation**

- **Completion Callbacks**

- And much more...

## Bugs/Need to Update

- When trying to refresh the meme feed by scrolling down, the feed will continuously load and possibly crash. 
I didn't implement the refresh, so it's more of "I need to update it" instead of it being an actual bug. 

- When posting a meme to the home feed, it will sometimes not appear instantly. Therefore, closing it and running it again will do the trick. I hope... LOOL

- On the User Profile tab, there is an "Edit Profile" button. When tapped/clicked or w.e, it will show a screen where
most of the bottom section is yellow. Just need to change the color, but too lazy since this was done a year ago for learning purposes. 

- On the login screen, the Facebook button won't work at the moment. Did not implement FB Login SDK. Later.

- PodFile cannot be opened anymore.

- IDK Other stuff if you can find fam.

## Updated
- Just reinstalled my podfile and updated firebase to v5.15.0. 
- Assets folder was missing, so commited & pushed to github again. 






