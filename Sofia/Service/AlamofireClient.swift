//
//  AlamofireClient.swift
//  Sofia
//
//  Created by Alfian on 26/08/24.
//

import Alamofire
import Combine
import Foundation
import KeychainSwift

enum ViewState<T> {
  case processing
  case success(T)
  case failure(Error)
  case idle
}

let decoder: JSONDecoder = {
  let decoder = JSONDecoder()
  decoder.keyDecodingStrategy = .convertFromSnakeCase
  return decoder
}()

public protocol Request {
  var path: String { get }
  var method: HTTPMethod { get }
  var body: [String: Any]? { get }
  var queryParams: [String: Any]? { get }
  var headers: [String: String]? { get set }
}

extension Request {
  func asHTTPHeaders() -> HTTPHeaders {
    let headers = headers?.map { HTTPHeader(name: $0.key, value: $0.value) } ?? []
    return HTTPHeaders(headers)
  }

  func asURL(with baseURL: String) -> URL? {
    guard let url = URL(string: baseURL),
          var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
    urlComponents.path = "\(urlComponents.path)\(path)"
    urlComponents.queryItems = addQueryItems(queryParams: queryParams)
    guard let finalURL = urlComponents.url else { return nil }
    return finalURL
  }

  func addQueryItems(queryParams: [String: Any]?) -> [URLQueryItem]? {
    guard let queryParams = queryParams else {
      return nil
    }
    return queryParams.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
  }
}

protocol HttpClient {
  func publisher<T: Decodable>(_ type: T.Type, request: Request, decoder: DataDecoder) -> AnyPublisher<T, Error>
}

final class AlamofireClient: HttpClient {
  private let urlString: String

  init(with urlString: String) {
    self.urlString = urlString
  }

  func publisher<T: Decodable>(_ type: T.Type, request: Request,
                               decoder: DataDecoder = decoder) -> AnyPublisher<T, Error> {
    guard let url = request.asURL(with: urlString) else {
      return Fail(error: NSError(domain: "Sofia", code: 404)).eraseToAnyPublisher()
    }
    return AF.request(
      url,
      method: request.method,
      parameters: request.body,
      encoding: JSONEncoding.default,
      headers: request.asHTTPHeaders()
    )
    .validate()
    .publishDecodable(type: type, decoder: decoder)
    .tryMap { result in
      switch result.result {
      case let .success(data):
        return data
      case let .failure(error):
        if let responseCode = error.responseCode,
           responseCode == 401 {
          KeychainSwift().delete("stringToken")
          KeychainSwift().delete("githubToken")
        }
        throw error
      }
    }
    .eraseToAnyPublisher()
  }
}

final class AlamofireAuthenticatedClient: HttpClient {
  private let token: String
  private let client: HttpClient

  init(token: String, client: HttpClient) {
    self.token = token
    self.client = client
  }

  func publisher<T: Decodable>(_ type: T.Type, request: Request,
                               decoder: DataDecoder = decoder) -> AnyPublisher<T, Error> {
    var request = request
    if request.headers == nil {
      request.headers = [:]
    } else if request.headers?["Authorization"] != nil {
      request.headers?.removeValue(forKey: "Authorization")
    }
    request.headers?["Authorization"] = "Bearer \(token)"
    return client.publisher(type, request: request, decoder: decoder)
  }
}

final class WakaAuthenticatedClient: HttpClient {
  private let client: AlamofireAuthenticatedClient

  init?() {
    guard let token = KeychainSwift().get("stringToken"),
          !token.isEmpty else {
      return nil
    }
    client = AlamofireAuthenticatedClient(token: token, client: AlamofireClient(with: "https://wakatime.com"))
  }

  func publisher<T: Decodable>(_ type: T.Type, request: Request,
                               decoder: DataDecoder = decoder) -> AnyPublisher<T, Error> {
    return client.publisher(type, request: request, decoder: decoder)
  }
}

final class GithubAuthenticatedClient: HttpClient {
  private let client: AlamofireAuthenticatedClient

  init?() {
    guard let token = KeychainSwift().get("githubToken"),
          !token.isEmpty else {
      return nil
    }
    client = AlamofireAuthenticatedClient(token: token, client: AlamofireClient(with: "https://api.github.com"))
  }

  func publisher<T: Decodable>(_ type: T.Type, request: Request,
                               decoder: DataDecoder = decoder) -> AnyPublisher<T, Error> {
    return client.publisher(type, request: request, decoder: decoder)
  }
}
