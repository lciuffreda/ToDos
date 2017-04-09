import UIKit

protocol SortListTableViewControllerDelegate: class {
    func didFinishSelectSorting(sortName: String)
}

class SortListTableViewController: UITableViewController {
    
    weak var delegate:SortListTableViewControllerDelegate?
    var selectedIndex: Int = 0
    let array = ["Name asc.","Name desc.","Priority asc.","Priority desc.","Date asc.","Date desc."]
    private let titleSection = "Select the sort order"
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = array[indexPath.row]
        cell.accessoryType = (selectedIndex == indexPath.row) ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleSection
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
    }

    @IBAction func dismissVC(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneSelecting(_ sender: UIBarButtonItem) {
        delegate?.didFinishSelectSorting(sortName: array[selectedIndex])
        dismiss(animated: true, completion: nil)
    }
}
