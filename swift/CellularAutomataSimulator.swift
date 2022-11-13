public protocol CellularAutomata {
    associatedtype State: CellularAutomataState

    /// Возвращает новое состояние поля после n поколений
    /// - Parameters:
    ///   - state: Исходное состояние поля
    ///   - generations: Количество симулируемых поколений
    /// - Returns:
    ///   - Новое состояние после симуляции
    func simulate(_ state: State, generations: UInt) throws -> State
}

public protocol CellularAutomataState {
    associatedtype Cell
    associatedtype SubState: CellularAutomataState

    /// Конструктор пустого поля
    init()

    /// Квадрат представляемой области в глобальных координатах поля
    /// Присвоение нового значения меняет поле обрезая/дополняя его до нужного размера
    var viewport: Rect { get set }

    /// Значение конкретной ячейки в точке, заданной в глобальных координатах.
    subscript(_: Point) -> Cell { get set }
    /// Значение поля в прямоугольнике, заданном в глобальных координатах.
    subscript(_: Rect) -> SubState { get set }

    /// Меняет origin у viewport
    mutating func translate(to: Point)
}

public struct Size {
    public let width: Int
    public let height: Int

    public init(width: Int, height: Int) {
        guard width >= 0 && height >= 0 else { fatalError() }
        self.width = width
        self.height = height
    }
}

public struct Point {
    public let x: Int
    public let y: Int
    public init (x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

public struct Rect {
    public let origin: Point
    public let size: Size
    public init (origin: Point, size: Size) {
        self.origin = origin
        self.size = size
    }
}

public enum BinaryCell: UInt8 {
    case inactive = 0
    case active = 1
}
