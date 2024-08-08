import Foundation

final class KNLog {
    static func logging(
        message: String,
        fileName: String = #file,
        line: Int = #line,
        funcname: String = #function
    ) {
        let fileString = fileName.components(separatedBy: "/").last?.replacingOccurrences(of: ".swift", with: "")
        let line = #line
        
        var log = "[\(String(describing: fileString))][\(funcname):\(line)] \(message)"
       print(log)
    }
}
