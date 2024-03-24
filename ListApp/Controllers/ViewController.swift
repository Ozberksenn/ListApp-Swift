//
//  ViewController.swift
//  ListApp
//
//  Created by Özberk Sen on 17.03.2024.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    var alertController = UIAlertController()
    
    @IBOutlet weak var tableView : UITableView!
    
    var data = [NSManagedObject]();

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        fetch()
    }
    
    
    
    @IBAction func didAppBarButtonItemTapped(sender : UIBarButtonItem){
       presentAddAlert()
    }
    
    @IBAction func didAppBarRemoveButton(sender : UIBarButtonItem){
        presentAlert(title: "Are you sure ?", message: " Do you want to delete all list ? ", cancelButtonTitle: "NO",defaultButtonTitle: "YES",defaultButtonHandler: {_ in
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            
            for item in self.data {
                managedObjectContext?.delete(item)
            }
            try? managedObjectContext?.save()
            self.fetch()
        })
        
    }
    
    
    func presentAddAlert(){
        presentAlert(title: "Add a new item", message: "Do you want to new item ?", cancelButtonTitle: "NO",defaultButtonTitle: "YES",defaultButtonHandler: {_ in
            let text = self.alertController.textFields?.first?.text
            if text != "" {
                
                let appDelegate = UIApplication.shared.delegate as? AppDelegate // burada app Delegateye ulaşıyoruz. App Delgate is bize bilgiler verir uygulamadan çıktı mı şunu yaptı vs gibi. Yine bizim local storageuye ulaşmamızı da sağlar.
                let managedObjectContext = appDelegate?.persistentContainer.viewContext // verit tabanıma , core dataya , local storageye aslında böyle eriştik.
                let entity = NSEntityDescription.entity(forEntityName: "ListItem", in: managedObjectContext!) // managedObjectContext içinde bir entity oluşturdum.
                
                let listItem = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
                
                listItem.setValue(text, forKey: "title")
                
                try? managedObjectContext?.save() // kaydetme işlemini yapar.
                
                self.fetch()
                

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
    
    func fetch(){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        let managedObjectContext = appDelegate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        
        data = try! managedObjectContext!.fetch(fetchRequest)
        
        tableView.reloadData()
    }
}


extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        let listItem = data[indexPath.row]
        cell.textLabel?.text = listItem.value(forKey: "title") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { _,_,_ in
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            managedObjectContext?.delete(self.data[indexPath.row])
            try? managedObjectContext?.save()
            self.fetch()
        }
        let editedAction = UIContextualAction(style: .normal, title: "Edit") { _, _,_ in
            self.presentAlert(title: "Edited item", message: "Do you want to edit item ?", cancelButtonTitle: "NO",defaultButtonTitle: "YES",defaultButtonHandler: {_ in
                let text = self.alertController.textFields?.first?.text
                if text != "" {
                    // self.data[indexPath.row] = text!
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    let managedObjectContext = appDelegate?.persistentContainer.viewContext
                    
                    self.data[indexPath.row].setValue(text, forKey:"title")
                    
                    if managedObjectContext!.hasChanges{
                      try? managedObjectContext?.save()
                    }
                    
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
