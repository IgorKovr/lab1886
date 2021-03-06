import Foundation

typealias NetworkRouterCompletion = (_ data: Data?,_ response: URLResponse?,_ error: Swift.Error?)->()

protocol NetworkRouter: class {
  
  func request(_ route: Endpoint, parameters: HTTPParametersConvertable?,
               completion: @escaping NetworkRouterCompletion)
  func cancelRequest()
}

final class NetworkRouterImpl: NetworkRouter {
  
  private var task: URLSessionTask?
  private let timeoutInterval = 60.0
  
  func cancelRequest() {
    task?.cancel()
  }
  
  func request(_ route: Endpoint, parameters: HTTPParametersConvertable?,
               completion: @escaping NetworkRouterCompletion) {
    do {
      let currentDispatchQueue = OperationQueue.current?.underlyingQueue
      let request = try self.buildRequest(from: route, parameters: parameters)
      task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
        currentDispatchQueue?.async {
          completion(data, response, error)
        }
      })
    } catch {
      completion(nil, nil, error)
    }
    task?.resume()
  }
  
  private func buildRequest(from route: Endpoint,
                            parameters: HTTPParametersConvertable?) throws -> URLRequest {
    var request = URLRequest(url: route.url, timeoutInterval: timeoutInterval)
    request.allHTTPHeaderFields = route.httpHeader
    request.httpMethod = route.httpMethod.rawValue
    request.httpBody = try parameters?.httpParameters()
    return request
  }
}
