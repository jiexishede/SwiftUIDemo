//
//  DialogQueue.swift
//  ReduxSwiftUIDemo
//
//  Priority queue for managing dialog presentation order
//  用于管理对话框展示顺序的优先级队列
//
//  Created by AI Assistant on 2025/1/12.
//

import Foundation
import Combine

/**
 * DESIGN PATTERNS USED / 使用的设计模式:
 * 1. Priority Queue Pattern (优先级队列模式)
 *    - Why: Ensures high-priority dialogs are shown before low-priority ones / 为什么：确保高优先级对话框在低优先级对话框之前显示
 *    - Benefits: Automatic ordering, prevents dialog overlap, manages presentation flow / 好处：自动排序，防止对话框重叠，管理展示流程
 *
 * 2. Observer Pattern (观察者模式)
 *    - Why: Notifies listeners when queue state changes / 为什么：当队列状态改变时通知监听者
 *    - Benefits: Reactive UI updates, decoupled components / 好处：响应式UI更新，解耦组件
 *
 * 3. Thread-Safe Pattern (线程安全模式)
 *    - Why: Queue may be accessed from multiple threads / 为什么：队列可能从多个线程访问
 *    - Benefits: Prevents race conditions, ensures data integrity / 好处：防止竞态条件，确保数据完整性
 */

// MARK: - Dialog Queue Item / 对话框队列项
/// Wrapper for dialog configurations in the queue / 队列中对话框配置的包装器
public struct DialogQueueItem: Identifiable {
    /// Unique identifier / 唯一标识符
    public let id = UUID()

    /// Dialog configuration / 对话框配置
    public let configuration: DialogConfiguration

    /// Completion handler when dialog is dismissed / 对话框关闭时的完成处理器
    public let completion: (() -> Void)?

    /// Timestamp for ordering within same priority / 同一优先级内排序的时间戳
    public let timestamp: Date

    /// Initialize queue item / 初始化队列项
    /// - Parameters:
    ///   - configuration: Dialog configuration / 对话框配置
    ///   - completion: Completion handler / 完成处理器
    public init(
        configuration: DialogConfiguration,
        completion: (() -> Void)? = nil
    ) {
        self.configuration = configuration
        self.completion = completion
        self.timestamp = Date()
    }
}

// MARK: - Dialog Queue / 对话框队列
/// Priority queue for managing dialog presentation / 管理对话框展示的优先级队列
///
/// Example usage / 使用示例:
/// ```swift
/// let queue = DialogQueue()
///
/// // Add dialog to queue / 添加对话框到队列
/// queue.enqueue(DialogQueueItem(configuration: config))
///
/// // Get next dialog / 获取下一个对话框
/// if let nextItem = queue.dequeue() {
///     presentDialog(nextItem.configuration)
/// }
///
/// // Check if queue has items / 检查队列是否有项目
/// if !queue.isEmpty {
///     print("Queue has \(queue.count) dialogs")
/// }
/// ```
public class DialogQueue: ObservableObject {
    // MARK: - Properties / 属性

    /// Internal priority queue storage / 内部优先级队列存储
    private var items: [DialogQueueItem] = []

    /// Thread safety lock / 线程安全锁
    private let lock = NSLock()

    /// Published property for queue changes / 队列变化的发布属性
    @Published public private(set) var isEmpty: Bool = true

    /// Published property for queue count / 队列计数的发布属性
    @Published public private(set) var count: Int = 0

    /// Published property for current item / 当前项的发布属性
    @Published public private(set) var currentItem: DialogQueueItem?

    /// Maximum queue size / 最大队列大小
    private let maxQueueSize: Int

    // MARK: - Initializer / 初始化器

    /// Initialize dialog queue / 初始化对话框队列
    /// - Parameter maxQueueSize: Maximum number of dialogs in queue / 队列中对话框的最大数量
    public init(maxQueueSize: Int = 10) {
        self.maxQueueSize = maxQueueSize
    }

    // MARK: - Public Methods / 公共方法

    /// Add dialog to queue / 添加对话框到队列
    /// - Parameter item: Dialog queue item / 对话框队列项
    /// - Returns: True if added, false if queue is full / 如果添加成功返回true，如果队列已满返回false
    @discardableResult
    public func enqueue(_ item: DialogQueueItem) -> Bool {
        lock.lock()
        defer {
            lock.unlock()
            updatePublishedProperties()
        }

        // Check queue size limit / 检查队列大小限制
        guard items.count < maxQueueSize else {
            print("DialogQueue: Queue is full, cannot add more dialogs / 队列已满，无法添加更多对话框")
            return false
        }

        // Find insertion position based on priority / 根据优先级找到插入位置
        let insertionIndex = findInsertionIndex(for: item)
        items.insert(item, at: insertionIndex)

        print("DialogQueue: Enqueued dialog with priority \(item.configuration.priority) / 入队优先级为 \(item.configuration.priority) 的对话框")
        return true
    }

    /// Remove and return next dialog from queue / 从队列中移除并返回下一个对话框
    /// - Returns: Next dialog item or nil if empty / 下一个对话框项或nil（如果为空）
    public func dequeue() -> DialogQueueItem? {
        lock.lock()
        defer {
            lock.unlock()
            updatePublishedProperties()
        }

        guard !items.isEmpty else {
            currentItem = nil
            return nil
        }

        let item = items.removeFirst()
        currentItem = items.first

        print("DialogQueue: Dequeued dialog with priority \(item.configuration.priority) / 出队优先级为 \(item.configuration.priority) 的对话框")
        return item
    }

    /// Peek at next dialog without removing / 查看下一个对话框而不移除
    /// - Returns: Next dialog item or nil if empty / 下一个对话框项或nil（如果为空）
    public func peek() -> DialogQueueItem? {
        lock.lock()
        defer { lock.unlock() }

        return items.first
    }

    /// Remove specific dialog from queue / 从队列中移除特定对话框
    /// - Parameter id: Dialog ID to remove / 要移除的对话框ID
    /// - Returns: Removed item or nil if not found / 移除的项或nil（如果未找到）
    @discardableResult
    public func remove(byId id: UUID) -> DialogQueueItem? {
        lock.lock()
        defer {
            lock.unlock()
            updatePublishedProperties()
        }

        guard let index = items.firstIndex(where: { $0.id == id }) else {
            return nil
        }

        let removedItem = items.remove(at: index)
        print("DialogQueue: Removed dialog with ID \(id) / 移除ID为 \(id) 的对话框")
        return removedItem
    }

    /// Clear all dialogs from queue / 清除队列中的所有对话框
    public func clear() {
        lock.lock()
        defer {
            lock.unlock()
            updatePublishedProperties()
        }

        let count = items.count
        items.removeAll()
        currentItem = nil

        print("DialogQueue: Cleared \(count) dialogs from queue / 从队列中清除了 \(count) 个对话框")
    }

    /// Check if queue contains dialog with specific ID / 检查队列是否包含特定ID的对话框
    /// - Parameter id: Dialog ID / 对话框ID
    /// - Returns: True if contains, false otherwise / 如果包含返回true，否则返回false
    public func contains(id: UUID) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        return items.contains(where: { $0.id == id })
    }

    /// Get all dialogs in queue / 获取队列中的所有对话框
    /// - Returns: Array of dialog items in priority order / 按优先级顺序排列的对话框项数组
    public func getAllItems() -> [DialogQueueItem] {
        lock.lock()
        defer { lock.unlock() }

        return items
    }

    /// Get dialogs with specific priority / 获取特定优先级的对话框
    /// - Parameter priority: Priority level / 优先级级别
    /// - Returns: Array of dialog items with specified priority / 具有指定优先级的对话框项数组
    public func getItems(withPriority priority: DialogPriority) -> [DialogQueueItem] {
        lock.lock()
        defer { lock.unlock() }

        return items.filter { $0.configuration.priority == priority }
    }

    // MARK: - Private Methods / 私有方法

    /// Find insertion index based on priority and timestamp / 根据优先级和时间戳找到插入索引
    /// - Parameters:
    ///   - item: The dialog queue item to insert / 要插入的对话框队列项
    /// - Returns: Index to insert at / 要插入的索引
    private func findInsertionIndex(for item: DialogQueueItem) -> Int {
        let priority = item.configuration.priority

        // Special handling for deferred priority - LIFO (Last In First Out)
        // 对延迟优先级的特殊处理 - LIFO（后进先出）
        if priority == .deferred {
            // Find the first deferred item and insert before it (LIFO)
            // 找到第一个延迟项并在它之前插入（LIFO）
            for (index, existingItem) in items.enumerated() {
                let existingPriority = existingItem.configuration.priority

                if existingPriority == .deferred {
                    // Insert new deferred item before existing deferred items (LIFO)
                    // 在现有延迟项之前插入新的延迟项（LIFO）
                    return index
                } else if existingPriority < priority {
                    // Found lower priority, insert here
                    // 找到更低优先级，在此插入
                    return index
                }
            }
        }
        // Special handling for immediate priority - FIFO (First In First Out)
        // 对立即优先级的特殊处理 - FIFO（先进先出）
        else if priority == .immediate {
            // Find the last immediate item and insert after it (FIFO)
            // 找到最后一个立即项并在它之后插入（FIFO）
            var lastImmediateIndex = -1
            for (index, existingItem) in items.enumerated() {
                let existingPriority = existingItem.configuration.priority

                if existingPriority == .immediate {
                    lastImmediateIndex = index
                } else if existingPriority < priority {
                    // Found lower priority
                    // 找到更低优先级
                    break
                }
            }

            if lastImmediateIndex >= 0 {
                // Insert after the last immediate item (FIFO)
                // 在最后一个立即项之后插入（FIFO）
                return lastImmediateIndex + 1
            }
        }

        // Normal priority handling - FIFO within same priority
        // 正常优先级处理 - 同一优先级内FIFO
        for (index, existingItem) in items.enumerated() {
            let existingPriority = existingItem.configuration.priority

            if existingPriority < priority {
                return index
            } else if existingPriority == priority {
                // Same priority - FIFO (insert after items with same priority)
                // 相同优先级 - FIFO（在相同优先级的项之后插入）
                continue
            }
        }

        // If no lower priority found, add to the end / 如果没有找到更低的优先级，添加到末尾
        return items.count
    }

    /// Update published properties / 更新发布的属性
    private func updatePublishedProperties() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isEmpty = self.items.isEmpty
            self.count = self.items.count
        }
    }
}

// MARK: - Queue Statistics / 队列统计
extension DialogQueue {
    /// Queue statistics / 队列统计
    public struct Statistics {
        /// Total dialogs in queue / 队列中的总对话框数
        public let total: Int

        /// Count by priority / 按优先级计数
        public let byPriority: [DialogPriority: Int]

        /// Average wait position / 平均等待位置
        public let averagePosition: Double

        /// Is queue at capacity / 队列是否已满
        public let isAtCapacity: Bool
    }

    /// Get queue statistics / 获取队列统计
    /// - Returns: Queue statistics / 队列统计
    public func getStatistics() -> Statistics {
        lock.lock()
        defer { lock.unlock() }

        var priorityCounts: [DialogPriority: Int] = [:]
        for item in items {
            priorityCounts[item.configuration.priority, default: 0] += 1
        }

        let averagePos = items.isEmpty ? 0 : Double(items.count) / 2.0

        return Statistics(
            total: items.count,
            byPriority: priorityCounts,
            averagePosition: averagePos,
            isAtCapacity: items.count >= maxQueueSize
        )
    }
}

// MARK: - Queue Debugging / 队列调试
extension DialogQueue: CustomDebugStringConvertible {
    public var debugDescription: String {
        lock.lock()
        defer { lock.unlock() }

        let itemDescriptions = items.map { item in
            "  - \(item.configuration.title) (Priority: \(item.configuration.priority))"
        }.joined(separator: "\n")

        return """
        DialogQueue:
        Count: \(items.count) / \(maxQueueSize)
        Items:
        \(itemDescriptions.isEmpty ? "  (empty)" : itemDescriptions)
        """
    }
}