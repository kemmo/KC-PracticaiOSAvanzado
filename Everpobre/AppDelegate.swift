//
//  AppDelegate.swift
//  Everpobre
//
//  Created by Joaquin Perez on 08/03/2018.
//  Copyright © 2018 Joaquin Perez. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let firstLaunch = FirstLaunch(userDefaults: .standard, key: "com.jorgevinaches.Everpobre")
        if firstLaunch.isFirstLaunch {
            NotebookManager.createNotebook(name: "Mi notebook", isDefault: true, completion: nil)
        }
        
        window = UIWindow()
        
        let notesTVC = NotesTableViewController(style: .plain)
        let notesNavigationController = UINavigationController(rootViewController: notesTVC)
        
        let noNoteViewController = NoNoteViewController()
        let noNoteNavigationController = UINavigationController(rootViewController: noNoteViewController)
        
        let splitViewController = UISplitViewController()
        splitViewController.delegate = self
        splitViewController.preferredDisplayMode = .primaryOverlay
        splitViewController.viewControllers = [
            notesNavigationController,
            noNoteNavigationController
        ]
        
        noNoteViewController.navigationItem.leftItemsSupplementBackButton = true
        noNoteViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        
        window?.rootViewController = splitViewController
        
        window?.makeKeyAndVisible()
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(documentDirectory.absoluteString)
        
        return true
    }
}

extension AppDelegate: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}

