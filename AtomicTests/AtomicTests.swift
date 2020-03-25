//
//  AtomicTests.swift
//  AtomicTests
//
//  Created by Cassius Pacheco on 25/3/20.
//  Copyright © 2020 Cassius Pacheco. All rights reserved.
//

import XCTest
@testable import Atomic

class AtomicTests: XCTestCase {
    @Atomic var array = [Int]()

    func testAtomic() {
        self.measure {
            let expectation = self.expectation(description: "testAtomic")

            DispatchQueue.concurrentPerform(iterations: 100000) { (i) in
                if i % 2 == 0 {
                    self.array.append(i)
                } else {
                    // Access the wrapper in order to synchronise the mutation
                    // to ensure the value doesn't get changed by another thread
                    // during this mutation.
                    self._array.mutate {
                        if !$0.isEmpty {
                            $0.removeLast()
                        }
                    }
                }

                if i == 99999 {
                    expectation.fulfill()
                }
            }

            wait(for: [expectation], timeout: 5.0)
        }
    }
}
