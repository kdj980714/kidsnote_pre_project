import Network
import UIKit

class NetworkMonitor {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    private var isConnected: Bool = false
    
    static let shared = NetworkMonitor()
    private init() { }
    func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
        }
    }
    
    func checkInternet() async throws -> () {
        guard self.isConnected else {
            throw NetworkError.connection
        }
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
