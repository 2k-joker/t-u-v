# T-U-V
Stay up to date with your friends' social media activities in one place.

||Snippet 1|Snippet 2|Snippet 3|
|-|-|-|-|
|**Login**|<img src="https://user-images.githubusercontent.com/59208677/136338935-7d2ece85-e21b-4373-bb39-d1c05124c40b.png" width="200" height="400" />|<img src="https://user-images.githubusercontent.com/59208677/136339131-6acdb90d-a210-4807-87a8-8293e048e5f4.png" width="200" height="400" />|<img src="https://user-images.githubusercontent.com/59208677/136339311-ddb52d5a-0953-44fe-a082-a3e843af4e7c.png" width="200" height="400" />|
|**Signup**|<img src="https://user-images.githubusercontent.com/59208677/136339763-fef0e4a0-bca5-4203-93dd-71e443a9209f.png" width="200" height="400" />|<img src="https://user-images.githubusercontent.com/59208677/136339850-720f2aa8-7ecb-476f-920d-e0fe42908f59.png" width="200" height="400" />||
|**Feed**|<img src="https://user-images.githubusercontent.com/59208677/136340510-48d66adf-74cd-401d-8bc7-22a1253f3d83.png" width="200" height="400" />|<img src="https://user-images.githubusercontent.com/59208677/136340611-ed1a7a68-dc50-4c18-bb75-64edd9f461fb.png" width="200" height="400" />||
|**Profile**|<img src="https://user-images.githubusercontent.com/59208677/136340901-56d1721b-cb3c-48b1-a987-1f89b541a632.png" width="200" height="400" />|<img src="https://user-images.githubusercontent.com/59208677/136340993-a403adf7-def8-48a4-9433-8cf051be92db.png" width="200" height="400" />||
|**Users**|<img src="https://user-images.githubusercontent.com/59208677/136341174-8dfb8680-f85f-4381-bb08-5ce3cb0413cc.png" width="200" height="400" />|<img src="https://user-images.githubusercontent.com/59208677/136341241-a3ae2a88-e2aa-48b1-b821-1c831c6a4629.png" width="200" height="400" />||
|**Apps**|<img src="https://user-images.githubusercontent.com/59208677/136341347-570c9fa8-ca01-4e39-93a4-248dd856acc6.png" width="200" height="400" />|<img src="https://user-images.githubusercontent.com/59208677/136341434-eda9341e-74df-4df8-8465-f42fe88a341c.png" width="200" height="400" />||




### IMPLEMENTATION
* **Database and Authentication:** `Firebase`
* **Middlewear:** `Swift`
* **Frontend:** `Storyboard`

### SETUP
* **Cocoapods** is required to run this build and run this project. Follow the installation instructions in [this guide](https://guides.cocoapods.org/using/getting-started.html#getting-started)
* Navigate to the project directory and run `pod install` (recommended that the **Xcode** project be closed while running this)
* This should generate a **Podfile.lock** file, **pods** directory and a **TUV.xcworkspace** workspace file.
* Open the workspace **TUV.xcworkspace**. Note that the workspace (**.xcworkspace** extension) should be used to run this app moving forward  and not the project (**.xcodeproj** extension)
* Choose a target simulator device and run the app. It should build and run successfully

### REQUIREMENTS
* Xcode 12
* Swift 5
* Pod ~> '1.10.0'

### USAGE
* If it's your first time using the app, follow the **Sign Up** flow to create an account. Be sure to use a valid email address as email verification is required
* To connect to **Twitter**, simply input your twitter handle when prompted (e.g @\_my_handle)
* Your **Channel ID** is required to connect to **YouTube**. You can find this id in your Youtube account at **Profile -> Settings -> Advanced settings -> Channel ID**
* Navigate the app as you wish. Hopefully the UX is intuitive enough 🤞
