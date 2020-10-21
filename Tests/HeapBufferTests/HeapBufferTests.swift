import XCTest
@testable import HeapBuffer

final class HeapBufferTests: XCTestCase {
    var sut: HeapBuffer<Int>!
    
    override func setUp() {
        super.setUp()
        
        sut = HeapBuffer<Int>(0, heapType: .maxHeap)
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - init tests
    func testInit() {
        // generic tests on initializing a max heap
        sut = HeapBuffer<Int>(0, sort: >)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertTrue(sut.isEmpty)
        XCTAssertEqual(sut._elementsCount, 0)
        XCTAssertGreaterThanOrEqual(sut._capacity, 0)
        XCTAssertTrue(sut._sort(10, 9))
        XCTAssertFalse(sut._sort(9, 10))
        assertHeapProperty()
        
        sut = HeapBuffer<Int>(0, heapType: .maxHeap)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertTrue(sut.isEmpty)
        XCTAssertEqual(sut._elementsCount, 0)
        XCTAssertGreaterThanOrEqual(sut._capacity, 0)
        XCTAssertTrue(sut._sort(10, 9))
        XCTAssertFalse(sut._sort(9, 10))
        assertHeapProperty()
        
        // generic tests on initializing a min heap
        sut = HeapBuffer<Int>(0, sort: <)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertTrue(sut.isEmpty)
        XCTAssertEqual(sut._elementsCount, 0)
        XCTAssertGreaterThanOrEqual(sut._capacity, 0)
        XCTAssertFalse(sut._sort(10, 9))
        XCTAssertTrue(sut._sort(9, 10))
        assertHeapProperty()
        
        sut = HeapBuffer<Int>(0, heapType: .minHeap)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertTrue(sut.isEmpty)
        XCTAssertEqual(sut._elementsCount, 0)
        XCTAssertGreaterThanOrEqual(sut._capacity, 0)
        XCTAssertFalse(sut._sort(10, 9))
        XCTAssertTrue(sut._sort(9, 10))
        assertHeapProperty()
        
        // tests on capacity
        for requestedCapacity in 0...1024 {
            sut = HeapBuffer<Int>(requestedCapacity, sort: >)
            XCTAssertGreaterThanOrEqual(sut._capacity, requestedCapacity)
            sut = HeapBuffer<Int>(requestedCapacity, heapType: .maxHeap)
            XCTAssertGreaterThanOrEqual(sut._capacity, requestedCapacity)
            
            sut = HeapBuffer<Int>(requestedCapacity, sort: <)
            XCTAssertGreaterThanOrEqual(sut._capacity, requestedCapacity)
            sut = HeapBuffer<Int>(requestedCapacity, heapType: .minHeap)
            XCTAssertGreaterThanOrEqual(sut._capacity, requestedCapacity)
        }
        
        // test that sort is effectively used:
        let exp = expectation(description: "sort called")
        let sort: (Int, Int) -> Bool = { lhs, rhs in
            defer {
                exp.fulfill()
            }
            
            return lhs > rhs
        }
        
        sut = HeapBuffer<Int>(0, sort: sort)
        XCTAssertTrue(sut._sort(10, 9))
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - init from sequence tests
    func testInitFromSequence_whenSequenceIsEmpty() {
        let emptyWithoutContiguousBuffer = MyTestSequence<Int>([], hasUnderestimatedCount: false, hasContiguousBuffer: false)
        
        sut = HeapBuffer(emptyWithoutContiguousBuffer, sort: >)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertGreaterThanOrEqual(sut._capacity, 0)
        XCTAssertEqual(sut._elementsCount, 0)
        XCTAssertTrue(sut.isEmpty)
        
        sut = HeapBuffer(emptyWithoutContiguousBuffer, heapType: .maxHeap)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertGreaterThanOrEqual(sut._capacity, 0)
        XCTAssertEqual(sut._elementsCount, 0)
        XCTAssertTrue(sut.isEmpty)
        
        sut = HeapBuffer(emptyWithoutContiguousBuffer, sort: <)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertGreaterThanOrEqual(sut._capacity, 0)
        XCTAssertEqual(sut._elementsCount, 0)
        XCTAssertTrue(sut.isEmpty)
        
        sut = HeapBuffer(emptyWithoutContiguousBuffer, heapType: .minHeap)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertGreaterThanOrEqual(sut._capacity, 0)
        XCTAssertEqual(sut._elementsCount, 0)
        XCTAssertTrue(sut.isEmpty)
        
        let emptyWithContiguousBuffer = MyTestSequence<Int>([])
        
        sut = HeapBuffer(emptyWithContiguousBuffer, sort: >)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertGreaterThanOrEqual(sut._capacity, 0)
        XCTAssertEqual(sut._elementsCount, 0)
        XCTAssertTrue(sut.isEmpty)
        
        sut = HeapBuffer(emptyWithContiguousBuffer, heapType: .maxHeap)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertGreaterThanOrEqual(sut._capacity, 0)
        XCTAssertEqual(sut._elementsCount, 0)
        XCTAssertTrue(sut.isEmpty)
        
        sut = HeapBuffer(emptyWithContiguousBuffer, sort: <)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertGreaterThanOrEqual(sut._capacity, 0)
        XCTAssertEqual(sut._elementsCount, 0)
        XCTAssertTrue(sut.isEmpty)
        
        sut = HeapBuffer(emptyWithContiguousBuffer, heapType: .minHeap)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertGreaterThanOrEqual(sut._capacity, 0)
        XCTAssertEqual(sut._elementsCount, 0)
        XCTAssertTrue(sut.isEmpty)
        
        // test that sort is effectively used:
        let exp = expectation(description: "sort called")
        let sort: (Int, Int) -> Bool = { lhs, rhs in
            defer {
                exp.fulfill()
            }
            
            return lhs > rhs
        }
        
        sut = HeapBuffer([], sort: sort)
        XCTAssertTrue(sut._sort(10, 9))
        wait(for: [exp], timeout: 1)
    }
    
    func testInitFromSequence_whenSequenceIsNotEmpty() {
        let notEmptyElements = [1, 2, 3, 4, 5, 6, 7].shuffled()
        
        let seqWithContiguousBufferAndExactCount = MyTestSequence(notEmptyElements)
        
        sut = HeapBuffer<Int>(seqWithContiguousBufferAndExactCount, sort: >)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut._elementsCount, notEmptyElements.count)
        var result = UnsafeBufferPointer<Int>(start: sut._elements, count: sut._elementsCount)
        XCTAssertTrue(result.sorted().elementsEqual(notEmptyElements.sorted()))
        assertHeapProperty()
        
        sut = HeapBuffer<Int>(seqWithContiguousBufferAndExactCount, heapType: .maxHeap)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut._elementsCount, notEmptyElements.count)
        result = UnsafeBufferPointer<Int>(start: sut._elements, count: sut._elementsCount)
        XCTAssertTrue(result.sorted().elementsEqual(notEmptyElements.sorted()))
        assertHeapProperty()
        
        sut = HeapBuffer<Int>(seqWithContiguousBufferAndExactCount, sort: <)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut._elementsCount, notEmptyElements.count)
        result = UnsafeBufferPointer<Int>(start: sut._elements, count: sut._elementsCount)
        XCTAssertTrue(result.sorted().elementsEqual(notEmptyElements.sorted()))
        assertHeapProperty()
        
        sut = HeapBuffer<Int>(seqWithContiguousBufferAndExactCount, heapType: .minHeap)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut._elementsCount, notEmptyElements.count)
        result = UnsafeBufferPointer<Int>(start: sut._elements, count: sut._elementsCount)
        XCTAssertTrue(result.sorted().elementsEqual(notEmptyElements.sorted()))
        assertHeapProperty()
        
        let seqWithContiguousBufferNoExactCount = MyTestSequence(elements: notEmptyElements, underestimatedCount: 3, hasContiguousBuffer: true)
        
        sut = HeapBuffer<Int>(seqWithContiguousBufferNoExactCount, sort: >)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut._elementsCount, notEmptyElements.count)
        result = UnsafeBufferPointer<Int>(start: sut._elements, count: sut._elementsCount)
        XCTAssertTrue(result.sorted().elementsEqual(notEmptyElements.sorted()))
        assertHeapProperty()
        
        sut = HeapBuffer<Int>(seqWithContiguousBufferNoExactCount, heapType: .maxHeap)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut._elementsCount, notEmptyElements.count)
        result = UnsafeBufferPointer<Int>(start: sut._elements, count: sut._elementsCount)
        XCTAssertTrue(result.sorted().elementsEqual(notEmptyElements.sorted()))
        assertHeapProperty()
        
        sut = HeapBuffer<Int>(seqWithContiguousBufferNoExactCount, sort: <)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut._elementsCount, notEmptyElements.count)
        result = UnsafeBufferPointer<Int>(start: sut._elements, count: sut._elementsCount)
        XCTAssertTrue(result.sorted().elementsEqual(notEmptyElements.sorted()))
        assertHeapProperty()
        
        sut = HeapBuffer<Int>(seqWithContiguousBufferNoExactCount, heapType: .minHeap)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut._elementsCount, notEmptyElements.count)
        result = UnsafeBufferPointer<Int>(start: sut._elements, count: sut._elementsCount)
        XCTAssertTrue(result.sorted().elementsEqual(notEmptyElements.sorted()))
        assertHeapProperty()
        
        let seqWithoutContiguousBufferHasExactCount = MyTestSequence(notEmptyElements, hasContiguousBuffer: false)
        
        sut = HeapBuffer<Int>(seqWithoutContiguousBufferHasExactCount, sort: >)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut._elementsCount, notEmptyElements.count)
        result = UnsafeBufferPointer<Int>(start: sut._elements, count: sut._elementsCount)
        XCTAssertTrue(result.sorted().elementsEqual(notEmptyElements.sorted()))
        assertHeapProperty()
        
        sut = HeapBuffer<Int>(seqWithoutContiguousBufferHasExactCount, heapType: .maxHeap)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut._elementsCount, notEmptyElements.count)
        result = UnsafeBufferPointer<Int>(start: sut._elements, count: sut._elementsCount)
        XCTAssertTrue(result.sorted().elementsEqual(notEmptyElements.sorted()))
        assertHeapProperty()
        
        sut = HeapBuffer<Int>(seqWithoutContiguousBufferHasExactCount, sort: <)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut._elementsCount, notEmptyElements.count)
        result = UnsafeBufferPointer<Int>(start: sut._elements, count: sut._elementsCount)
        XCTAssertTrue(result.sorted().elementsEqual(notEmptyElements.sorted()))
        assertHeapProperty()
        
        sut = HeapBuffer<Int>(seqWithoutContiguousBufferHasExactCount, heapType: .minHeap)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut._elementsCount, notEmptyElements.count)
        result = UnsafeBufferPointer<Int>(start: sut._elements, count: sut._elementsCount)
        XCTAssertTrue(result.sorted().elementsEqual(notEmptyElements.sorted()))
        assertHeapProperty()
        
        let seqWithoutContiguousBufferNoExactCount = MyTestSequence(notEmptyElements, hasUnderestimatedCount: false, hasContiguousBuffer: false)
        
        sut = HeapBuffer<Int>(seqWithoutContiguousBufferNoExactCount, sort: >)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut._elementsCount, notEmptyElements.count)
        result = UnsafeBufferPointer<Int>(start: sut._elements, count: sut._elementsCount)
        XCTAssertTrue(result.sorted().elementsEqual(notEmptyElements.sorted()))
        assertHeapProperty()
        
        sut = HeapBuffer<Int>(seqWithoutContiguousBufferNoExactCount, heapType: .maxHeap)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut._elementsCount, notEmptyElements.count)
        result = UnsafeBufferPointer<Int>(start: sut._elements, count: sut._elementsCount)
        XCTAssertTrue(result.sorted().elementsEqual(notEmptyElements.sorted()))
        assertHeapProperty()
        
        sut = HeapBuffer<Int>(seqWithoutContiguousBufferNoExactCount, sort: <)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut._elementsCount, notEmptyElements.count)
        result = UnsafeBufferPointer<Int>(start: sut._elements, count: sut._elementsCount)
        XCTAssertTrue(result.sorted().elementsEqual(notEmptyElements.sorted()))
        assertHeapProperty()
        
        sut = HeapBuffer<Int>(seqWithoutContiguousBufferNoExactCount, heapType: .minHeap)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut._elementsCount, notEmptyElements.count)
        result = UnsafeBufferPointer<Int>(start: sut._elements, count: sut._elementsCount)
        XCTAssertTrue(result.sorted().elementsEqual(notEmptyElements.sorted()))
        assertHeapProperty()
        
        // test that sort is effectively used:
        var sortCalls = 0
        let sort: (Int, Int) -> Bool = { lhs, rhs in
            sortCalls += 1
            
            return lhs > rhs
        }
        
        sut = HeapBuffer([1, 2, 3, 4, 5, 6, 7], sort: sort)
        XCTAssertGreaterThan(sortCalls, 0, "sort was not called")
    }
    
    func testInitRepeatingCount() {
        sut = HeapBuffer(repeating: 10, count: 10, sort: >)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut._elements)
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut._elementsCount, 10)
        XCTAssertGreaterThanOrEqual(sut._capacity, sut._elementsCount)
        XCTAssertEqual(Array(UnsafeBufferPointer(start: sut._elements, count: sut._elementsCount)), Array(repeating: 10, count: 10))
        
        // test that sort is effectively used:
        let exp = expectation(description: "sort called")
        let sort: (Int, Int) -> Bool = { lhs, rhs in
            defer {
                exp.fulfill()
            }
            
            return lhs > rhs
        }
        
        sut = HeapBuffer(repeating: 10, count: 10, sort: sort)
        XCTAssertTrue(sut._sort(10, 9))
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Deinit tests
    func testDeinit() {
        sut = nil
        XCTAssertNil(sut?._elements)
    }
    
    // MARK: - copy(reservingCapacity:) tests
    func testCopy() {
        // To check that both copies uses same sort closure, we can let it capture
        // an Int global var which gets incremented at each call:
        var sortCalls = 0
        let sort: (Int, Int) -> Bool = { lhs, rhs in
            sortCalls += 1
            return lhs > rhs
        }
        
        sut = HeapBuffer([1, 2, 3, 4, 5, 6, 7], sort: sort)
        let copy = sut.copy()
        // let's do the canonical checks for the copy:
        XCTAssertNotEqual(sut._elements, copy._elements)
        XCTAssertEqual(sut._elementsCount, copy._elementsCount)
        XCTAssertTrue(UnsafeBufferPointer(start: sut._elements, count: sut._elementsCount).elementsEqual(UnsafeBufferPointer(start: copy._elements, count: copy._elementsCount)))
        
        // We'll do the same operation on both copies, knowing that it will call sort
        // one time per each instance (2 in total):
        var expectedSortCalls = sortCalls + 1
        sut.insert(0)
        XCTAssertEqual(sortCalls, expectedSortCalls, "sort closures are different")
        expectedSortCalls += 1
        copy.insert(0)
        XCTAssertEqual(sortCalls, expectedSortCalls, "sort closures are different")
        // We also check that the same operation produced the same effect
        // on both instances:
        XCTAssertTrue(UnsafeBufferPointer(start: sut._elements, count: sut._elementsCount).elementsEqual(UnsafeBufferPointer(start: copy._elements, count: copy._elementsCount)))
    }
    
    func testCopy_whenReservingCapacityIsGreaterThanZero() {
        // when reservingCapacity is less than or equal the capacity left, doesn't
        // increase capacity:
        var reserveCapacity = sut._capacity - sut._elementsCount
        XCTAssertGreaterThanOrEqual(reserveCapacity, 0)
        var copy = sut.copy(reservingCapacity: reserveCapacity)
        XCTAssertEqual(copy._capacity, sut._capacity)
        
        let notEmptyElements = [1, 2, 3, 4, 5].shuffled()
        sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
        reserveCapacity = sut._capacity - sut._elementsCount
        XCTAssertGreaterThanOrEqual(reserveCapacity, 0)
        copy = sut.copy(reservingCapacity: reserveCapacity)
        XCTAssertEqual(copy._capacity, sut._capacity)
        // let's also test with a different sort:
        sut = HeapBuffer(notEmptyElements, heapType: .minHeap)
        copy = sut.copy(reservingCapacity: reserveCapacity)
        XCTAssertEqual(copy._capacity, sut._capacity)
        
        // when reservingCapacity is greater than the capacity left, copy has
        // increased capacity so its capacity left can hold that count:
        sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
        reserveCapacity = sut._capacity - sut._elementsCount + 1
        XCTAssertGreaterThanOrEqual(reserveCapacity, 0)
        copy = sut.copy(reservingCapacity: reserveCapacity)
        XCTAssertGreaterThan(copy._capacity, sut._capacity)
        XCTAssertGreaterThanOrEqual(copy._capacity - copy._elementsCount, reserveCapacity)
        // let's also test with a different sort:
        sut = HeapBuffer(notEmptyElements, heapType: .minHeap)
        copy = sut.copy(reservingCapacity: reserveCapacity)
        XCTAssertGreaterThan(copy._capacity, sut._capacity)
        XCTAssertGreaterThanOrEqual(copy._capacity - copy._elementsCount, reserveCapacity)
    }
    
    // MARK: - count, isEmpty, startIndex and endIndex variables tests
    func testCount() {
        XCTAssertEqual(sut._elementsCount, sut.count)
        sut.insert(10)
        XCTAssertEqual(sut._elementsCount, sut.count)
        sut.extract()
        XCTAssertEqual(sut._elementsCount, sut.count)
    }
    
    func testIsEmpty() {
        XCTAssertEqual(sut._elementsCount, 0)
        XCTAssertTrue(sut.isEmpty)
        sut.insert(100)
        XCTAssertGreaterThan(sut._elementsCount, 0)
        XCTAssertFalse(sut.isEmpty)
        sut.extract()
        XCTAssertEqual(sut._elementsCount, 0)
        XCTAssertTrue(sut.isEmpty)
    }
    
    func testStartIndex() {
        XCTAssertTrue(sut.isEmpty)
        XCTAssertEqual(sut.startIndex, 0)
        
        let elements = [1, 2, 3, 4, 5].shuffled()
        sut = HeapBuffer(elements, heapType: .maxHeap)
        XCTAssertEqual(sut.startIndex, 0)
        sut = HeapBuffer(elements, heapType: .minHeap)
        XCTAssertEqual(sut.startIndex, 0)
    }
    
    func testEndIndex() {
        XCTAssertTrue(sut.isEmpty)
        XCTAssertEqual(sut.endIndex, sut.startIndex)
        XCTAssertEqual(sut.endIndex, sut._elementsCount)
        
        let elements = [1, 2, 3, 4, 5].shuffled()
        sut = HeapBuffer(elements, heapType: .maxHeap)
        XCTAssertFalse(sut.isEmpty)
        XCTAssertNotEqual(sut.endIndex, sut.startIndex)
        XCTAssertEqual(sut.endIndex, sut._elementsCount)
        sut = HeapBuffer(elements, heapType: .minHeap)
        XCTAssertFalse(sut.isEmpty)
        XCTAssertNotEqual(sut.endIndex, sut.startIndex)
        XCTAssertEqual(sut.endIndex, sut._elementsCount)
    }
    
    // MARK: - reserveCapacity() tests
    func testReserveCapacity() {
        // when residual capacity can hold reserved capacity:
        let prevCapacity = sut._capacity
        let prevElements = sut._elements
        sut.reserveCapacity(sut._capacity - sut._elementsCount)
        XCTAssertEqual(sut._capacity, prevCapacity)
        XCTAssertEqual(sut._elements, prevElements)
        
        while sut._elementsCount < sut._capacity - 2 {
            sut.insert(10)
        }
        sut.reserveCapacity(2)
        XCTAssertEqual(sut._capacity, prevCapacity)
        XCTAssertEqual(sut._elements, prevElements)
        let prevStoredElements = Array(UnsafeBufferPointer(start: sut._elements, count: sut._elementsCount))
        XCTAssertGreaterThanOrEqual(sut._capacity - sut._elementsCount, 2)
        
        // when residual capacity can't hold reserved capacity:
        sut.reserveCapacity(3)
        XCTAssertGreaterThan(sut._capacity, prevCapacity)
        XCTAssertNotEqual(sut._elements, prevElements)
        XCTAssertTrue(UnsafeBufferPointer(start: sut._elements, count: sut._elementsCount).elementsEqual(prevStoredElements))
        XCTAssertGreaterThanOrEqual(sut._capacity - sut._elementsCount, 3)
    }
    
    // MARK: - forEach(_:) test
    func testForEach() {
        let notEmptyElements = [1, 2, 3, 4, 5, 6, 7].shuffled()
        sut = HeapBuffer(notEmptyElements, sort: >)
        let expectedResult = Array(UnsafeBufferPointer(start: sut._elements, count: sut._elementsCount))
        var result = [Int]()
        sut.forEach { result.append($0) }
        XCTAssertEqual(result, expectedResult)
    }
    
    // MARK: - peek() tests
    func testPeek() {
        XCTAssertTrue(sut.isEmpty)
        XCTAssertNil(sut.peek())
        sut.insert(10)
        XCTAssertFalse(sut.isEmpty)
        XCTAssertNotNil(sut.peek())
        XCTAssertEqual(sut._elements[0], sut.peek())
        var prevRoot = sut.peek()
        sut.insert(200)
        XCTAssertNotEqual(sut._elements[0], prevRoot)
        XCTAssertEqual(sut._elements[0], sut.peek())
        prevRoot = sut.peek()
        sut.insert(50)
        XCTAssertEqual(sut._elements[0], prevRoot)
        XCTAssertEqual(sut._elements[0], sut.peek())
    }
    
    // MARK: - push(_:) and insert(_:) tests
    // we are gonna use insert(_:) method in tests since it would just call push(_:)
    // internally, hence both methods are tested.
    func testPush_increasesCountByOne() {
        var prevCount = sut.count
        sut.insert(10)
        XCTAssertEqual(sut.count, prevCount + 1)
        for i in 1..<10 {
            prevCount = sut.count
            sut.insert(i)
            XCTAssertEqual(sut.count, prevCount + 1)
        }
    }
    
    func testPush_insertsElementInHeapMainteiningHeapProperty() {
        for i in 1...10 {
            XCTAssertFalse(UnsafeBufferPointer(start: sut._elements, count: sut._elementsCount).contains(i))
            sut.insert(i)
            XCTAssertTrue(UnsafeBufferPointer(start: sut._elements, count: sut._elementsCount).contains(i))
            assertHeapProperty()
        }
        
        // let's also check it with a different sort:
        sut = HeapBuffer<Int>(0, heapType: .minHeap)
        for i in 1...10 {
            XCTAssertFalse(UnsafeBufferPointer(start: sut._elements, count: sut._elementsCount).contains(i))
            sut.insert(i)
            XCTAssertTrue(UnsafeBufferPointer(start: sut._elements, count: sut._elementsCount).contains(i))
            assertHeapProperty()
        }
    }
    
    // MARK: - insert(_:at:) tests
    func testInsertAt_incrementsCountByOne() {
        for i in 1...10 {
            let prevCount = sut._elementsCount
            let idx = Int.random(in: 0...sut._elementsCount)
            sut.insert(i, at: idx)
            XCTAssertEqual(sut.count, prevCount + 1)
        }
    }
    
    func testInsertAt_InsertElementInHeapMainteiningHeapProperty() {
        for i in 1...10 {
            let idx = Int.random(in: 0...sut._elementsCount)
            XCTAssertFalse(UnsafeBufferPointer(start: sut._elements, count: sut._elementsCount).contains(i))
            sut.insert(i, at: idx)
            XCTAssertTrue(UnsafeBufferPointer(start: sut._elements, count: sut._elementsCount).contains(i))
            assertHeapProperty()
        }
        // let's also check it with a different sort:
        sut = HeapBuffer<Int>(0, heapType: .minHeap)
        for i in 1...10 {
            let idx = Int.random(in: 0...sut._elementsCount)
            XCTAssertFalse(UnsafeBufferPointer(start: sut._elements, count: sut._elementsCount).contains(i))
            sut.insert(i, at: idx)
            XCTAssertTrue(UnsafeBufferPointer(start: sut._elements, count: sut._elementsCount).contains(i))
            assertHeapProperty()
        }
    }
    
    // MARK: - insert(elements:at:) tests
    func testInsertCollectionAt_incrementsCountByCollectionsCount() {
        let newElements = [10, 20, 30, 40, 50].shuffled()
        let notEmptyElements = [1, 2, 3, 4, 5].shuffled()
        
        var prevCount = sut.count
        sut.insert(elements: [], at: sut.startIndex)
        XCTAssertEqual(sut.count, prevCount)
        
        for i in 0..<notEmptyElements.count {
            sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
            prevCount = sut.count
            sut.insert(elements: newElements, at: i)
            XCTAssertEqual(sut.count, prevCount + newElements.count)
        }
        
        // let's also test with another sort:
        for i in 0...notEmptyElements.count {
            sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
            prevCount = sut.count
            sut.insert(elements: newElements, at: i)
            XCTAssertEqual(sut.count, prevCount + newElements.count)
        }
    }
    
    func testInsertCollectionAt_insertsCollectionsElementsMaintainingHeapProperty() {
        let newElements = [10, 20, 30, 40, 50].shuffled()
        let notEmptyElements = [1, 2, 3, 4, 5].shuffled()
        
        sut.withUnsafeBufferPointer { buff in
            for i in 0..<newElements.count {
                XCTAssertFalse(buff.contains(newElements[i]))
            }
        }
        sut.insert(elements: newElements, at: sut.startIndex)
        sut.withUnsafeBufferPointer { buff in
            for i in 0..<newElements.count {
                XCTAssertTrue(buff.contains(newElements[i]))
            }
        }
        assertHeapProperty()
        
        for i in 0...notEmptyElements.count {
            sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
            sut.insert(elements: newElements, at: i)
            sut.withUnsafeBufferPointer { buff in
                for i in 0..<newElements.count {
                    XCTAssertTrue(buff.contains(newElements[i]))
                }
                for i in 0..<notEmptyElements.count {
                    XCTAssertTrue(buff.contains(notEmptyElements[i]))
                }
            }
            assertHeapProperty()
        }
        
        // let's also test with another sort:
        for i in 0...notEmptyElements.count {
            sut = HeapBuffer(notEmptyElements, heapType: .minHeap)
            sut.insert(elements: newElements, at: i)
            sut.withUnsafeBufferPointer { buff in
                for i in 0..<newElements.count {
                    XCTAssertTrue(buff.contains(newElements[i]))
                }
                for i in 0..<notEmptyElements.count {
                    XCTAssertTrue(buff.contains(notEmptyElements[i]))
                }
            }
            assertHeapProperty()
        }
    }
    
    // MARK: - extract() and pop() tests
    // extract() uses pop() when isEmpty == false, hence pop() will be tested too.
    func testExtract_whenEmpty_returnsNil() {
        XCTAssertTrue(sut.isEmpty)
        XCTAssertNil(sut.extract())
    }
    
    func testExtract_whenNotEmpty_decreasesCountByOneAndRemovesAndReturnsRootAndMaintainsHeapProperty() {
        let notEmptyElements = [1, 2, 3, 4, 5, 6, 7].shuffled()
        
        sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
        while let root = sut.peek() {
            let prevCount = sut.count
            let extracted = sut.extract()
            XCTAssertEqual(sut.count, prevCount - 1)
            XCTAssertEqual(root, extracted)
            XCTAssertNotEqual(sut.peek(), extracted)
            assertHeapProperty()
        }
        
        // let's also test with a different sort
        sut = HeapBuffer(notEmptyElements, heapType: .minHeap)
        while let root = sut.peek() {
            let prevCount = sut.count
            let extracted = sut.extract()
            XCTAssertEqual(sut.count, prevCount - 1)
            XCTAssertEqual(root, extracted)
            XCTAssertNotEqual(sut.peek(), extracted)
            assertHeapProperty()
        }
    }
    
    func testPop_reducesCapacity() {
        let notEmptyElements = [1, 2, 3, 4, 5].shuffled()
        sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
        let prevCapacity = sut._capacity
        sut.pop()
        XCTAssertLessThan(sut._capacity, prevCapacity)
    }
    
    // MARK: - remove(at:) tests
    func testRemoveAt_decreasesCountByOneAndRemovesAndReturnsElementAtIndexAndMaintainsHeapProperty() {
        let notEmptyElements = [1, 2, 3, 4, 5].shuffled()
        for i in 0..<notEmptyElements.count {
            sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
            var prevCount = sut.count
            var expectedResult = sut[i]
            var result = sut.remove(at: i)
            XCTAssertEqual(sut.count, prevCount - 1)
            XCTAssertEqual(result, expectedResult)
            XCTAssertFalse(UnsafeBufferPointer(start: sut._elements, count: sut.count).contains(result), "element was not removed")
            assertHeapProperty()
            
            // let's also test with a different sort:
            sut = HeapBuffer(notEmptyElements, heapType: .minHeap)
            prevCount = sut.count
            expectedResult = sut[i]
            result = sut.remove(at: i)
            XCTAssertEqual(sut.count, prevCount - 1)
            XCTAssertEqual(result, expectedResult)
            XCTAssertFalse(UnsafeBufferPointer(start: sut._elements, count: sut.count).contains(result), "element was not removed")
            assertHeapProperty()
        }
    }
    
    func testRemoveAt_reducesCapacity() {
        let notEmptyElements = [1, 2, 3, 4, 5].shuffled()
        for i in 0..<notEmptyElements.count {
            sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
            var prevCapacity = sut._capacity
            sut.remove(at: i)
            XCTAssertLessThan(sut._capacity, prevCapacity)
            
            sut = HeapBuffer(notEmptyElements, heapType: .minHeap)
            prevCapacity = sut._capacity
            sut.remove(at: i)
            XCTAssertLessThan(sut._capacity, prevCapacity)
        }
    }
    
    // MARK: - remove(at:count:) tests
    func testRemoveAtCount_whenIdxIsEqualToStartIndexAndCountIsEqualToElementsCount_thenRemovesAndReturnsAllElements() {
        let notEmptyElements = [1, 2, 3, 4, 5].shuffled()
        sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
        var expectedResult = sut.withUnsafeBufferPointer { Array($0) }
        var result = sut.remove(at: 0, count: sut._elementsCount)
        XCTAssertTrue(sut.isEmpty)
        XCTAssertEqual(result, expectedResult)
        
        // let's also try with a different sort:
        sut = HeapBuffer(notEmptyElements, heapType: .minHeap)
        expectedResult = sut.withUnsafeBufferPointer { Array($0) }
        result = sut.remove(at: 0, count: sut._elementsCount)
        XCTAssertTrue(sut.isEmpty)
        XCTAssertEqual(result, expectedResult)
    }
    
    func testRemoveAtCount_removesAndReturnsKElementsFromIdxMaintainingHeapProperty() {
        let notEmptyElements = [1, 2, 3, 4, 5].shuffled()
        let initialCount = notEmptyElements.count
        for i in 0..<initialCount {
            for k in 0...(initialCount - i) {
                let rangeOfRemoval = i..<(i+k)
                sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
                let original = sut.withUnsafeBufferPointer { Array($0) }
                let expectedResult = Array(original[rangeOfRemoval])
                let result = sut.remove(at: i, count: k)
                XCTAssertEqual(sut.count, initialCount - k)
                XCTAssertEqual(result, expectedResult)
                sut.withUnsafeBufferPointer { buff in
                    for removedElement in expectedResult {
                        XCTAssertFalse(buff.contains(removedElement))
                    }
                }
                assertHeapProperty()
            }
        }
        // let's also test with a different sort:
        for i in 0..<initialCount {
            for k in 0...(initialCount - i) {
                let rangeOfRemoval = i..<(i+k)
                sut = HeapBuffer(notEmptyElements, heapType: .minHeap)
                let original = sut.withUnsafeBufferPointer { Array($0) }
                let expectedResult = Array(original[rangeOfRemoval])
                let result = sut.remove(at: i, count: k)
                XCTAssertEqual(sut.count, initialCount - k)
                XCTAssertEqual(result, expectedResult)
                sut.withUnsafeBufferPointer { buff in
                    for removedElement in expectedResult {
                        XCTAssertFalse(buff.contains(removedElement))
                    }
                }
                assertHeapProperty()
            }
        }
    }
    
    func testRemoveAtCount_keepingCapacity() {
        let notEmptyElements = [1, 2, 3, 4, 5].shuffled()
        let initialCount = notEmptyElements.count
        
        // when keepingCapacity is true, keeps capacity:
        sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
        var prevCapacity = sut._capacity
        sut.remove(at: 0, count: sut._elementsCount, keepingCapacity: true)
        XCTAssertEqual(sut._capacity, prevCapacity)
        // let's also test with a different sort:
        sut = HeapBuffer(notEmptyElements, heapType: .minHeap)
        prevCapacity = sut._capacity
        sut.remove(at: 0, count: sut._elementsCount, keepingCapacity: true)
        XCTAssertEqual(sut._capacity, prevCapacity)
        
        // when keepingCapacity is false, reduces capacity:
        for i in 0..<initialCount {
            for k in 1...(initialCount - i) {
                sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
                prevCapacity = sut._capacity
                sut.remove(at: i, count: k)
                XCTAssertLessThan(sut._capacity, prevCapacity)
            }
        }
        // let's also test with a different sort:
        for i in 0..<initialCount {
            for k in 1...(initialCount - i) {
                sut = HeapBuffer(notEmptyElements, heapType: .minHeap)
                prevCapacity = sut._capacity
                sut.remove(at: i, count: k)
                XCTAssertLessThan(sut._capacity, prevCapacity)
            }
        }
    }
    
    // MARK: - replace(subrange:with:) tests
    func testReplaceSubrangeWith_whenSubrangeCountIsZero_insertsNewElementsMaintainingHeapProperty() {
        // let's test when sut and newElements are empty:
        XCTAssertTrue(sut.isEmpty)
        let prevElements = sut.withUnsafeBufferPointer { Array($0) }
        sut.replace(subrange: 0..<0, with: [])
        XCTAssertEqual(sut.withUnsafeBufferPointer { Array($0) }, prevElements)
        
        // when sut is empty and newElements is not empty:
        let additionalElements = [10, 20, 30, 40, 50].shuffled()
        sut.replace(subrange: 0..<0, with: additionalElements)
        XCTAssertEqual(sut.count, additionalElements.count)
        sut.withUnsafeBufferPointer { buff in
            for newElement in additionalElements {
                XCTAssertTrue(buff.contains(newElement))
            }
        }
        assertHeapProperty()
        
        let notEmptyElements = [1, 2, 3, 4, 5].shuffled()
        let allElements = notEmptyElements + additionalElements
        for i in 0...notEmptyElements.count {
            // when sut and newElements are not empty:
            sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
            let subrange = i..<i
            let prevCount = sut.count
            sut.replace(subrange: subrange, with: additionalElements)
            XCTAssertGreaterThan(sut.count, prevCount)
            XCTAssertEqual(sut.count, allElements.count)
            sut.withUnsafeBufferPointer { buff in
                for element in allElements {
                    XCTAssertTrue(buff.contains(element))
                }
            }
            assertHeapProperty()
            
            // when sut is not empty and newElements is empty:
            sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
            let prevElements = sut.withUnsafeBufferPointer { Array($0) }
            sut.replace(subrange: subrange, with: [])
            XCTAssertEqual(sut.withUnsafeBufferPointer { Array($0) }, prevElements)
            assertHeapProperty()
        }
        
        // let's also test with a different sort:
        for i in 0...notEmptyElements.count {
            // when sut and newElements are not empty:
            sut = HeapBuffer(notEmptyElements, heapType: .minHeap)
            let subrange = i..<i
            let prevCount = sut.count
            sut.replace(subrange: subrange, with: additionalElements)
            XCTAssertGreaterThan(sut.count, prevCount)
            XCTAssertEqual(sut.count, allElements.count)
            sut.withUnsafeBufferPointer { buff in
                for element in allElements {
                    XCTAssertTrue(buff.contains(element))
                }
            }
            assertHeapProperty()
            
            // when sut is not empty and newElements is empty:
            sut = HeapBuffer(notEmptyElements, heapType: .minHeap)
            let prevElements = sut.withUnsafeBufferPointer { Array($0) }
            sut.replace(subrange: subrange, with: [])
            XCTAssertEqual(sut.withUnsafeBufferPointer { Array($0) }, prevElements)
            assertHeapProperty()
        }
    }
    
    func testReplaceSubrangeWith_whenSubrangeCountIsGreaterThanZeroAndNewElementsIsEmpty_removesElementsAtSubrangeIndexesMaintainigHeapProperty() {
        let notEmptyElements = [1, 2, 3, 4, 5].shuffled()
        for i in 0..<notEmptyElements.count {
            for k in stride(from: i + 1, through: notEmptyElements.count, by: 1) {
                let subrange = i..<k
                sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
                let removed = sut.withUnsafeBufferPointer { Array($0[subrange]) }
                sut.replace(subrange: subrange, with: [])
                XCTAssertEqual(sut.count, notEmptyElements.count - subrange.count)
                sut.withUnsafeBufferPointer { buff in
                    for removedElement in removed {
                        XCTAssertFalse(buff.contains(removedElement))
                    }
                }
                assertHeapProperty()
            }
        }
        // let's also test with a different sort:
        for i in 0..<notEmptyElements.count {
            for k in stride(from: i + 1, through: notEmptyElements.count, by: 1) {
                let subrange = i..<k
                sut = HeapBuffer(notEmptyElements, heapType: .minHeap)
                let removed = sut.withUnsafeBufferPointer { Array($0[subrange]) }
                sut.replace(subrange: subrange, with: [])
                XCTAssertEqual(sut.count, notEmptyElements.count - subrange.count)
                sut.withUnsafeBufferPointer { buff in
                    for removedElement in removed {
                        XCTAssertFalse(buff.contains(removedElement))
                    }
                }
                assertHeapProperty()
            }
        }
    }
    
    func testReplaceSubrangeWith_whenSubrangeCountAndNewElementsCountAreGreaterThanZero_thenElementsAtSubrangeAreRemovedAndNewElementsIsInsertedMaintainingHeapProperty() {
        let notEmptyElements = [1, 2, 3, 4, 5].shuffled()
        let additionalElements = [10, 20, 30, 40, 50].shuffled()
        for i in 0..<notEmptyElements.count {
            for k in stride(from: i + 1, through: notEmptyElements.count, by: 1) {
                let subrange = i..<k
                sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
                let prevElements = sut.withUnsafeBufferPointer { Array($0) }
                let removed = Array(prevElements[subrange])
                let allElements = prevElements.filter { !removed.contains($0) } + additionalElements
                sut.replace(subrange: subrange, with: additionalElements)
                XCTAssertEqual(sut.count, allElements.count)
                sut.withUnsafeBufferPointer { buff in
                    for element in allElements {
                        XCTAssertTrue(buff.contains(element), "element should be in sut: \(element)\nremoved: \(removed)\nActualElements: \(Array(buff))\nsubrange: \(subrange)")
                    }
                    for removedElement in removed {
                        XCTAssertFalse(buff.contains(removedElement), "element should have been removed from sut: \(removedElement)")
                    }
                }
                assertHeapProperty()
            }
        }
        // let's also test with a different sort:
        for i in 0..<notEmptyElements.count {
            for k in stride(from: i + 1, through: notEmptyElements.count, by: 1) {
                let subrange = i..<k
                sut = HeapBuffer(notEmptyElements, heapType: .minHeap)
                let prevElements = sut.withUnsafeBufferPointer { Array($0) }
                let removed = Array(prevElements[subrange])
                let allElements = prevElements.filter { !removed.contains($0) } + additionalElements
                sut.replace(subrange: subrange, with: additionalElements)
                XCTAssertEqual(sut.count, allElements.count)
                sut.withUnsafeBufferPointer { buff in
                    for element in allElements {
                        XCTAssertTrue(buff.contains(element), "element should be in sut: \(element)\nremoved: \(removed)\nActualElements: \(Array(buff))\nsubrange: \(subrange)")
                    }
                    for removedElement in removed {
                        XCTAssertFalse(buff.contains(removedElement), "element should have been removed from sut: \(removedElement)")
                    }
                }
                assertHeapProperty()
            }
        }
    }
    
    // MARK: - pushPop(_:) tests
    func testPushPop_whenIsEmptyOrElementIsHigherThanRootReturnsElement() {
        XCTAssertTrue(sut.isEmpty)
        var result = sut.pushPop(10)
        XCTAssertEqual(result, 10)
        
        let notEmptyElements = [1, 2, 3, 4, 5].shuffled()
        sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
        var higher = 6
        var prevRoot = sut.peek()!
        XCTAssertTrue(sut._sort(higher, prevRoot))
        sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
        result = sut.pushPop(higher)
        XCTAssertEqual(result, higher)
        XCTAssertEqual(sut.peek(), prevRoot)
        
        // let's also test with a different sort:
        sut = HeapBuffer(notEmptyElements, heapType: .minHeap)
        higher = 0
        prevRoot = sut.peek()!
        XCTAssertTrue(sut._sort(higher, prevRoot))
        result = sut.pushPop(higher)
        XCTAssertEqual(result, higher)
        XCTAssertEqual(sut.peek(), prevRoot)
    }
    
    func testPushPop_whenElementIsLowerThanRoot_removesAndReturnRootAndInsertElementMaintainingHeapProperty() {
        let notEmptyElements = [1, 2, 3, 4, 5].shuffled()
        sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
        var lower = 0
        var prevRoot = sut.peek()!
        XCTAssertTrue(sut._sort(prevRoot, lower))
        var result = sut.pushPop(lower)
        XCTAssertNotEqual(result, lower)
        XCTAssertEqual(result, prevRoot)
        XCTAssertNotEqual(prevRoot, sut.peek()!)
        assertHeapProperty()
        
        // let's also test with a different sort:
        sut = HeapBuffer(notEmptyElements, heapType: .minHeap)
        lower = 6
        prevRoot = sut.peek()!
        XCTAssertTrue(sut._sort(prevRoot, lower))
        result = sut.pushPop(lower)
        XCTAssertNotEqual(result, lower)
        XCTAssertEqual(result, prevRoot)
        XCTAssertNotEqual(prevRoot, sut.peek()!)
        assertHeapProperty()
    }
    
    // MARK: - replace(_:) tests
    func testReplace_replacesRootAndMaintainsHeapProperty() {
        let notEmptyElements = [1, 2, 3, 4, 5].shuffled()
        sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
        var higher = 6
        var prevRoot = sut.peek()!
        var result = sut.replace(higher)
        XCTAssertEqual(result, prevRoot)
        XCTAssertNotEqual(sut.peek(), prevRoot)
        XCTAssertTrue(UnsafeBufferPointer(start: sut._elements, count: sut._elementsCount).contains(higher))
        assertHeapProperty()
        
        var lower = 0
        prevRoot = sut.peek()!
        result = sut.replace(lower)
        XCTAssertEqual(result, prevRoot)
        XCTAssertNotEqual(sut.peek(), prevRoot)
        XCTAssertTrue(UnsafeBufferPointer(start: sut._elements, count: sut._elementsCount).contains(lower))
        assertHeapProperty()
        
        // let's also test with a different sort:
        sut = HeapBuffer(notEmptyElements, heapType: .minHeap)
        swap(&lower, &higher)
        prevRoot = sut.peek()!
        result = sut.replace(higher)
        XCTAssertEqual(result, prevRoot)
        XCTAssertNotEqual(sut.peek(), prevRoot)
        XCTAssertTrue(UnsafeBufferPointer(start: sut._elements, count: sut._elementsCount).contains(higher))
        assertHeapProperty()
        
        prevRoot = sut.peek()!
        result = sut.replace(lower)
        XCTAssertEqual(result, prevRoot)
        XCTAssertNotEqual(sut.peek(), prevRoot)
        XCTAssertTrue(UnsafeBufferPointer(start: sut._elements, count: sut._elementsCount).contains(lower))
        assertHeapProperty()
    }
    
    // MARK: - subscript tests
    func testSubscriptGetter() {
        let notEmptyElements = [1, 2, 3, 4, 5].shuffled()
        sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
        for i in 0..<sut.count {
            XCTAssertEqual(sut[i], sut._elements.advanced(by: i).pointee)
        }
        
        // let's also tests with a different sort:
        sut = HeapBuffer(notEmptyElements, heapType: .minHeap)
        for i in 0..<sut.count {
            XCTAssertEqual(sut[i], sut._elements.advanced(by: i).pointee)
        }
    }
    
    func testSubscriptSetter() {
        let notEmptyElements = [1, 2, 3, 4, 5].shuffled()
        sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
        for i in 0..<sut.count {
            let expectedValue = sut[i] + 10
            sut[i] += 10
            XCTAssertTrue(UnsafeBufferPointer(start: sut._elements, count: sut._elementsCount).contains(expectedValue))
            assertHeapProperty()
        }
        
        // let's also tests with a different sort:
        sut = HeapBuffer(notEmptyElements, heapType: .minHeap)
        for i in 0..<sut.count {
            let expectedValue = sut[i] + 10
            sut[i] += 10
            XCTAssertTrue(UnsafeBufferPointer(start: sut._elements, count: sut._elementsCount).contains(expectedValue))
            assertHeapProperty()
        }
    }
    
    // MARK: - withUnsafeBufferPointer(_:) and withUnsafeMutableBufferPointer(_:) tests
    func testWithUnsafeBufferPointer_whenBodyDoesntThrow_thenReturnsResult() {
        let notEmptyElements = [1, 2, 3, 4, 5].shuffled()
        sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
        var expectedResult = [Int]()
        for i in sut.startIndex..<sut.endIndex {
            expectedResult.append(sut[i])
        }
        var result: [Int] = sut.withUnsafeBufferPointer { buff in
            Array(buff)
        }
        XCTAssertEqual(result, expectedResult)
        
        // let's also tests with a different sort:
        sut = HeapBuffer(notEmptyElements, heapType: .minHeap)
        expectedResult.removeAll(keepingCapacity: true)
        for i in sut.startIndex..<sut.endIndex {
            expectedResult.append(sut[i])
        }
        result = sut.withUnsafeBufferPointer { buff in
            Array(buff)
        }
        XCTAssertEqual(result, expectedResult)
    }
    
    func testWithUnsafeBufferPointer_whenBodyThrows_thenRethrows() {
        let throwingClosure: (UnsafeBufferPointer<Int>) throws -> Void = { _ in
            throw NSError(domain: "com.vdl.heapBufferTest", code: 1, userInfo: nil)
        }
        
        let notEmptyElements = [1, 2, 3, 4, 5].shuffled()
        sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
        XCTAssertThrowsError(try sut.withUnsafeBufferPointer(throwingClosure))
        
        // let's also tests with a different sort:
        sut = HeapBuffer(notEmptyElements, heapType: .minHeap)
        XCTAssertThrowsError(try sut.withUnsafeBufferPointer(throwingClosure))
    }
    
    func testWithUnsafeMutablePointer_whenBodyDoesntThrow_thenReturnsResultAndMaintainsHeapProperty() {
        let notEmptyElements = [1, 2, 3, 4, 5].shuffled()
        sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
        var expectedResult = [Int]()
        for i in sut.startIndex..<sut.endIndex {
            expectedResult.append((sut[i] + 40) / 3)
        }
        var result: [Int] = sut.withUnsafeMutableBufferPointer{ buff in
            for i in buff.startIndex..<buff.endIndex {
                buff[i] += 40
                buff[i] /= 3
            }
            
            return Array(buff)
        }
        
        XCTAssertEqual(result, expectedResult)
        assertHeapProperty()
        var otherHeap = HeapBuffer(result, heapType: .maxHeap)
        XCTAssertTrue(sut.withUnsafeBufferPointer({ sutBuff in
            otherHeap.withUnsafeBufferPointer({ otherBuff in
                otherBuff.elementsEqual(sutBuff)
            })
        }))
        
        // let's also tests with a different sort:
        sut = HeapBuffer(notEmptyElements, heapType: .minHeap)
        expectedResult.removeAll(keepingCapacity: true)
        for i in sut.startIndex..<sut.endIndex {
            expectedResult.append((sut[i] + 40) / 3)
        }
        result = sut.withUnsafeMutableBufferPointer{ buff in
            for i in buff.startIndex..<buff.endIndex {
                buff[i] += 40
                buff[i] /= 3
            }
            
            return Array(buff)
        }
        
        XCTAssertEqual(result, expectedResult)
        assertHeapProperty()
        otherHeap = HeapBuffer(result, heapType: .minHeap)
        XCTAssertTrue(sut.withUnsafeBufferPointer({ sutBuff in
            otherHeap.withUnsafeBufferPointer({ otherBuff in
                otherBuff.elementsEqual(sutBuff)
            })
        }))
    }
    
    func testWithUnsafeMutableBufferPointer_whenBodyThrows_thenRethrows() {
        let throwingClosure: (inout UnsafeMutableBufferPointer<Int>) throws -> Void = { _ in
            throw NSError(domain: "com.vdl.heapBufferTest", code: 1, userInfo: nil)
        }
        
        let notEmptyElements = [1, 2, 3, 4, 5].shuffled()
        sut = HeapBuffer(notEmptyElements, heapType: .maxHeap)
        XCTAssertThrowsError(try sut.withUnsafeMutableBufferPointer(throwingClosure))
        
        // let's also tests with a different sort:
        sut = HeapBuffer(notEmptyElements, heapType: .minHeap)
        XCTAssertThrowsError(try sut.withUnsafeMutableBufferPointer(throwingClosure))
    }
    
    // MARK: - Traversing tests
    func testPostOrderTraverse_whenBodyDoesntThrow_visitsElementsPostOrder() {
        let elementsForMaxHeap = [5, 4, 3, 2, 1]
        sut = HeapBuffer(elementsForMaxHeap, heapType: .maxHeap)
        var expectedResult = [2, 1, 4, 3, 5]
        var result = [Int]()
        sut.postOrder { result.append($0) }
        XCTAssertEqual(result, expectedResult)
        
        // let's also tests with a different sort:
        let elementsForMinHeap = [1, 2, 3, 4, 5]
        sut = HeapBuffer(elementsForMinHeap, heapType: .minHeap)
        expectedResult = [4, 5, 2, 3, 1]
        result.removeAll(keepingCapacity: true)
        sut.postOrder { result.append($0) }
        XCTAssertEqual(result, expectedResult)
    }
    
    func testPostOrderTraverse_whenBodyThrows_rethrows() {
        let throwingClosure: (Int) throws -> Void = { _ in
            throw NSError(domain: "com.vdl.heapBufferTest", code: 1, userInfo: nil)
        }
        let elementsForMaxHeap = [5, 4, 3, 2, 1]
        sut = HeapBuffer(elementsForMaxHeap, heapType: .maxHeap)
        XCTAssertThrowsError(try sut.postOrder(body: throwingClosure))
        
        // let's also tests with a different sort:
        let elementsForMinHeap = [1, 2, 3, 4, 5]
        sut = HeapBuffer(elementsForMinHeap, heapType: .minHeap)
        XCTAssertThrowsError(try sut.postOrder(body: throwingClosure))
    }
    
    func testInOrder_whenBodyDoesntThrow_visitsElementsInOrder() {
        let elementsForMaxHeap = [5, 4, 3, 2, 1]
        sut = HeapBuffer(elementsForMaxHeap, heapType: .maxHeap)
        var expectedResult = [2, 4, 1, 5, 3]
        var result = [Int]()
        sut.inOrder { result.append($0) }
        XCTAssertEqual(result, expectedResult)
        
        // let's also tests with a different sort:
        let elementsForMinHeap = [1, 2, 3, 4, 5]
        sut = HeapBuffer(elementsForMinHeap, heapType: .minHeap)
        expectedResult = [4, 2, 5, 1, 3]
        result.removeAll(keepingCapacity: true)
        sut.inOrder { result.append($0) }
        XCTAssertEqual(result, expectedResult)
    }
    
    func testInOrder_whenBodyThrows_rethrows() {
        let throwingClosure: (Int) throws -> Void = { _ in
            throw NSError(domain: "com.vdl.heapBufferTest", code: 1, userInfo: nil)
        }
        let elementsForMaxHeap = [5, 4, 3, 2, 1]
        sut = HeapBuffer(elementsForMaxHeap, heapType: .maxHeap)
        XCTAssertThrowsError(try sut.inOrder(body: throwingClosure))
        
        // let's also tests with a different sort:
        let elementsForMinHeap = [1, 2, 3, 4, 5]
        sut = HeapBuffer(elementsForMinHeap, heapType: .minHeap)
        XCTAssertThrowsError(try sut.inOrder(body: throwingClosure))
    }
    
    func testPreOrder_whenBodyDoesntThrow_visitsElementsPreOrder() {
        let elementsForMaxHeap = [5, 4, 3, 2, 1]
        sut = HeapBuffer(elementsForMaxHeap, heapType: .maxHeap)
        var expectedResult = [5, 4, 2, 1, 3]
        var result = [Int]()
        sut.preOrder { result.append($0) }
        XCTAssertEqual(result, expectedResult)
        
        // let's also tests with a different sort:
        let elementsForMinHeap = [1, 2, 3, 4, 5]
        sut = HeapBuffer(elementsForMinHeap, heapType: .minHeap)
        expectedResult = [1, 2, 4, 5, 3]
        result.removeAll(keepingCapacity: true)
        sut.preOrder { result.append($0) }
        XCTAssertEqual(result, expectedResult)
    }
    
    func testPreOrder_whenBodyThrows_rethrows() {
        let throwingClosure: (Int) throws -> Void = { _ in
            throw NSError(domain: "com.vdl.heapBufferTest", code: 1, userInfo: nil)
        }
        let elementsForMaxHeap = [5, 4, 3, 2, 1]
        sut = HeapBuffer(elementsForMaxHeap, heapType: .maxHeap)
        XCTAssertThrowsError(try sut.preOrder(body: throwingClosure))
        
        // let's also tests with a different sort:
        let elementsForMinHeap = [1, 2, 3, 4, 5]
        sut = HeapBuffer(elementsForMinHeap, heapType: .minHeap)
        XCTAssertThrowsError(try sut.preOrder(body: throwingClosure))
    }
    
    func testLevelOrder_whenBodyDoesntThrow_visitsElementsLevelOrder() {
        let elementsForMaxHeap = [5, 4, 3, 2, 1]
        sut = HeapBuffer(elementsForMaxHeap, heapType: .maxHeap)
        var expectedResult = [5, 4, 3, 2, 1]
        var result = [Int]()
        sut.levelOrder { result.append($0) }
        XCTAssertEqual(result, expectedResult)
        
        // let's also tests with a different sort:
        let elementsForMinHeap = [1, 2, 3, 4, 5]
        sut = HeapBuffer(elementsForMinHeap, heapType: .minHeap)
        expectedResult = [1, 2, 3, 4, 5]
        result.removeAll(keepingCapacity: true)
        sut.levelOrder { result.append($0) }
        XCTAssertEqual(result, expectedResult)
    }
    
    func testLevelOrder_whenBodyThrows_rethrows() {
        let throwingClosure: (Int) throws -> Void = { _ in
            throw NSError(domain: "com.vdl.heapBufferTest", code: 1, userInfo: nil)
        }
        let elementsForMaxHeap = [5, 4, 3, 2, 1]
        sut = HeapBuffer(elementsForMaxHeap, heapType: .maxHeap)
        XCTAssertThrowsError(try sut.levelOrder(body: throwingClosure))
        
        // let's also tests with a different sort:
        let elementsForMinHeap = [1, 2, 3, 4, 5]
        sut = HeapBuffer(elementsForMinHeap, heapType: .minHeap)
        XCTAssertThrowsError(try sut.levelOrder(body: throwingClosure))
    }
    
    // MARK: - indexOf(_:startingAt:) tests
    func testIndexOf_whenElementIsNotPresent_returnsNil() {
        XCTAssertTrue(sut.isEmpty)
        XCTAssertNil(sut.indexOf(10))
        
        let maxHeapElements = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
        sut = HeapBuffer(maxHeapElements, heapType: .maxHeap)
        XCTAssertNil(sut.indexOf(11))
        XCTAssertNil(sut.indexOf(10, startingAt: 1))
        XCTAssertNil(sut.indexOf(1, startingAt: 10))
        
        // let's also tests with a different sort:
        let minHeapElements = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        sut = HeapBuffer(minHeapElements, heapType: .minHeap)
        XCTAssertNil(sut.indexOf(11))
        XCTAssertNil(sut.indexOf(1, startingAt: 1))
        XCTAssertNil(sut.indexOf(10, startingAt: 10))
    }
    
    func testIndexOf_whenElementIsPresent_returnsIndex() {
        let maxHeapElements = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
        sut = HeapBuffer(maxHeapElements, heapType: .maxHeap)
        XCTAssertEqual(sut.indexOf(10), 0)
        XCTAssertEqual(sut.indexOf(1, startingAt: 1), 9)
        XCTAssertEqual(sut.indexOf(8, startingAt: 2), 2)
        
        // let's also tests with a different sort:
        let minHeapElements = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        sut = HeapBuffer(minHeapElements, heapType: .minHeap)
        XCTAssertEqual(sut.indexOf(1), 0)
        XCTAssertEqual(sut.indexOf(10, startingAt: 1), 9)
        XCTAssertEqual(sut.indexOf(3, startingAt: 2), 2)
    }
    
    // MARK: - Performance tests
    func testPerformanceOfBufferHeapOnSmallCount() {
        measure(performanceLoopHeapBufferSmallCount)
    }
    
    func testPerformanceSortedArrayOnSmallCount() {
        measure(performanceLoopSortedArraySmallCount)
    }
    
    func testPerformanceOfBufferHeapOnLargeCount() {
        measure(performanceLoopHeapBufferLargeCount)
    }
    
    func testPerformanceSortedArrayOnLargeCount() {
        measure(performanceLoopSortedArrayLargeCount)
    }
    
    // MARK: - Helpers
    private func assertHeapProperty(file: StaticString = #file, line: UInt = #line) {
        func isHeapPropertyRespected(parent: Int = 0) -> Bool {
            var result = true
            let leftChild = (2 * parent) + 1
            let rightChild = (2 * parent) + 2
            if leftChild < sut._elementsCount {
                result = !sut._sort(sut._elements[leftChild], sut[parent])
                if result {
                    result = isHeapPropertyRespected(parent: leftChild)
                }
            }
            
            if result && rightChild < sut._elementsCount {
                result = !sut._sort(sut._elements[rightChild], sut[parent])
                if result {
                    result = isHeapPropertyRespected(parent: rightChild)
                }
            }
            
            return result
        }
        
        XCTAssertTrue(isHeapPropertyRespected(), "Heap property is not respected", file: file, line: line)
    }
    
    private func performanceLoopHeapBufferSmallCount() {
        let outerCount: Int = 10_000
        let innerCount: Int = 20
        var accumulator = 0
        for _ in 1...outerCount {
            let heap = HeapBuffer<Int>(innerCount, heapType: .maxHeap)
            for i in 1...innerCount {
                heap.insert(i)
                accumulator ^= (heap.peek() ?? 0)
            }
            for _ in 1...innerCount {
                accumulator ^= (heap.peek() ?? 0)
                heap.extract()
            }
        }
        XCTAssert(accumulator == 0)
    }
    
    private func performanceLoopHeapBufferLargeCount() {
        let outerCount: Int = 10
        let innerCount: Int = 20_000
        var accumulator = 0
        for _ in 1...outerCount {
            let heap = HeapBuffer<Int>(innerCount, heapType: .maxHeap)
            for i in 1...innerCount {
                heap.insert(i)
                accumulator ^= (heap.peek() ?? 0)
            }
            for _ in 1...innerCount {
                accumulator ^= (heap.peek() ?? 0)
                heap.extract()
            }
        }
        XCTAssert(accumulator == 0)
    }
    
    private func performanceLoopSortedArraySmallCount() {
        let outerCount: Int = 10_000
        let innerCount: Int = 20
        var accumulator = 0
        for _ in 1...outerCount {
            var array = Array<Int>()
            for i in 1...innerCount {
                array.heapInsert(i, heapType: .maxHeap)
                accumulator ^= (array.first ?? 0)
            }
            for _ in 1...innerCount {
                accumulator ^= (array.heapExtract(heapType: .maxHeap) ?? 0)
            }
        }
        XCTAssert(accumulator == 0)
    }
    
    private func performanceLoopSortedArrayLargeCount() {
        let outerCount: Int = 10
        let innerCount: Int = 20_000
        var accumulator = 0
        for _ in 1...outerCount {
            var array = Array<Int>()
            for i in 1...innerCount {
                array.heapInsert(i, heapType: .maxHeap)
                accumulator ^= (array.first ?? 0)
            }
            for _ in 1...innerCount {
                accumulator ^= (array.heapExtract(heapType: .maxHeap) ?? 0)
            }
        }
        XCTAssert(accumulator == 0)
    }
    
}

// MARK: - Other helpers
struct MyTestSequence<Element>: Sequence {
    let elements: Array<Element>
    let underestimatedCount: Int
    let hasContiguousBuffer: Bool
    
    init() {
        self.elements = []
        self.underestimatedCount = 0
        self.hasContiguousBuffer = true
    }
    
    init(elements: [Element], underestimatedCount: Int, hasContiguousBuffer: Bool) {
        self.elements = elements
        self.underestimatedCount = underestimatedCount >= 0 ? (underestimatedCount <= elements.count ? underestimatedCount : elements.count) : 0
        self.hasContiguousBuffer = hasContiguousBuffer
    }
    
    init(_ elements: [Element], hasUnderestimatedCount: Bool = true, hasContiguousBuffer: Bool = true) {
        self.elements = elements
        self.underestimatedCount = hasContiguousBuffer ? elements.count : 0
        self.hasContiguousBuffer = hasContiguousBuffer
    }
    
    // Sequence
    func makeIterator() -> AnyIterator<Element> {
        AnyIterator(elements.makeIterator())
    }
    
    func withContiguousStorageIfAvailable<R>(_ body: (UnsafeBufferPointer<Iterator.Element>) throws -> R) rethrows -> R? {
        guard hasContiguousBuffer else { return nil }
        
        return try elements.withUnsafeBufferPointer(body)
    }
    
}

// MARK: - Array extension for performance tests
// Since usually Heap are implemented on Array, we introduce some functionalities
// as an extension on Array, in this way it is possible to do a performance comparison
// between adopting the HeapBuffer rather than using an Array as a Heap.
extension Array where Element: Comparable {
    mutating func heapExtract(heapType: HeapBuffer<Element>.HeapType) -> Element? {
        guard !isEmpty else { return nil }
        
        swapAt(0, count - 1)
        let removed = self.popLast()
        defer { _siftDown(from: 0, heapType: heapType) }
        
        return removed
    }
    
    mutating func heapInsert(_ newElement: Element, heapType: HeapBuffer<Element>.HeapType) {
        append(newElement)
        _siftUp(from: count - 1, heapType: heapType)
    }
    
    private mutating func _siftUp(from idx: Int, heapType: HeapBuffer<Element>.HeapType) {
        let sort: (Element, Element) -> Bool = { lhs, rhs in
            switch heapType {
            case .minHeap:
                return lhs < rhs
            case .maxHeap:
                return lhs > rhs
            }
        }
        var child = idx
        var parent = _parentIdx(of: child)
        while child > 0 && sort(self[child], self[parent]) {
            swapAt(child, parent)
            child = parent
            parent = _parentIdx(of: child)
        }
    }
    
    private mutating func _siftDown(from idx: Int, heapType: HeapBuffer<Element>.HeapType) {
        let sort: (Element, Element) -> Bool = { lhs, rhs in
            switch heapType {
            case .minHeap:
                return lhs < rhs
            case .maxHeap:
                return lhs > rhs
            }
        }
        var parent = idx
        while true {
            let left = _leftChild(of: parent)
            let right = _rightChild(of: parent)
            var candidate = parent
            if left < count && sort(self[left], self[candidate]) {
                candidate = left
            }
            if right < count && sort(self[right], self[candidate]) {
                candidate = right
            }
            if candidate == parent { return }
            
            swapAt(parent, candidate)
            parent = candidate
        }
        
    }
    
    private func _leftChild(of parent: Int) -> Int { (parent * 2) + 1 }
    
    private func _rightChild(of parent: Int) -> Int { (parent * 2) + 2 }
    
    private func _parentIdx(of child: Int) -> Int { (child - 1) / 2 }
    
}
