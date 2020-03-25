//
//  Atomic.swift
//  Atomic
//
//  Created by Cassius Pacheco on 25/3/20.
//  Copyright © 2020 Cassius Pacheco. All rights reserved.
//

import Foundation

/// This property wrapper offers a locking mechanism for accessing/mutating values in a safer
/// way. Bear in mind that operations such as `+=` or executions of `if let` to read and then
/// mutate  values are *unsafe*.  Each time you access the variable to read it, it acquires the lock,
/// then once the read is finished it releases it. The following operation is to mutate the value, which
/// requires the lock to be mechanism again, however, another thread may have already claimed the lock
/// in between these two operations and have potentially changed the value. This may cause unexpected
/// results or crashes.
/// In order to ensure you've acquired the lock for a certain amount of time use the `mutate` method.
@propertyWrapper
public final class Atomic<Value> {
    private var value: Value
    private let lock = NSLock()

    public init(wrappedValue: Value) {
        value = wrappedValue
    }

    public var wrappedValue: Value {
        get {
            lock.lock()
            defer { lock.unlock() }
            return value
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            value = newValue
        }
    }

    /// Synchronises mutation to ensure the value doesn't get changed by another thread during this mutation.
    public func mutate(_ mutation: (inout Value) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        mutation(&value)
    }

    /// Synchronises mutation to ensure the value doesn't get changed by another thread during this mutation.
    /// This method returns a value specified in the `mutation` closure.
    public func mutate<T>(_ mutation: (inout Value) -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return mutation(&value)
    }
}

@propertyWrapper
public final class AtomicSerialQueue<Value> {
    private var value: Value
    private let queue = DispatchQueue(label:  "com.cassiuspacheco.serial")

    public init(wrappedValue: Value) {
        value = wrappedValue
    }

    public var wrappedValue: Value {
        get {
            return queue.sync {
                return self.value
            }
        }
        set {
            queue.sync {
                self.value = newValue
            }
        }
    }

    /// Synchronises mutation to ensure the value doesn't get changed by another thread during this mutation.
    public func mutate(_ mutation: (inout Value) -> Void) {
        queue.sync {
            mutation(&self.value)
        }
    }

    /// Synchronises mutation to ensure the value doesn't get changed by another thread during this mutation.
    /// This method returns a value specified in the `mutation` closure.
    public func mutate<T>(_ mutation: (inout Value) -> T) -> T {
        return queue.sync {
            mutation(&self.value)
        }
    }
}

@propertyWrapper
public final class AtomicBarrierQueue<Value> {
    private var value: Value
    private let queue = DispatchQueue(label: "com.cassiuspacheco.barrier", attributes: .concurrent)

    public init(wrappedValue: Value) {
        value = wrappedValue
    }

    public var wrappedValue: Value {
        get {
            return queue.sync {
                return self.value
            }
        }
        set {
            queue.async(flags: .barrier) {
                self.value = newValue
            }
        }
    }

    /// Synchronises mutation to ensure the value doesn't get changed by another thread during this mutation.
    public func mutate(_ mutation: @escaping (inout Value) -> Void) {
        queue.async(flags: .barrier) {
            mutation(&self.value)
        }
    }

    /// Synchronises mutation to ensure the value doesn't get changed by another thread during this mutation.
    /// This method returns a value specified in the `mutation` closure.
    public func mutate<T>(_ mutation: (inout Value) -> T) -> T {
        return queue.sync {
            mutation(&self.value)
        }
    }
}

@propertyWrapper
public final class AtomicPThread<Value> {
    private var value: Value
    var mutex = pthread_mutex_t()

    public init(wrappedValue: Value) {
        value = wrappedValue
        pthread_mutex_init(&mutex, nil)
    }

    public var wrappedValue: Value {
        get {
            pthread_mutex_lock(&mutex)
            defer { pthread_mutex_unlock(&mutex) }
            return value
        }
        set {
            pthread_mutex_lock(&mutex)
            defer { pthread_mutex_unlock(&mutex) }
            value = newValue
        }
    }

    /// Synchronises mutation to ensure the value doesn't get changed by another thread during this mutation.
    public func mutate(_ mutation: (inout Value) -> Void) {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }
        mutation(&value)
    }

    /// Synchronises mutation to ensure the value doesn't get changed by another thread during this mutation.
    /// This method returns a value specified in the `mutation` closure.
    public func mutate<T>(_ mutation: (inout Value) -> T) -> T {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }
        return mutation(&value)
    }
}

@propertyWrapper
public final class AtomicPThreadRW<Value> {
    private var value: Value
    var mutex = pthread_rwlock_t()

    public init(wrappedValue: Value) {
        value = wrappedValue
        pthread_rwlock_init(&mutex, nil)
    }

    public var wrappedValue: Value {
        get {
            pthread_rwlock_rdlock(&mutex)
            defer { pthread_rwlock_unlock(&mutex) }
            return value
        }
        set {
            pthread_rwlock_wrlock(&mutex)
            defer { pthread_rwlock_unlock(&mutex) }
            value = newValue
        }
    }

    /// Synchronises mutation to ensure the value doesn't get changed by another thread during this mutation.
    public func mutate(_ mutation: (inout Value) -> Void) {
        pthread_rwlock_wrlock(&mutex)
        defer { pthread_rwlock_unlock(&mutex) }
        mutation(&value)
    }

    /// Synchronises mutation to ensure the value doesn't get changed by another thread during this mutation.
    /// This method returns a value specified in the `mutation` closure.
    public func mutate<T>(_ mutation: (inout Value) -> T) -> T {
        pthread_rwlock_wrlock(&mutex)
        defer { pthread_rwlock_unlock(&mutex) }
        return mutation(&value)
    }
}

@propertyWrapper
public final class AtomicUnfair<Value> {
    private var value: Value
    private var lock: os_unfair_lock

    public init(wrappedValue: Value) {
        value = wrappedValue
        lock = os_unfair_lock()
    }

    public var wrappedValue: Value {
        get {
            os_unfair_lock_lock(&lock)
            defer { os_unfair_lock_unlock(&lock) }
            return value
        }
        set {
            os_unfair_lock_lock(&lock)
            defer { os_unfair_lock_unlock(&lock) }
            value = newValue
        }
    }

    /// Synchronises mutation to ensure the value doesn't get changed by another thread during this mutation.
    public func mutate(_ mutation: (inout Value) -> Void) {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        mutation(&value)
    }

    /// Synchronises mutation to ensure the value doesn't get changed by another thread during this mutation.
    /// This method returns a value specified in the `mutation` closure.
    public func mutate<T>(_ mutation: (inout Value) -> T) -> T {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return mutation(&value)
    }
}
