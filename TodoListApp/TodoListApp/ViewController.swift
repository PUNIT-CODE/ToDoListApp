//
//  ViewController.swift
//  TodoListApp
//
//  Created by Punit Thakali on 20/11/2023.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext  //calling the PersisenetContainer of CoreData
 
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")       // creating a tableview
        return table
    }()
    
    private var models = [ToDoListItem]()         // creating an array and adding the sub-class created to that array

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ToDoList"
        view.addSubview(tableView)
        retrieveItems()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))    //creating a bar button item
      
    }
    
    @objc private func didTapAdd()
    {
        let alert = UIAlertController(title: "New Tasks", message: "Enter New Tasks", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: { [weak self] _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {      //alerts for adding new tasks and submitting
                return
            }
            self?.createItem(name: text)
        }))
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = models[indexPath.row]
        
        let sheet = UIAlertController(title: "Edit Tasks", message: nil, preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "Edit your Tasks", style: .cancel, handler: { _ in
            
            let alert = UIAlertController(title: "New Tasks", message: "Enter New Tasks", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.name
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { [weak self] _ in
                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else {
                    return
                    
                }
                self?.updateItem(item: item, newName: newName)
            }))
            
            self.present(alert, animated: true)
            
        }))
        
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
          
            self?.deleteItem(item: item)
            
        }))
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
            
        }))
           
        present(sheet, animated: true)
        
    }
    
    //CoreData
    
    func retrieveItems(){
        do{
            models = try  context.fetch(ToDoListItem.fetchRequest())    //using fetchrequest from subclass to retrieve/fetch
           
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch{
            
        }
    }
    
    func createItem(name: String){
        
        let newItem = ToDoListItem(context: context)
        newItem.name = name                                          //calling the atrributes and adding them to newItem
        newItem.createdAt = Date()
        
        do {
            try context.save()
            retrieveItems()
        }
        catch{
            
        }
        
    }
    
    func deleteItem( item: ToDoListItem){
        context.delete(item)
        
        do{
            try context.save()                                 //CRUD is done in do,try,catch basically using error handling.
            retrieveItems()
        }
        catch{
            
        }
    }
    
    func updateItem( item: ToDoListItem, newName: String){
        item.name = newName
        
        do{
            try context.save()
            retrieveItems()
        }
        catch{
            
        }
    }
}



