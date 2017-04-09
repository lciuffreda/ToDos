import UIKit

protocol ChangePriorityViewControllerDelegate: class {
    func didFinishSelectingPriority(priority: String)
}

class ChangePriorityViewController: UIViewController {

    @IBOutlet weak var segmentCtrl: UISegmentedControl!
    weak var delegate:ChangePriorityViewControllerDelegate?
    var selectedString:String?
    enum Priority: String {
        case Low    = "Low"
        case Medium = "Medium"
        case High   = "High"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setIndexSelected(stringSelected: selectedString!)
    }
    
    @IBAction func segmentControllerValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
           selectedString = Priority.Low.rawValue
        case 1:
            selectedString = Priority.Medium.rawValue
        case 2:
            selectedString = Priority.High.rawValue
        default:
            break
        }
    }

    @IBAction func doneSelectingPriority(_ sender: UIBarButtonItem) {
        delegate?.didFinishSelectingPriority(priority: selectedString!)
        dismiss(animated: true, completion: nil)
    }
    
    func setIndexSelected(stringSelected:String) {
        if selectedString == Priority.Low.rawValue {
            segmentCtrl.selectedSegmentIndex = 0
        } else if selectedString == Priority.Medium.rawValue {
            segmentCtrl.selectedSegmentIndex = 1
        } else {
            segmentCtrl.selectedSegmentIndex = 2
        }
    }
}
