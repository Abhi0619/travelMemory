import Combine

public enum APIError: Error {
    case internalError
    case serverError
    case parsingError
}

public protocol CatFactProvider {
    func LogIn(parameters : [String : Any], completion: @escaping((Result<LoginModel, APIError>) -> Void))
    func SignUp(parameters : [String : Any], completion: @escaping((Result<RegisterModel, APIError>) -> Void))
    // MARK: Combine
    func randomFact() -> AnyPublisher<RandomFact, APIError>
}

