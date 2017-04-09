import UIKit
import RealmSwift

class ToDoListTableViewController: UITableViewController {
    
    var toDoArray = [ToDo]()
    var filteredArray = [ToDo]()
    var realmManager = RealManager()
    var toDoToEdit:ToDo?
    let searchController = UISearchController(searchResultsController: nil)
    var selectedIndex: Int = 0
    var isSortingEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for to do"
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isSortingEnabled {
            isSortingEnabled = false
        } else {
            toDoArray = realmManager.queryToDos()
        }
        tableView.reloadData()
        toDoToEdit = nil
    }
    
    override func loadView() {
        super.loadView()
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredArray.count
        }
        return toDoArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: toDoCellID, for: indexPath) as! ToDoCell
        if searchController.isActive && searchController.searchBar.text != "" {
            cell.toDo = filteredArray[indexPath.row]
        } else {
            cell.toDo = toDoArray[indexPath.row]
        }
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let toDoToDelete = toDoArray[indexPath.row]
            let realm = try! Realm()
            try! realm.write {
                realm.delete(toDoToDelete)
            }
            toDoArray = realmManager.queryToDos()
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toDoToEdit = toDoArray[indexPath.row]
        performSegue(withIdentifier: ManageToDoID, sender: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        setEditing(false, animated: true)
        if segue.identifier == "ManageToDoID" { //ManageToDo
            let navCtr = segue.destination as! UINavigationController
            let manageToDoTVC = navCtr.topViewController as! ManageToDoTVC
            manageToDoTVC.toDoToEdit = self.toDoToEdit
        } else { //showSort
            let navCtr = segue.destination as! UINavigationController
            let sortListTVC = navCtr.topViewController as! SortListTableViewController
            sortListTVC.selectedIndex = selectedIndex
            sortListTVC.delegate = self
        }
    }
    
    //MARK: Additional function
    func filterContentForSearchText(searchText: String) {
        filteredArray = toDoArray.filter { toDo in
            return (toDo.name!.lowercased().contains(searchText.lowercased()))
        }
        tableView.reloadData()
    }
    
}

//MARK: DZNEmptyDataSetSource

extension ToDoListTableViewController: DZNEmptyDataSetSource {
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let text = "Empty List"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraphStyle.alignment = .center
        let attributes: [String: Any] = [NSFontAttributeName: UIFont.systemFont(ofSize: 17),
                                         NSForegroundColorAttributeName: UIColor(red: CGFloat(170 / 255.0),
                                                                                 green: CGFloat(171 / 255.0),
                                                                                 blue: CGFloat(179 / 255.0),
                                                                                 alpha: CGFloat(1.0)),
                                         NSParagraphStyleAttributeName: paragraphStyle]
        return NSMutableAttributedString(string: text, attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let text = "Start adding a new to-do!"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraphStyle.alignment = .center
        let attributes: [String: Any] = [NSFontAttributeName: UIFont.systemFont(ofSize: 16),
                                         NSForegroundColorAttributeName: UIColor(red: CGFloat(170 / 255.0),
                                                                                 green: CGFloat(171 / 255.0),
                                                                                 blue: CGFloat(179 / 255.0),
                                                                                 alpha: CGFloat(1.0)),
                                         NSParagraphStyleAttributeName: paragraphStyle]
        return NSMutableAttributedString(string: text, attributes: attributes)
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        return UIColor.white
    }
    
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        return nil
    }
    
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return 0
    }
}

//MARK: DZNEmptyDataSetDelegate

extension ToDoListTableViewController: DZNEmptyDataSetDelegate {
    
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView) -> Bool {
        return false
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return false
    }
}

//MARK: UISearchResultsUpdating protocol

extension ToDoListTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

//MARK: SortListTableViewControllerDelegate

extension ToDoListTableViewController: SortListTableViewControllerDelegate {
    func didFinishSelectSorting(sortName: String) {
        if sortName == "Name asc." {
            toDoArray = toDoArray.sorted{$0.name!.localizedCaseInsensitiveCompare($1.name!) == .orderedAscending }
            selectedIndex = 0
        } else if sortName == "Name desc." {
            toDoArray = toDoArray.sorted{$0.name!.localizedCaseInsensitiveCompare($1.name!) == .orderedDescending }
            selectedIndex = 1
        } else if sortName == "Priority asc." {
            toDoArray =
                toDoArray.sorted{$0.priority!.localizedCaseInsensitiveCompare($1.priority!) == .orderedAscending }
            selectedIndex = 2
        } else if sortName == "Priority desc." {
            toDoArray =
                toDoArray.sorted{$0.priority!.localizedCaseInsensitiveCompare($1.priority!) == .orderedDescending }
            selectedIndex = 3
        } else if sortName == "Date asc." {
            toDoArray = toDoArray.sorted(by: {$0.date!.timeIntervalSince1970 < $1.date!.timeIntervalSince1970})
            selectedIndex = 4
        } else {
            toDoArray = toDoArray.sorted(by: {$0.date!.timeIntervalSince1970 > $1.date!.timeIntervalSince1970})
            selectedIndex = 5
        }
        isSortingEnabled = true
    }
}

