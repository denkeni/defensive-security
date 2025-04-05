import Network

func performWhoisQuery(for domain: String, completion: @escaping (String) -> Void) {
    let connection = NWConnection(host: "whois.verisign-grs.com", port: 43, using: .tcp)
    connection.stateUpdateHandler = { state in
        switch state {
        case .ready:
            let query = "\(domain)\r\n".data(using: .utf8)!
            connection.send(content: query, completion: .contentProcessed { _ in
                receiveWhoisResponse(from: connection, accumulated: "", completion: completion)
            })
        default:
            break
        }
    }
    connection.start(queue: .global())
}

func receiveWhoisResponse(from connection: NWConnection, accumulated: String, completion: @escaping (String) -> Void) {
    connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) { data, _, isComplete, _ in
        var current = accumulated
        if let data = data, let response = String(data: data, encoding: .utf8) {
            current += response
        }
        if isComplete {
            connection.cancel()
            completion(current)
        } else {
            receiveWhoisResponse(from: connection, accumulated: current, completion: completion)
        }
    }
}
