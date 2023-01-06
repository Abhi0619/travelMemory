import Foundation
import Combine

public class CatFactApi: CatFactProvider {
    
    
    //https://ar_game.project-demo.info/actual_project/public/api/login
    private let baseURL = "https://ar_game.project-demo.info/travel_memories/public"
    private enum Endpoint: String {
        case logIn = "/api/login"
        case register = "/api/register"
    }
    private enum Method: String {
        case GET
        case POST
    }
    
    public init() {}
    
    // MARK: Traditional
    
    public func LogIn(parameters : [String : Any], completion: @escaping((Result<LoginModel, APIError>) -> Void)) {
        request(endpoint: .logIn, method: .POST, parameters : parameters, completion: completion)
    }
    public func SignUp(parameters: [String : Any], completion: @escaping ((Result<RegisterModel, APIError>) -> Void)) {
        request(endpoint: .register, method: .POST, parameters: parameters, completion: completion)
    }

    private func request<T: Codable>(endpoint: Endpoint, method: Method, parameters : [String : Any],
                                  completion: @escaping((Result<T, APIError>) -> Void)) {
        let path = "\(baseURL)\(endpoint.rawValue)"
        
        var components = URLComponents(string: path)!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value as? String)
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        let url = components.url!

        //MARK: UNCOMMENT BELOW BOTH LINE WHEN THERE IS NO PARAMETER
//        guard let url = URL(string: path)
//            else { completion(.failure(.internalError)); return }
        print("-----URL-----> \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = "\(method)"
        request.allHTTPHeaderFields = ["Content-Type": "application/json"]
        
        call(with: request, completion: completion)
    }
    
    private func call<T: Codable>(with request: URLRequest, 
                                  completion: @escaping((Result<T, APIError>) -> Void)) {
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil
                else { completion(.failure(.serverError)); return }
            do {
                guard let data = data
                    else { completion(.failure(.serverError)); return }
                let object = try JSONDecoder().decode(T.self, from: data)
                completion(Result.success(object))
            } catch {
                completion(Result.failure(.parsingError))
            }
        }
        dataTask.resume()
    }
    
    // MARK: Combine
    
    public func randomFact() -> AnyPublisher<RandomFact, APIError> {
        return call(.logIn, method: .GET)
    }
    
    private func call<T: Codable>(_ endPoint: Endpoint, method: Method) -> AnyPublisher<T, APIError> {
        let urlRequest = request(for: endPoint, method: method)
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .mapError{ _ in APIError.serverError }
            .map { $0.data }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { _ in APIError.parsingError }
            .eraseToAnyPublisher()
    }
    
    private func request(for endpoint: Endpoint, method: Method) -> URLRequest {
        let path = "\(baseURL)\(endpoint.rawValue)"
        guard let url = URL(string: path)
            else { preconditionFailure("Bad URL") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "\(method)"
        request.allHTTPHeaderFields = ["Content-Type": "application/json"]
        return request
    }
}


