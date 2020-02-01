import Foundation
import Vapor
import Rainbow

// ref: https://gist.github.com/bre7/3e625c51ed9c9344e449c03ec2a1b8ca

/// Logs all requests that pass through it.
final class LogMiddleware: Middleware, Service {

    let log: Logger

    /// Creates a new `LogMiddleware`.
    init(log: Logger) { self.log = log }

    /// See `Middleware.respond(to:)`
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        let indent="      "
        var line: [String] = []
        line.append("[\(Date())] \(request.http.method) \(request.http.url.path)".bold)
        line.append("  Request Parameters:")
        for (k,v) in request.http.headers {
            line.append(indent + "\(k)=\(v)")
        }
        line.append("  Body: ")
        line.append(indent + "\(request.http.body)")
        
        log.verbose(line.joined(separator: "\n").blue+"\n".white)
        return try next.respond(to: request)
    }

}
