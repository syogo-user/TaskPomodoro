//
//  SceneDelegate.swift
//  TaskPomodoro
//
//  Created by 小野寺祥吾 on 2021/04/03.
//

import UIKit

protocol backgroundTimerDelegate: class {
    func setCurrentTimer(_ elapsedTime:Int)
    func deleteTimer()
    func checkBackground()
    var timerIsBackground:Bool { set get }
}
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    weak var delegate: backgroundTimerDelegate?
    let ud = UserDefaults.standard
    var myNavigationController :UINavigationController?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
//        let rootViewController = HomeViewController()
//        myNavigationController = UINavigationController(rootViewController: rootViewController)
//        window = UIWindow(frame: UIScreen.main.bounds)
//        window?.makeKeyAndVisible()
//        window?.rootViewController = myNavigationController
        guard let windowScene = (scene as? UIWindowScene) else {return}
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        let rootViewController = HomeViewController()
        myNavigationController = UINavigationController(rootViewController: rootViewController)
        window.rootViewController = myNavigationController
        window.makeKeyAndVisible()
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    // アプリ画面に復帰したとき
    func sceneDidBecomeActive(_ scene: UIScene) {
        if delegate?.timerIsBackground == true {
            let calender = Calendar(identifier: .gregorian)
            let date1 = ud.value(forKey: "date1") as! Date
            let date2 = Date()
            let elapsedTime = calender.dateComponents([.second], from: date1, to: date2).second!
            delegate?.setCurrentTimer(elapsedTime)
        }
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    //アプリ画面から離れるとき(ホームボタン押下時,スリープ時)
    func sceneWillResignActive(_ scene: UIScene) {
        ud.set(Date(), forKey: "date1")
        delegate?.checkBackground()
        delegate?.deleteTimer()
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

