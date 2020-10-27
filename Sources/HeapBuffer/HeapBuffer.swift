//
// HeapBuffer
// HeapBuffer.swift
//
// Created by Valeriano Della Longa on 2020/10/8.
// Copyright © 2020 Valeriano Della Longa. All rights reserved.
//
//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
//  SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
//  IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

/// A memory buffer which keeps its stored elements in an order so that each stored element satisfies
/// the heap property established by a sort function.
///
/// This reference sematics type can be used as underlaying storage of data structures leveraging on a Heap as their
/// backed storage system.
final public class HeapBuffer<Element> {
    let _sort: (Element, Element) -> Bool
    
    private(set) var _elements: UnsafeMutablePointer<Element>
    
    private(set) var _capacity: Int
    
    private(set) var _elementsCount: Int
    
    /// Returns a new and empty `HeapBuffer` instance initialized to use the given sort function for ensuring the heap
    /// property on its elements and able to store contiguously the specified count of elements.
    ///
    /// The sort closure must be a *strict weak ordering* over the elements. That
    /// is, for any elements `a`, `b`, and `c`, the following conditions must
    /// hold:
    ///
    /// - `sort(a, a)` is always `false`. (Irreflexivity)
    /// - If `sort(a, b)` and `sort(b, c)` are
    ///   both `true`, then `sort(a, c)` is also `true`.
    ///   (Transitive comparability)
    /// - Two elements are *incomparable* if neither is ordered before the other
    ///   according to the sort closure. If `a` and `b` are incomparable, and `b`
    ///   and `c` are incomparable, then `a` and `c` are also incomparable.
    ///   (Transitive incomparability)
    ///
    /// - Parameter _:  a positive `Int` value representing the minimum count of elements the new buffer can to
    ///                 store contiguously. **Must  not be negative**.
    /// - Parameter sort:   a closure that given two elements returns either `true` if they are sorted, or `false`
    ///                     if they aren't sorted.
    /// - Returns: a new `HeapBuffer` instance initialized to the given sort and able to store contiguosuly at least
    ///            the specified count of elements.
    public init(_ capacity: Int = 0, sort: @escaping (Element, Element) -> Bool) {
        self._capacity = Self._convenientCapacityFor(capacity: capacity)
        self._elements = UnsafeMutablePointer<Element>.allocate(capacity: self._capacity)
        self._elementsCount = 0
        self._sort = sort
    }
    
    /// Creates a new instance containing the specified number of a single,
    /// repeated value, using the given sort function for ensuring the heap
    /// property on its elements.
    ///
    /// The following example creates a max heap initialized with five strings
    /// containing the letter *Z*.
    ///
    ///     let fiveZs = HeapBuffer(repeating: "Z", count: 5, sort: >)
    ///     print(fiveZs)
    ///     // Prints "["Z", "Z", "Z", "Z", "Z"]"
    ///
    /// The sort closure must be a *strict weak ordering* over the elements. That
    /// is, for any elements `a`, `b`, and `c`, the following conditions must
    /// hold:
    ///
    /// - `sort(a, a)` is always `false`. (Irreflexivity)
    /// - If `sort(a, b)` and `sort(b, c)` are
    ///   both `true`, then `sort(a, c)` is also `true`.
    ///   (Transitive comparability)
    /// - Two elements are *incomparable* if neither is ordered before the other
    ///   according to the sort closure. If `a` and `b` are incomparable, and `b`
    ///   and `c` are incomparable, then `a` and `c` are also incomparable.
    ///   (Transitive incomparability)
    ///
    /// - Parameters:
    ///   - repeatedValue: The element to repeat.
    ///   - count: The number of times to repeat the value passed in the
    ///            `repeating` parameter. `count` must be zero or greater.
    ///   - sort: a closure that given two elements returns either `true` if they are sorted, or `false`
    ///           if they aren't sorted.
    public init(repeating repeatedValue: Element, count: Int, sort: @escaping (Element, Element) -> Bool) {
        self._capacity = Self._convenientCapacityFor(capacity: count)
        self._elements = UnsafeMutablePointer<Element>.allocate(capacity: self._capacity)
        self._elementsCount = count
        self._sort = sort
        self._elements.initialize(repeating: repeatedValue, count: count)
    }
    
    deinit {
        _elements.deinitialize(count: _elementsCount)
        _elements.deallocate()
    }
    
}

// MARK: - Public interface
extension HeapBuffer {
    /// The number of stored elements.
    ///
    /// - Complexity: O(1)
    public var count: Int { _elementsCount }
    
    /// A Boolean value indicating whether the heap buffer is empty.
    ///
    /// - Complexity: O(1)
    public var isEmpty: Bool { _elementsCount == 0 }
    
    /// The total number of elements that the instance can contain without
    /// allocating new storage.
    ///
    /// Every instance reserves a specific amount of memory to hold its contents.
    /// When you add elements to a HeapBuffer instance and that instance begins to exceed its
    /// reserved capacity, the instance allocates a larger region of memory and
    /// copies its elements into the new storage. The new storage is a multiple
    /// of the old storage's size. This exponential growth strategy means that
    /// enqueueing an element happens in constant time, averaging the performance
    /// of many enqueue operations. Enqueue operations that trigger reallocation
    /// have a performance cost, but they occur less and less often as the instance
    /// grows larger.
    ///
    /// The following example creates a HeapBuffer of integers from an array,
    /// then enqueue the elements of another collection. Before appending, the
    /// instance allocates new storage that is large enough store the resulting
    /// elements.
    ///
    ///     let heap = HeapBuffer([10, 20, 30, 40], heaptype: .minHeap)
    ///     // heap.count == 4
    ///     // heap.capacity == 4
    ///
    ///     heap.insert(elements: [50, 60, 70, 80], at: 4)
    ///     // numbers.count == 8
    ///     // numbers.capacity == 8
    /// - Complexity: O(1)
    public var capacity: Int { _capacity }
    
    /// A Boolean value indicating whether the heap buffer storage is full.
    ///
    /// - Complexity: O(1)
    public var isFull: Bool { _isFull }
    
    /// The position of the first element in a nonempty HeapBuffer.
    ///
    /// For an instance of `HeapBuffer`, `startIndex` is always zero. If the HeapBuffer
    /// is empty, `startIndex` is equal to `endIndex`
    public var startIndex: Int { 0 }
    
    /// The HeapBuffer's "past the end" position---that is, the position one greater
    /// than the last valid subscript argument.
    ///
    /// When you need a range that includes the last element of an HepBuffer, use the
    /// half-open range operator (`..<`) with `endIndex`. The `..<` operator
    /// creates a range that doesn't include the upper bound, so it's always
    /// safe to use with `endIndex`. For example:
    ///
    ///     let heapMin = HeapBuffer([10, 20, 30, 40, 50], heapType: .minHeap)
    ///     for i in 3..<heapMin.endIndex {
    ///         print(heapMin[i])
    ///     }
    ///     // Prints "[30, 40, 50]"
    ///
    /// If the HeapBuffer is empty, `endIndex` is equal to `startIndex`.
    public var endIndex: Int { _elementsCount }
    
    /// Returns a new `HeapBuffer` instance initialized to use the given sort, and containing the elements of the given
    /// sequence.
    ///
    /// The sort closure must be a *strict weak ordering* over the elements. That
    /// is, for any elements `a`, `b`, and `c`, the following conditions must
    /// hold:
    ///
    /// - `sort(a, a)` is always `false`. (Irreflexivity)
    /// - If `sort(a, b)` and `sort(b, c)` are
    ///   both `true`, then `sort(a, c)` is also `true`.
    ///   (Transitive comparability)
    /// - Two elements are *incomparable* if neither is ordered before the other
    ///   according to the sort closure. If `a` and `b` are incomparable, and `b`
    ///   and `c` are incomparable, then `a` and `c` are also incomparable.
    ///   (Transitive incomparability)
    ///
    /// - Parameter _: a sequence of elements to store.
    /// - Parameter sort:   a closure that given two elements returns either `true` if they are sorted, or `false`
    ///                     if they aren't sorted.
    /// - Returns:  a new `HeapBuffer` instance initialized to use the given sort and storing all the elements
    ///             of the given sequence, heap ordered as dictated by the sort criteria.
    /// - Complexity: O(log *n*) where *n* is the number of elements stored in the given sequence.
    public convenience init<S: Sequence>(_ elements: S, sort: @escaping (Element, Element) -> Bool) where S.Iterator.Element == Element {
        self.init(elements.underestimatedCount, sort: sort)
        
        // copy elements from contiguous storage buffer in case the sequence provides it:
        if let _ = elements
            .withContiguousStorageIfAvailable({ buffer -> Bool in
                if buffer.baseAddress != nil && buffer.count != 0 {
                    // we've got elements in the storage to copy…
                    // let's first calculate the effective capacity needed:
                    let effectiveCapacity = Self._convenientCapacityFor(capacity: buffer.count)
                    // check if we have to increase underlaying capacity:
                    if self._capacity < effectiveCapacity {
                        self._elements.deallocate()
                        self._elements = UnsafeMutablePointer<Element>.allocate(capacity: effectiveCapacity)
                        self._capacity = effectiveCapacity
                    }
                    self._elements.initialize(from: buffer.baseAddress!, count: buffer.count)
                    self._elementsCount = buffer.count
                }
                
                return true
            })
        {
            // the copy from contiguous buffer went fine. We now need to turn it into a
            // Heap and then we're done.
            _buildHeap()
            
            return
        }
        // Otherwise we might as well have to insert elements from
        // the given sequence iteratively…
        var iter = elements.makeIterator()
        if let firstElement = iter.next() {
            // yes we do…
            _elementsCount += 1
            _elements.initialize(to: firstElement)
            while let newElement = iter.next() {
                if _isFull {
                    _growToNextCapacityLevel()
                }
                insert(newElement)
            }
        }
    }
    
    /// Creates and returns a copy of the callee, eventually incresasing the free contiguous storage of the returned instance
    /// so it can additionally hold the specified number of elements.
    ///
    /// - Parameter reservingCapacity:  the amount of minimum free slots the copy must be able to store.
    ///                                 **Must be positive**, defaults to `0`.
    /// - Returns:  a new `HeapBuffer` instance contianing the same elements of the callee, using the same
    ///             sort criteria and with at least the specified number of free slots in its storage.
    public func copy(reservingCapacity minCapacity: Int = 0) -> Self {
        precondition(minCapacity >= 0)
        let additionalCapacity = _capacityLeft >= minCapacity ? 0 : minCapacity - _capacityLeft
        
        return Self.init(from: self, additionalCapacity: additionalCapacity)
    }
    
    /// Eventually increases callee capacity, so it will have free contiguous storage for the given count of elements.
    ///
    /// - Parameter _:  A postive `Int` value representing the minimum count of contiguous free spots this buffer
    ///                 should reserve. Must be greater than or equal to `0`.
    public func reserveCapacity(_ minCapacity: Int) {
        precondition(minCapacity >= 0)
        guard _capacityLeft < minCapacity else { return }
        
        let newCapacity = Self._convenientCapacityFor(capacity: _elementsCount + minCapacity)
        _resizeElements(to: newCapacity)
    }
    
    /// Calls the given closure on each element in the storage in the same order as a for-in loop.
    ///
    /// The two loops in the following example produce the same output:
    /// ```
    /// let numbers = HeapBuffer(elements: [1, 2, 3], sort: <)
    /// for i in numbers.startIndex..<numbers.endIndex {
    ///    print(numbers[i])
    /// }
    /// // Prints 1
    /// // Prints 2
    /// // Prints 3
    ///
    /// numbers.forEach { number in
    ///     print(number)
    /// }
    /// // Same as above
    /// ```
    /// Using the forEach method is distinct from a for-in loop in two important ways:
    /// 1. You cannot use a break or continue statement to exit the current call of the body closure or skip subsequent calls.
    /// 2. Using the return statement in the body closure will exit only from the current call to body, not from any outer
    /// scope, and won’t skip subsequent calls.
    /// - Parameter _: A closure that takes an element of the storage as a parameter.
    public func forEach(_ body: (Element) throws -> ()) rethrows {
        try levelOrder(body: body)
    }
    
}

// MARK: - Operations on elements
extension HeapBuffer {
    /// Returns without removing it the root element of the heap, when storage is not empty, otherwise `nil`.
    ///
    /// - Returns: root element of the heap, otherwise `nil` when no elements are stored.
    /// - Complexity: O(1)
    /// - Note: when `isEmpty == false` returns the same element of subscripting to index position `0`.
    public func peek() -> Element? {
        guard !isEmpty else { return nil }
        
        return _elements.pointee
    }
    
    /// Stores specified element, maintaining the heap property.
    ///
    /// - Parameter _: the new element to store in the heap.
    /// - Complexity: O(log *n*) where *n* is the count of elements stored in the buffer after the insertion.
    public func push(_ newElement: Element) {
        if _isFull { _growToNextCapacityLevel() }
        _elements.advanced(by: _elementsCount).initialize(to: newElement)
        _elementsCount += 1
        _siftUp(from: _elementsCount - 1)
    }
    
    /// Stores specified element, maintaining the heap property.
    ///
    /// - Parameter _: the new element to store in the heap.
    /// - Complexity: O(log *n*) where *n* is the count of elements stored in the buffer after the insertion.
    /// - Note: same as `push(_:)`.
    public func insert(_ newElement: Element) {
        push(newElement)
    }
    
    /// Insert given new element at specified position, maintaining the heap property.
    ///
    /// - Parameter _: the element to insert
    /// - Parameter at: the `index` position where to insert the new element, **must not be negative** and
    ///                 in range `startIndex...endIndex` of the instance.
    /// - Complexity: O(log *n*) where *n* is the count of stored elements after the insertion.
    public func insert(_ newElement: Element, at idx: Int) {
        precondition(idx >= 0 && idx <= _elementsCount)
        guard idx != _elementsCount
        else {
            push(newElement)
            return
        }
        
        guard !_isFull
        else {
            let newCapacity = Self._convenientCapacityFor(capacity: _capacity + 1)
            let newBuff = UnsafeMutablePointer<Element>.allocate(capacity: newCapacity)
            _capacity = newCapacity
            newBuff.advanced(by: idx).initialize(to: newElement)
            newBuff.moveInitialize(from: _elements, count: idx)
            newBuff.advanced(by: idx + 1).initialize(from: _elements.advanced(by: idx), count: _elementsCount - idx)
            _elements.deallocate()
            _elements = newBuff
            _elementsCount += 1
            _buildHeap()
            
            return
        }
        
        let shiftedCount = _elementsCount - idx
        let tmp = UnsafeMutablePointer<Element>.allocate(capacity: shiftedCount)
        tmp.moveInitialize(from: _elements.advanced(by: idx), count: shiftedCount)
        _elements.advanced(by: idx + 1).moveInitialize(from: tmp, count: shiftedCount)
        tmp.deallocate()
        _elements.advanced(by: idx).initialize(to: newElement)
        _elementsCount += 1
        _buildHeap()
    }
    
    /// Inserts given collection of elements at specified index, maintaining the heap property.
    ///
    /// - Parameter contentsOf: a collection of elements to insert in the callee.
    /// - Parameter at: the index of the callee where to start to insert the elements. **Must be positive** and in
    ///                 range `startIndex...endIndex` of the instance.
    /// - Complexity:   O(log *n*) where *n* is the count of elements of the instance after the insertion,
    ///                 when the given collection implements `withContiguousStorageIfAvailable(_:)`
    ///                 method, otherwise O(*k*\times log *n*) where *k* is the count of the elements in the given
    ///                 collection, and *n* is the count of elements of the instance after the insertion.
    public func insert<C: Collection>(contentsOf newElements: C, at idx: Int) where C.Iterator.Element == Element {
        precondition(idx >= 0 && idx <= _elementsCount)
        
        guard !newElements.isEmpty else { return }
        
        let newCapacity = Self._convenientCapacityFor(capacity: _elementsCount + newElements.count)
        // copy newElements inside the newBuffer:
        let newBuff = UnsafeMutablePointer<Element>.allocate(capacity: newCapacity)
        let done: Bool = newElements
            .withContiguousStorageIfAvailable {  buff in
                guard
                    buff.baseAddress != nil && buff.count != 0
                else { return false }
                
                newBuff.advanced(by: idx).initialize(from: buff.baseAddress!, count: buff.count)
                
                return true
            } ?? false
        if !done {
            var i = 0
            for newElement in newElements {
                newBuff.advanced(by: idx + i).initialize(to: newElement)
                i += 1
            }
        }
        // move _elements into newBuffer:
        newBuff.moveInitialize(from: _elements, count: idx)
        newBuff.advanced(by: idx + newElements.count).moveInitialize(from: _elements.advanced(by: idx), count: _elementsCount - idx)
        _elements.deallocate()
        _elements = newBuff
        _capacity = newCapacity
        _elementsCount += newElements.count
        _buildHeap()
    }
    
    /// Eventually removes and returns the root of the heap, maintaining the heap property.
    ///
    /// - Returns: the root element when not empty, otherwise `nil`.
    /// - Note: when not empty removes and returns the element stored at index `0`.
    /// - Complexity: O(log *n*) where *n* is the count of stored elements after the removal.
    @discardableResult
    public func extract() -> Element? {
        guard !isEmpty else { return nil }
        
        return pop()
    }
    
    /// Removes and then returns the root of the heap, maintaining the heap property.
    /// Callee **must not be empty**.
    ///
    /// - Returns: the root element.
    /// - Complexity: O(log *n*) where *n* is the count of stored elements after the removal.
    @discardableResult
    public func pop() -> Element {
        precondition(!isEmpty)
        
        _swapElementsAt(0, _elementsCount - 1)
        let element = _elements.advanced(by: _elementsCount - 1).move()
        defer {
            _elementsCount -= 1
            _siftDown(from: 0)
            _reduceCapacityToCurrentCount()
        }
        
        return element
    }
    
    /// Removes and returns the element at specified index, maintaining the heap property.
    /// **Callee must not be empty**.
    ///
    /// - Parameter at: the index of the element to remove. Must not be negative and in
    ///                 range `startIndex..<endIndex` of the instance.
    /// - Returns: the element stored at given index.
    /// - Note: when given `0` as index value, returns the same element of `pop()`.
    /// - Complexity :  O(log *n*) where *n* is the count of stored elements after the removal.
    @discardableResult
    public func remove(at index: Int) -> Element {
        _checkSubscriptBounds(on: index)
        if index == _elementsCount - 1 {
            let element = _elements.advanced(by: index).move()
            defer {
                _elementsCount -= 1
                _reduceCapacityToCurrentCount()
            }
            
            return element
        }
        
        _swapElementsAt(index, _elementsCount - 1)
        let element = _elements.advanced(by: _elementsCount - 1).move()
        defer {
            _elementsCount -= 1
            _siftDown(from: index)
            _siftUp(from: index)
            _reduceCapacityToCurrentCount()
        }
        
        return element
    }
    
    /// Removes and returns given count of elements from storage starting from the specified index, eventually
    /// keeping the storage capacity, and maintainig the heap property.
    ///
    /// - Parameter at:     the index where to start the removal. **Must not be negative** and in range
    ///                     `startIndex..<endIndex` for the instance.
    /// - Parameter count:  the number of elements to remove.
    ///                     **Must not be negative and less tha or equal the number of elelemnts stored **
    ///                     **between the specified index and the last one**
    /// - Parameter keepingCapacity:    flags if storage capacity has to be kept after the removal or
    ///                                 should be reduced. Defaults to `false`
    /// - Returns:  an array containing the removed elements appearing in the same order
    ///             they were stored inside the storage.
    /// - Complexity: O(log *n*) where *n* is the count of elements after the removal.
    @discardableResult
    public func remove(at idx: Int, count k: Int, keepingCapacity: Bool = false) -> [Element] {
        precondition(idx >= 0 && idx < _elementsCount)
        precondition(k >= 0 && k <= _elementsCount - idx)
        guard
            k != 0
        else {
            defer {
                if !keepingCapacity { _reduceCapacityToCurrentCount() }
            }
            
            return []
        }
        
        if idx == 0 && k == _elementsCount {
            // we ought remove all elements!
            defer {
                _elements.deinitialize(count: _elementsCount)
                _elementsCount = 0
                if !keepingCapacity {
                    _elements.deallocate()
                    _elements = UnsafeMutablePointer<Element>.allocate(capacity: Self._minCapacity)
                    _capacity = Self._minCapacity
                }
            }
            
            return Array(UnsafeMutableBufferPointer(start: _elements, count: _elementsCount))
        }
        
        // we ought remove some elements
        defer {
            let newCapacity = keepingCapacity ? _capacity : Self._convenientCapacityFor(capacity: _elementsCount - k)
            let newBuff = UnsafeMutablePointer<Element>.allocate(capacity: newCapacity)
            newBuff.moveInitialize(from: _elements.advanced(by: 0), count: idx)
            let remainderCount = _elementsCount - (idx + k)
            newBuff.advanced(by: idx).moveInitialize(from: _elements.advanced(by: idx + k), count: remainderCount)
            _elements.deallocate()
            _elements = newBuff
            _capacity = newCapacity
            _elementsCount -= k
            _buildHeap()
        }
        let resultPointer = UnsafeMutablePointer<Element>.allocate(capacity: k)
        resultPointer.moveInitialize(from: _elements.advanced(by: idx), count: k)
        
        return Array(UnsafeMutableBufferPointer(start: resultPointer, count: k))
    }
    
    /// Inserts the specified element in the heap maintaining the heap property, than pops the root element.
    ///
    /// - Parameter _: the element to store
    /// - Returns: the topmost element of the heap.
    /// - Complexity: O(log *n*) where *n* is the count of stored elements.
    @discardableResult
    public func pushPop(_ newElement: Element) -> Element {
        guard !isEmpty && !_sort(newElement, _elements[0])
            else { return newElement }
        
        var result = newElement
        swap(&result, &_elements[0])
        defer {
            _siftDown(from: 0)
        }
        
        return result
    }
    
    /// Returns the root element and replaces it with the specified one, maininting the heap property.
    /// **Callee must not be empty**.
    ///
    /// - Parameter _: the new element replacing the root one.
    /// - Returns: the former root element.
    /// - Complexity: O(log *n*) where *n* is the count of stored elements.
    @discardableResult
    public func replace(_ newElement: Element) -> Element {
        precondition(!isEmpty)
        
        var result = newElement
        swap(&result, &_elements[0])
        defer {
            _siftDown(from: 0)
        }
        
        return result
    }
    
    /// Replaces elements in the storage at the specified subrange with contents from given collection of new elements,
    /// maintaining the heap property.
    ///
    /// - Parameter subrange:   a range expression representing the indexes of elements to replace.
    ///                         **Must be contained or equal to range** `startIndex...endIndex` for
    ///                         the instance.
    /// - Parameter with: a collection of new elements to insert in place of the removed ones.
    /// - Complexity:   O(log *n*) where *n* is the count of elements resulting by the replace operation when
    ///                 the given collection implements `withContiguousStorageIfAvailable(_:)`,
    ///                 otherwise O(*k*\times log *n*) where *k* is the count of elements in the given collection,
    ///                 and *n* is the count of elements resulting by the replace operation.
    public func replace<C: Collection>(subrange: Range<Int>, with newElements: C) where C.Iterator.Element == Element {
        precondition(subrange.lowerBound >= 0 && subrange.upperBound <= _elementsCount, "range of indexes out of bounds")
        if subrange.count == 0 {
            // It's an insertion
            guard !newElements.isEmpty else { return }
            
            insert(contentsOf: newElements, at: subrange.lowerBound)
        } else {
            // subrange count is greater than zero…
            if newElements.isEmpty {
                // but newElements is empty, though it's a delete operation:
                remove(at: subrange.lowerBound, count: subrange.count)
            } else {
                // newElements is not empty, it's effectively a replace operation:
                let newCount = _elementsCount - subrange.count + newElements.count
                let newCapacity = Self._convenientCapacityFor(capacity: newCount)
                let newBuff = UnsafeMutablePointer<Element>.allocate(capacity: newCapacity)
                
                // move into newBuff newElements in the right position:
                let done = newElements.withContiguousStorageIfAvailable { storage in
                    guard storage.baseAddress != nil && storage.count > 0
                    else { return false}
                    newBuff.advanced(by: subrange.lowerBound).initialize(from: storage.baseAddress!, count: storage.count)
                    
                    return true
                } ?? false
                if !done {
                    var adv = subrange.lowerBound
                    for newElement in newElements {
                        newBuff.advanced(by: adv).initialize(to: newElement)
                        adv += 1
                    }
                }
                
                // move from _elements to newBuffer only the elements kept
                newBuff.moveInitialize(from: _elements, count: subrange.lowerBound)
                let remainderCount = _elementsCount - (subrange.lowerBound + subrange.count)
                newBuff.advanced(by: subrange.lowerBound + newElements.count).moveInitialize(from: _elements.advanced(by: subrange.lowerBound + subrange.count), count: remainderCount)
                _elements.deallocate()
                _elements = newBuff
                _capacity = newCapacity
                _elementsCount = newCount
                _buildHeap()
            }
        }
    }
    
    /// Access stored element at specified position.
    ///
    /// - Parameter _:  an `Int` value representing the `index` of the element to access.
    ///                 The range of possible indexes is zero-based —i.e. first element stored is at index 0.
    ///                 Must be greater than or equal `startIndex` and less than `endIndex` value of
    ///                 the instance.
    ///                 **When isEmpty is true, no index value is valid for subscript.**
    /// - Complexity:   O(1) for read access, O(log *n*) for write access where *n* is the count of stored elements.
    public subscript(_ position: Int) -> Element {
        get {
            _checkSubscriptBounds(on: position)
            
            return _elements.advanced(by: position).pointee
        }
        
        set {
            _checkSubscriptBounds(on: position)
            let oldValue = _elements.advanced(by: position).move()
            _elements.advanced(by: position).initialize(to: newValue)
            if !_sort(newValue, oldValue) {
                _siftDown(from: position)
            } else {
                _siftUp(from: position)
            }
        }
    }
    
    /// Calls a closure with a pointer to the HeapBuffer contiguous storage.
    ///
    /// Often, the optimizer can eliminate bounds checks within an HeapBuffer
    /// algorithm, but when that fails, invoking the same algorithm on the
    /// buffer pointer passed into your closure lets you trade safety for speed.
    ///
    /// The pointer passed as an argument to `body` is valid only during the
    /// execution of `withUnsafeBufferPointer(_:)`. Do not store or return the
    /// pointer for later use.
    ///
    /// - Parameter body:   A closure with an `UnsafeBufferPointer` parameter that
    ///                     points to the contiguous storage for the HeapBuffer.  If no such storage exists, it is
    ///                     created. If `body` has a return value, that value is also used as the return value
    ///                     for the `withUnsafeBufferPointer(_:)` method. The pointer argument is
    ///                     valid only for the duration of the method's execution.
    /// - Returns: The return value, if any, of the `body` closure parameter.
    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<Element>) throws -> R ) rethrows -> R {
        let buff = UnsafeBufferPointer<Element>(start: self._elements, count: self._elementsCount)
            
        return try body(buff)
    }
    
    /// Calls the given closure with a pointer to the HeapBuffer's mutable contiguous
    /// storage, restoring the heap property at the end of the operation.
    ///
    /// Often, the optimizer can eliminate bounds checks within an HeapBuffer
    /// algorithm, but when that fails, invoking the same algorithm on the
    /// buffer pointer passed into your closure lets you trade safety for speed.
    /// Moreover this method allows the manipulation of the stored elements without the overhead
    ///  of restoring the Heap Property after each element is mutated.
    /// The Heap Property will be restored instead after `withUnsafeMutableBufferPointer` execution.
    ///
    /// The pointer passed as an argument to `body` is valid only during the
    /// execution of `withUnsafeMutableBufferPointer(_:)`. Do not store or
    /// return the pointer for later use.
    ///
    /// - Warning:  Do not rely on anything about the HeapBuffer that is the target of
    ///             this method during execution of the `body` closure; it might not
    ///             appear to have its correct value. Instead, use only the
    ///             `UnsafeMutableBufferPointer` argument to `body`.
    ///
    /// - Parameter body:   A closure with an `UnsafeMutableBufferPointer`
    ///                     parameter that points to the contiguous storage for the HeapBuffer.
    ///                     If no such storage exists, it is created. If `body` has a return value, that value is also
    ///                     used as the return value for the `withUnsafeMutableBufferPointer(_:)`
    ///                     method. The pointer argument is valid only for the duration of the
    ///                     method's execution.
    /// - Returns: The return value, if any, of the `body` closure parameter.
    public func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Element>) throws -> R) rethrows -> R {
        let originalElements = _elements
        let originalCount = _elementsCount
        let originalCapacity = _capacity
        var buff = UnsafeMutableBufferPointer(start: originalElements, count: originalCount)
        _elements = UnsafeMutablePointer<Element>.allocate(capacity: Self._minCapacity)
        _elementsCount = 0
        _capacity = Self._minCapacity
        defer {
            precondition(buff.baseAddress == originalElements && buff.count == originalCount, "HeapBuffer withUnsafeMutableBufferPointer: replacing the buffer is not allowed")
            _elements.deallocate()
            _elements = originalElements
            _capacity = originalCapacity
            _elementsCount = originalCount
            _buildHeap()
        }
        
        return try body(&buff)
    }
    
}

// MARK: - Heap traversing
extension HeapBuffer {
    /// Traverses stored elements in post-order from the specified position to the last one, executing with each one
    /// the specified closure.
    ///
    /// - Parameter from:   the `index` position from where the traverse should start.
    ///                     **Must not be negative**, defaults to `startIndex`.
    /// - Parameter body: a closure to execute with each element encountered on the traverse.
    public func postOrder(from idx: Int = 0, body: (Element) throws ->  ()) rethrows {
        precondition(idx >= 0)
        guard !isEmpty && idx < _elementsCount else { return }
        
        let leftChild = _leftChildIndexOf(parentAt: idx)
        try postOrder(from: leftChild, body: body)
        
        let rightChild = _rightChildIndexOf(parentAt: idx)
        try postOrder(from: rightChild, body: body)
        
        try body(_elements[idx])
    }
    
    /// Traverses stored elements in-order from the specified position to the last one, executing with each one
    /// the specified closure.
    ///
    /// - Parameter from:   the `index` position from where the traverse should start.
    ///                     **Must not be negative**, defaults to `startIndex`.
    /// - Parameter body: a closure to execute with each element encountered on the traverse.
    public func inOrder(from idx: Int = 0, body: (Element) throws -> ()) rethrows {
        precondition(idx >= 0)
        guard !isEmpty && idx < _elementsCount else { return }
        
        let leftChild = _leftChildIndexOf(parentAt: idx)
        try inOrder(from: leftChild, body: body)
        
        try body(_elements[idx])
        
        let rightChild = _rightChildIndexOf(parentAt: idx)
        try inOrder(from: rightChild, body: body)
    }
    
    /// Traverses stored elements pre-order from the specified position to the last one, executing with each one
    /// the specified closure.
    ///
    /// - Parameter from:   the `index` position from where the traverse should start.
    ///                     **Must not be negative**, defaults to `startIndex`.
    /// - Parameter body: a closure to execute with each element encountered on the traverse.
    public func preOrder(from idx: Int = 0, body: (Element) throws -> ()) rethrows {
        precondition(idx >= 0)
        guard !isEmpty && idx < _elementsCount else { return }
        
        try body(_elements[idx])
        
        let leftChild = _leftChildIndexOf(parentAt: idx)
        try preOrder(from: leftChild, body: body)
        
        let rightChild = _rightChildIndexOf(parentAt: idx)
        try preOrder(from: rightChild, body: body)
    }
    
    /// Traverses stored elements in level-order (breadth-first) from the specified position to the last one, executing with
    /// each one the specified closure.
    ///
    /// - Parameter from:   the `index` position from where the traverse should start.
    ///                     **Must not be negative**, defaults to `startIndex`.
    /// - Parameter body: a closure to execute with each element encountered on the traverse.
    public func levelOrder(from idx: Int = 0, body: (Element) throws -> ()) rethrows {
        precondition(idx >= 0)
        guard !isEmpty && idx < _elementsCount else { return }
        
        for i in idx..<_elementsCount {
            try body(_elements[i])
        }
    }
    
}

extension HeapBuffer where Element: Equatable {
    /// Eventually returns the index of given element if present between the specified position and the last stored element,
    /// otherwise `nil`.
    ///
    /// - Parameter _: the element to look for.
    /// - Parameter startingAt: the `index` position where to start searching for the specified element.
    ///                         **Must not be negative **, defaults to `startIndex`.
    /// - Returns:  the index position of the specified element if it is stored between the the specified index and the last
    ///             stored element, otherwise `nil`
    public func indexOf(_ element: Element, startingAt i: Int = 0) -> Int? {
        precondition(i >= 0)
        guard !isEmpty && i < _elementsCount else { return nil }
        
        if _sort(element, _elements[i]) { return nil }
        
        if element == _elements[i] { return i }
        
        if let j = indexOf(element, startingAt: _leftChildIndexOf(parentAt: i)) {
            return j
        }
        
        if let j = indexOf(element, startingAt: _rightChildIndexOf(parentAt: i)) {
            return j
        }
        
        return nil
    }
    
}

extension HeapBuffer where Element: Comparable {
    /// A value representing a type of Heap.
    public enum HeapType {
        /// A Heap storing elements in ascending order.
        case minHeap
        /// A Heap storing elements in descending order.
        case maxHeap
    }
    
    /// Returns a new and empty `HeapBuffer` instance initialized to have enough contiguous storage for storing at
    /// least the specified count of elements, and using as sorting criteria a default comparator on `Element`
    /// as specified with the kind of Heap order to use.
    ///
    /// - Parameter _:  the minimum count of elements the buffer has to be able to store contiguously.
    ///                 **Must not be negative**.
    /// - Parameter heapType:   the kind of Heap ordering criteria to use.
    ///                         When `minHeap` is specified, it would be the same as specifying `<` as
    ///                         `sort` closure inside the default initializer `init(_:sort:)`.
    ///                         When `maxHeap` is specified, it would be the same as specifying `>` as
    ///                         `sort` closure inside the default initializer `init(_:sort:)`.
    /// - Returns:  a new empty `HeapBuffer` instance, initialized to be able to store contiguously
    ///             at least the specified count of elements, and using the specified Heap order kind as sorting criteria.
    public convenience init(_ capacity: Int, heapType: HeapType) {
        switch heapType {
        case .maxHeap:
            self.init(capacity, sort: >)
        case .minHeap:
            self.init(capacity, sort: <)
        }
    }
    
    /// Returns a new `HeapBuffer` instance initialized to use as sorting criteria a default comparator on `Element`
    /// as specified with the kind of Heap order to use, storing all the elements in the given sequence.
    ///
    /// - Parameter _: the elements to store in the new `HeapBuffer` instance
    /// - Parameter heapType:   the kind of Heap ordering criteria to use.
    ///                         When `minHeap` is specified, it would be the same as specifying `<` as
    ///                         `sort` closure inside the default initializer `init(_:sort:)`.
    ///                         When `maxHeap` is specified, it would be the same as specifying `>` as
    ///                         `sort` closure inside the default initializer `init(_:sort:)`.
    /// - Returns:  an `HeapBuffer` instance, initialized to use the specified Heap order kind as sorting criteria,
    ///             and storing all elements stored in the specified sequence.
    /// - Complexity: O(log *n*) where *n* is the count of elements stored in the given sequence.
    public convenience init<S: Sequence>(_ elements: S, heapType: HeapType) where S.Iterator.Element == Element {
        switch heapType {
        case .maxHeap:
            self.init(elements, sort: >)
        case .minHeap:
            self.init(elements, sort: <)
        }
    }
    
    /// Creates a new instance containing the specified number of a single,
    /// repeated value, using as sorting criteria a default comparator on `Element`
    /// as specified with the kind of heap order to use.
    ///
    /// The following example creates a max heap initialized with five strings
    /// containing the letter *Z*.
    ///
    ///     let fiveZs = HeapBuffer(repeating: "Z", count: 5, heapType: .maxHeap)
    ///     print(fiveZs)
    ///     // Prints "["Z", "Z", "Z", "Z", "Z"]"
    ///
    /// - Parameters:
    ///   - repeatedValue: The element to repeat.
    ///   - count:  The number of times to repeat the value passed in the
    ///             `repeating` parameter. `count` must be zero or greater.
    ///   - heapType:   the kind of Heap ordering criteria to use.
    ///                 When `minHeap` is specified, it would be the same as specifying `<` as
    ///                 `sort` closure inside the default initializer `init(_:sort:)`.
    ///                 When `maxHeap` is specified, it would be the same as specifying `>` as
    ///                 `sort` closure inside the default initializer `init(_:sort:)`.
    public convenience init(repeating repeatedValue: Element, count: Int, heapType: HeapType) {
        switch heapType {
        case .maxHeap:
            self.init(repeating: repeatedValue, count: count, sort: >)
        case .minHeap:
            self.init(repeating: repeatedValue, count: count, sort: <)
        }
    }
    
}

// MARK: - Private Interface
// MARK: - Generic helpers
extension HeapBuffer {
    private convenience init(from other: HeapBuffer, additionalCapacity: Int = 0) {
        precondition(additionalCapacity >= 0)
        self.init(other._capacity + additionalCapacity, sort: other._sort)
        _elementsCount = other._elementsCount
        if other._elementsCount > 0 {
            _elements.initialize(from: other._elements, count: other._elementsCount)
        }
    }
    
    @inline(__always)
    private func _swapElementsAt(_ lhs: Int, _ rhs: Int) {
        guard lhs != rhs else { return }
        
        swap(&_elements.advanced(by: lhs).pointee, &_elements.advanced(by: rhs).pointee)
    }
    
}

// MARK: - Indexes helpers
extension HeapBuffer {
    @inline(__always)
    private func _leftChildIndexOf(parentAt idx: Int) -> Int {
        (2 * idx) + 1
    }
    
    @inline(__always)
    private func _rightChildIndexOf(parentAt idx: Int) -> Int {
        (2 * idx) + 2
    }
    
    @inline(__always)
    private func _parentIndexOf(childAt idx: Int) -> Int {
        (idx - 1) / 2
    }
    
    @inline(__always)
    private func _isInSubscriptBounds(_ position: Int) -> Bool {
        (0..<_elementsCount) ~= position
    }
    
    @inline(__always)
    private func _checkSubscriptBounds(on position: Int) {
        precondition(!isEmpty && _isInSubscriptBounds(position), "subscript index out of bounds")
    }
    
}

// MARK: - Heap functionalities
extension HeapBuffer {
    @inline(__always)
    private func _siftDown(from index: Int) {
        var parent = index
        while true {
            let left = _leftChildIndexOf(parentAt: parent)
            let right = _rightChildIndexOf(parentAt: parent)
            var candidate = parent
            if left < _elementsCount && _sort(_elements[left], _elements[candidate]) {
                candidate = left
            }
            if right < _elementsCount && _sort(_elements[right], _elements[candidate]) {
                candidate = right
            }
            if candidate == parent {
                return
            }
            _swapElementsAt(parent, candidate)
            parent = candidate
        }
    }
    
    @inline(__always)
    private func _siftUp(from index: Int) {
        var child = index
        var parent = _parentIndexOf(childAt: child)
        while child > 0 && _sort(_elements[child], _elements[parent]) {
            _swapElementsAt(child, parent)
            child = parent
            parent = _parentIndexOf(childAt: child)
        }
    }
    
    @inline(__always)
    private func _buildHeap() {
        guard !isEmpty else { return }
        
        for i in stride(from: _elementsCount / 2 - 1, through: 0, by: -1) {
            _siftDown(from: i)
        }
    }
    
}

// MARK: - Capacity helpers
extension HeapBuffer {
    @inline(__always)
    private static var _minCapacity: Int { 4 }
    
    // Returns the next power of 2 for given capacity value, or minCapacity for
    // a given value less than or equal to 2.
    // Returned value is clamped to Int.max, and given value must not be negative.
    @inline(__always)
    private static func _convenientCapacityFor(capacity: Int) -> Int {
        precondition(capacity >= 0, "Negative capacity values are not allowed.")
        
        guard capacity > (_minCapacity >> 1) else { return _minCapacity }
        
        guard capacity < ((Int.max >> 1) + 1) else { return Int.max }
        
        return 1 << (Int.bitWidth - (capacity - 1).leadingZeroBitCount)
    }
    
    @inline(__always)
    private var _isFull: Bool { _capacity == _elementsCount }
    
    @inline(__always)
    private var _capacityLeft: Int { _capacity - _elementsCount }
    
    @inline(__always)
    private func _growToNextCapacityLevel() {
        precondition(_capacity < Int.max, "Can't grow capacity more than Int.max value: \(Int.max)")
        let newCapacity = _capacity << 1
        _resizeElements(to: newCapacity)
    }
    
    @inline(__always)
    private func _reduceCapacityToCurrentCount() {
        guard _capacity > 4 else { return }
        
        if isEmpty {
            _resizeElements(to: Self._minCapacity)
        }
        
        let newCapacity = Self._convenientCapacityFor(capacity: _elementsCount)
        if newCapacity < _capacity {
            _resizeElements(to: newCapacity)
        }
    }
    
    @inline(__always)
    private func _resizeElements(to newCapacity: Int) {
        precondition(_elementsCount <= newCapacity, "Can't fit contained elements in proposed capacity")
        guard _capacity != newCapacity else { return }
        
        let newBuff = UnsafeMutablePointer<Element>.allocate(capacity: newCapacity)
        newBuff.moveInitialize(from: _elements, count: _elementsCount)
        
        _elements.deallocate()
        _elements = newBuff
        _capacity = newCapacity
    }
    
}



