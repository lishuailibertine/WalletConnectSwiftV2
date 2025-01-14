import Foundation

struct InputConfig {

    static var relayHost: String {
        return config(for: "RELAY_HOST")!
    }

    static var relayUrl: String {
        return "wss://\(relayHost)"
    }

    static var projectId: String {
        guard let projectId = config(for: "PROJECT_ID"), !projectId.isEmpty else {
            fatalError("PROJECT_ID is either not defined or empty in Configuration.xcconfig")
        }
        
        return projectId
    }

    static var defaultTimeout: TimeInterval {
        return 45
    }

    private static func config(for key: String) -> String? {
        return ProcessInfo.processInfo.environment[key]
    }
}
