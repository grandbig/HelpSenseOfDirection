//
//  SettingViewController.swift
//  HelpSenseOfDirection
//
//  Created by Takahiro Kato on 2017/07/09.
//  Copyright © 2017年 Takahiro Kato. All rights reserved.
//

import Foundation
import UIKit

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    private var rowTitle = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.rowTitle = ["アプリのチュートリアル", "ライセンス"]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択時にハイライト解除
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 1:
            performSegue(withIdentifier: "licenseSegue", sender: nil)
        default:
            break
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rowTitle.count 
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vc = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 2] as? ViewController
        
        switch indexPath.row {
        case 0:
            let cell: CustomCell = (tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as? CustomCell)!
            // チュートリアル完了の場合はスイッチOFF
            cell.sw.isOn = (vc?.checkTutorialState())! ? false : true
            return cell
        case 1:
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
            cell.textLabel?.text = self.rowTitle[indexPath.row]
            return cell
        default:
            break
        }
        return tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
    }
    
    // MARK: Storyboard Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backButton = UIBarButtonItem.init()
        backButton.title = "戻る"
        backButton.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = backButton
    }
    
    // MARK: Button Action
    @IBAction func changeValue(_ sender: Any) {
        // 遷移元ViewControllerの取得
        guard let nav = self.navigationController, let vc = nav.viewControllers[nav.viewControllers.count - 2] as? ViewController else {
            return
        }
        
        if (sender as AnyObject).isOn {
            // OFF → ON
            vc.removeTutorial()
            vc.tutorialStep = 0
        } else {
            // ON → OFF
            // 何もしない
        }
    }
    
}
