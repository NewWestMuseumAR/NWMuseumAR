// 1
public struct Queue<T> {
 
  // 2
  fileprivate var list = LinkedList<T>()
 
  public var isEmpty: Bool {
    return list.isEmpty
  }
 
  // 3
  public mutating func enqueue(_ element: T) {
    list.append(element)
  }
 
  // 4
  public mutating func dequeue() -> T? {
    guard !list.isEmpty, let element = list.first else { return nil }
 
    list.remove(element)
 
    return element.value
  }
 
  // 5
  public func peek() -> T? {
    return list.first?.value
  }
}

// 1
extension Queue: CustomStringConvertible {
  // 2
  public var description: String {
    // 3
    return list.description
  }
}

var queue = Queue<Int>()
queue.enqueue(10)
queue.enqueue(3)
queue.enqueue(57)

print(queue)

var queue2 = Queue<String>()
queue2.enqueue("mad")
queue2.enqueue("lad")
if let first = queue2.dequeue() {
  print(first)
}
print(queue2)
