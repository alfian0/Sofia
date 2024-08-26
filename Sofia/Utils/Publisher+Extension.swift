//
//  Publisher+Extension.swift
//  Sofia
//
//  Created by Alfian on 26/08/24.
//

import Combine

extension Publisher {
  func sink(result: @escaping ((Result<Self.Output, Self.Failure>) -> Void)) -> AnyCancellable {
    return sink { completion in
      switch completion {
      case let .failure(error):
        result(.failure(error))
      case .finished:
        break
      }
    } receiveValue: { output in
      result(.success(output))
    }
  }
}
