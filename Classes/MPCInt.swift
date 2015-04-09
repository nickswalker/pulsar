import UIKit

struct MPCInt: MPCSerializable {
    let value: Int

    var mpcSerialized: NSData {
        return NSKeyedArchiver.archivedDataWithRootObject(value)
    }

    init(value: Int) {
        self.value = value
    }

    init(mpcSerialized: NSData) {
        let value = NSKeyedUnarchiver.unarchiveObjectWithData(mpcSerialized) as! Int
        self.init(value: value)
    }
}
