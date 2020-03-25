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
    @AtomicUnfair var unfairArray = [Int]()
    @AtomicPThread var pthreadArray = [Int]()
    @AtomicPThreadRW var pthreadRWArray = [Int]()
    @AtomicSerialQueue var serialArray = [Int]()
    @AtomicBarrierQueue var barrierArray = [Int]()

    func testUnfair() {
        self.measure {
            let expectation = self.expectation(description: "testUnfair")

            DispatchQueue.concurrentPerform(iterations: 100000) { (i) in
                if i % 2 == 0 {
                    self.unfairArray.append(i)
                } else {
                    // Access the wrapper in order to synchronise the mutation
                    // to ensure the value doesn't get changed by another thread
                    // during this mutation.
                    self._unfairArray.mutate {
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

    func testPThread() {
        self.measure {
            let expectation = self.expectation(description: "testPThread")

            DispatchQueue.concurrentPerform(iterations: 100000) { (i) in
                if i % 2 == 0 {
                    self.pthreadArray.append(i)
                } else {
                    // Access the wrapper in order to synchronise the mutation
                    // to ensure the value doesn't get changed by another thread
                    // during this mutation.
                    self._pthreadArray.mutate {
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

    func testBarrier() {
        self.measure {
            let expectation = self.expectation(description: "testBarrier")

            DispatchQueue.concurrentPerform(iterations: 100000) { (i) in
                if i % 2 == 0 {
                    self.barrierArray.append(i)
                } else {
                    // Access the wrapper in order to synchronise the mutation
                    // to ensure the value doesn't get changed by another thread
                    // during this mutation.
                    self._barrierArray.mutate {
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

    func testPThreadRW() {
        self.measure {
            let expectation = self.expectation(description: "testPThreadRW")

            DispatchQueue.concurrentPerform(iterations: 100000) { (i) in
                if i % 2 == 0 {
                    self.pthreadRWArray.append(i)
                } else {
                    // Access the wrapper in order to synchronise the mutation
                    // to ensure the value doesn't get changed by another thread
                    // during this mutation.
                    self._pthreadRWArray.mutate {
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

    func testSerial() {
        self.measure {
            let expectation = self.expectation(description: "testSerial")

            DispatchQueue.concurrentPerform(iterations: 100000) { (i) in
                if i % 2 == 0 {
                    self.serialArray.append(i)
                } else {
                    // Access the wrapper in order to synchronise the mutation
                    // to ensure the value doesn't get changed by another thread
                    // during this mutation.
                    self._serialArray.mutate {
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
