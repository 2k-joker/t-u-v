## T-U-V
Stay up to date with your friends' social media activities in one place

### SETUP
* **Cocoapods** is required to run this build and run this project. Follow the installation instructions in [this guide](https://guides.cocoapods.org/using/getting-started.html#getting-started)
* Navigate to the project directory and run `pod install` (recommended that the **Xcode** project be closed while running this)
* This should generate a **Podfile.lock** file, **pods** directory and a **TUV.xcworkspace** workspace file.
* Open the workspace **TUV.xcworkspace**. Note that the workspace (**.xcworkspace** extension) should be used to run this app moving forward  and not the project (**.xcodeproj** extension)
* Choose a target simulator device and run the app. It should build and run successfully

### USAGE
* If it's your first time using the app, follow the **Sign Up** flow to create an account. Be sure to use a valid email address as email verification is required
* To connect to **Twitter**, simply input your twitter handle when prompted (e.g @\_2k_joker)
* Your **Channel ID** is required to connect to **YouTube**. You can find this id in your Youtube account at **Profile -> Settings -> Advanced settings -> Channel ID**
* Navigate the app as you wish. Hopefully the UX is intuitive enough 🤞

## Future Enhancements
* Implement API provided OAuth flows for proper user authentication and permissions
* Integrate with other social media APIs like **Pinterest**, and **Discord**
* 
