import UIKit
import RealmSwift

class ManageToDoTVC: UITableViewController {
    
    @IBOutlet weak var toDoNameTextField: UITextField!
    @IBOutlet weak var toDoDateLbl: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet var datePickerCell: UITableViewCell!
    @IBOutlet weak var priorityLbl: UILabel!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    private let indexPathDateRow = IndexPath(row: 0, section: 2)
    private let indexPathDatePicker = IndexPath(row: 1, section: 2)
    var toDoToEdit:ToDo?
    var dateToDo = Date()
    var datePickerVisible = false
    var realmManager:RealManager?
    var selectedPriorityTitle: String = "Low"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = toDoToEdit != nil ? "Edit To Do" : "Add To Do"
        doneButton.isEnabled = toDoToEdit != nil ? true : false
        if let toDoToEdit = toDoToEdit {
            toDoNameTextField.text = toDoToEdit.name
            priorityLbl.text = toDoToEdit.priority!
            selectedPriorityTitle = priorityLbl.text!
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            dateToDo = toDoToEdit.date! as Date
        } 
        updateDate()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navCtrl = segue.destination as! UINavigationController
        let priorityVC = navCtrl.topViewController as! ChangePriorityViewController
        priorityVC.selectedString = selectedPriorityTitle
        priorityVC.delegate = self
    }
    
    
    //MARK: Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 && datePickerVisible {
            return 2
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 2 && indexPath.row == 1 {
            return datePickerCell
        } else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    //MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        toDoNameTextField.resignFirstResponder()
        switch (indexPath.section, indexPath.row) {
        case (1,0):
            performSegue(withIdentifier: "showPriorityID", sender: nil)
        case (2, 0):
            manageDatePicker()
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 && indexPath.row == 1 {
            return 217
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        var newIndexPath = indexPath
        if indexPath.section == 2 && indexPath.row == 1 {
            newIndexPath = IndexPath(row: 0, section: indexPath.section)
        }
        return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
    }
    
    //Manage visibility DatePicker
    func manageDatePicker() {
        if !datePickerVisible {
            showDatePicker()
        } else {
            hideDatePicker()
        }
    }
    
    //Show datePicker
    func showDatePicker() {
        datePickerVisible = true
        let indexPathDateRow = self.indexPathDateRow
        let indexPathDatePicker = self.indexPathDatePicker
        if let dateCell = tableView.cellForRow(at: indexPathDateRow) {
            dateCell.detailTextLabel!.textColor = dateCell.detailTextLabel!.tintColor
        }
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPathDatePicker], with: .fade)
        tableView.reloadRows(at: [indexPathDateRow], with: .none)
        tableView.endUpdates()
        datePicker.setDate(dateToDo, animated: false)
        scrollToBottom()
    }
    
    //Hide datePicker
    func hideDatePicker() {
        if datePickerVisible {
            datePickerVisible = false
            let indexPathDateRow = self.indexPathDateRow
            let indexPathDatePicker = self.indexPathDatePicker
            if let cell = tableView.cellForRow(at: indexPathDateRow) {
                cell.detailTextLabel!.textColor = UIColor(white: 0, alpha: 0.5)
            }
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPathDateRow], with: .none)
            tableView.deleteRows(at: [indexPathDatePicker], with: .fade)
            tableView.endUpdates()
        }
    }
    
    //Scroll to bottom when start typing
    func scrollToBottom()
    {
        let numberOfSections = tableView.numberOfSections
        let numberOfRows = tableView.numberOfRows(inSection: numberOfSections-1)
        if numberOfRows > 0 {
            let indexPath = IndexPath(row: numberOfRows-1, section: numberOfSections-1)
            tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
    
    //Update date
    func updateDate() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        toDoDateLbl.text = formatter.string(from: dateToDo)
    }
    
    //MARK: IBAction
    
    //Dismiss ctrl
    @IBAction func dismissVC(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    //Done managing to do
    @IBAction func doneManaging(_ sender: UIBarButtonItem) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        if let toDoToEdit = toDoToEdit {//Modify
            let realm = try! Realm()
            try! realm.write {
                toDoToEdit.name = toDoNameTextField.text!
                toDoToEdit.priority = selectedPriorityTitle
                toDoToEdit.date = formatter.date(from: toDoDateLbl.text!)! as NSDate
            }
        } else { //Add
            let toDo = ToDo()
            toDo.name = toDoNameTextField.text!
            toDo.priority = selectedPriorityTitle
            toDo.date = formatter.date(from: toDoDateLbl.text!)! as NSDate
            let realm = try! Realm()
            try! realm.write {
                realm.add(toDo)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    //Change the Date
    @IBAction func dueDateChanged(_ datePicker: UIDatePicker) {
        dateToDo = datePicker.date
        updateDate()
    }
    
}

//MARK: UITextFieldDelegate
extension ManageToDoTVC: UITextFieldDelegate {
    func textField(_ textField: UITextField,shouldChangeCharactersIn range: NSRange,replacementString string: String) -> Bool {
        let oldText = toDoNameTextField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string) as NSString
        doneButton.isEnabled = newText.length > 0
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideDatePicker()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

//MARK: ChangePriorityViewControllerDelegate
extension ManageToDoTVC: ChangePriorityViewControllerDelegate {
    
    func didFinishSelectingPriority(priority: String) {
        self.selectedPriorityTitle = priority
        priorityLbl.text = self.selectedPriorityTitle
    }
    
}


