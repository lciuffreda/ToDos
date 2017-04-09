import UIKit
import Foundation

class ToDoCell: UITableViewCell {
    
    @IBOutlet weak var toDoNameLbl: UILabel!
    @IBOutlet weak var priorityLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    var toDo:ToDo! {
        didSet {
            configureCell()
        }
    }
    
    func configureCell() {
        toDoNameLbl.text = toDo!.name
        priorityLbl.text = toDo!.priority
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        dateLbl.text = formatter.string(from: toDo!.date! as Date)
    }
}
