import Foundation
import RealmSwift

class ToDo: Object {
    dynamic var name:String?
    dynamic var priority:String?
    dynamic var date:NSDate?
}

class RealManager: NSObject {
    
    override init() {
        super.init()
    }
    
    func queryToDos() -> [ToDo] {
        var toDoArray = [ToDo]()
        let realm = try! Realm()
        let allToDos = realm.objects(ToDo.self)
        for toDo in allToDos {
          toDoArray.append(toDo)
        }
        return toDoArray
    }
}



