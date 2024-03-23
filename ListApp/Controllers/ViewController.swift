//
//  ViewController.swift
//  ListApp
//
//  Created by Özberk Sen on 17.03.2024.
//

import UIKit

class ViewController: UIViewController {

    var alertController = UIAlertController()
    
    @IBOutlet weak var tableView : UITableView!
    
    var data = [String]();

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    
    @IBAction func didAppBarButtonItemTapped(sender : UIBarButtonItem){
       presentAddAlert()
    }
    
    @IBAction func didAppBarRemoveButton(sender : UIBarButtonItem){
        presentAlert(title: "Are you sure ?", message: " Do you want to delete all list ? ", cancelButtonTitle: "NO",defaultButtonTitle: "YES",defaultButtonHandler: {_ in
            self.data.removeAll()
            self.tableView.reloadData()
        })
        
    }
    
    
    func presentAddAlert(){
        presentAlert(title: "Add a new item", message: "Do you want to new item ?", cancelButtonTitle: "NO",defaultButtonTitle: "YES",defaultButtonHandler: {_ in
            let text = self.alertController.textFields?.first?.text
            if text != "" {
                self.data.append((text)!);
                self.tableView.reloadData();
            }else {
                self.presentWarningAlert()
            }
            
        },isTextFieldAvailable: true)


    }
    func presentWarningAlert(){
        presentAlert(title: "Warning !!!", message: "List not be empty !", cancelButtonTitle: "OK")
    }
    
    
    func presentAlert(title: String?,message: String?,preferredStyle:  UIAlertController.Style = .alert,cancelButtonTitle: String?,defaultButtonTitle: String? = nil,defaultButtonHandler: ((UIAlertAction)-> Void)? = nil,isTextFieldAvailable: Bool = false){
         alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        let cancelButton = UIAlertAction(title: cancelButtonTitle, style: .cancel)
        
        if defaultButtonTitle != nil {
            let defaultButton = UIAlertAction(title: defaultButtonTitle, style: .default, handler: defaultButtonHandler)
            alertController.addAction(defaultButton)
            if isTextFieldAvailable {
                alertController.addTextField()
            }
            
        }
        alertController.addAction(cancelButton)
        present(alertController, animated: true)
    }
}


extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { _,_,_ in
            self.data.remove(at: indexPath.row)
            tableView.reloadData()
        }
        let editedAction = UIContextualAction(style: .normal, title: "Edit") { _, _,_ in
            self.presentAlert(title: "Edited item", message: "Do you want to edit item ?", cancelButtonTitle: "NO",defaultButtonTitle: "YES",defaultButtonHandler: {_ in
                let text = self.alertController.textFields?.first?.text
                if text != "" {
                    self.data[indexPath.row] = text!
                    self.tableView.reloadData();
                }else {
                    self.presentWarningAlert()
                }
                
            },isTextFieldAvailable: true)
        }
        deleteAction.backgroundColor = .systemRed
        let config = UISwipeActionsConfiguration(actions: [deleteAction,editedAction])
        return config
        
    }
}
