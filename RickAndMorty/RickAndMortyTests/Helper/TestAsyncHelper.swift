//
//  TestAsyncHelper.swift
//  RickAndMorty
//
//  Created by Nicholas Forte on 14/01/26.
//

import XCTest

extension XCTestCase {
    func XCTAssertThrowsErrorAsync<T>(_ expression: @autoclosure () async throws -> T,
                                      _ message: @autoclosure () -> String = "",
                                      file: StaticString = #filePath, line: UInt = #line,
                                      _ errorHandler: (Error) -> Void = { _ in }) async {
        do {
            _ = try await expression()
            XCTFail(message(), file: file, line: line)
        } catch {
            errorHandler(error)
        }
    }
}
