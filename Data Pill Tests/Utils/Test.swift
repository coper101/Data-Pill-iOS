//
//  Test.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 13/3/23.
//

import Combine
import XCTest

extension XCTestCase {
    
    func createExpectation<Output, E>(
        publisher: AnyPublisher<Output, E>,
        description: String,
        timeout: TimeInterval = 0.5,
        onFailure: @escaping (Error) -> Void = { _ in },
        onSuccess: @escaping (Output) -> Void
    ) {
        let expectation = expectation(description: description)
        var subscriptions = Set<AnyCancellable>()
        
        publisher.sink { completion in
            switch completion {
            case .failure(let error):
                onFailure(error)
                break
            case .finished:
                // called when received value
                break;
            }
            
            expectation.fulfill()
        } receiveValue: { output in
            onSuccess(output)
        }
        .store(in: &subscriptions)

        waitForExpectations(timeout: timeout)
    }
}
