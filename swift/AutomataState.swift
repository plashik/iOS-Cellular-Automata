public struct AutomataState: CellularAutomataState, CustomStringConvertible {
    public typealias Cell = BinaryCell
    public typealias SubState = Self
    
    private var array: Array<Cell>
    private var _viewport: Rect
    public var viewport: Rect {
        get {
            self._viewport
        }
        set {
            self.array = Self.resize(self.array, from: self.viewport, to: newValue)
            self._viewport = newValue
        }
    }
    
    public var description: String {
         var string = ""
         for y in self.viewport.yRange {
             for x in self.viewport.xRange {
                 if self[Point(x: x, y: y)] == .inactive {
                     string.append(contentsOf: " ")
                 }
                 else {
                     string.append(contentsOf: "█")
                 }
             }
             string.append(contentsOf: "\n")
         }
         return string
    }
    
    public init() {
        self._viewport = .zero
        self.array = []
    }
    
    public subscript(_ point: Point) -> BinaryCell {
        get {
            guard let index = Self.getIndex(at: point, in: self.viewport) else { return .inactive }
            return self.array[index]
        }
        set {
            let newViewport = self.viewport.resizing(toInclude: point)
            self.array = Self.resize(self.array, from: self.viewport, to: newViewport)
            self._viewport = newViewport
            
            guard let index = Self.getIndex(at: point, in: self.viewport) else { fatalError("Unable to set new point") }
            return self.array[index] = newValue
        }
    }

    public subscript(_ rectangle: Rect) -> AutomataState {
        get {
            var rectState = self
            rectState.viewport = rectangle
            return rectState
        }
        set {
            self.array = Self.copy(newValue.array, from: rectangle, to: self.viewport, new: self.array)
        }
    }

    public mutating func translate(to newOrigin: Point) {
        self._viewport = Rect(origin: newOrigin, size: self._viewport.size)
    }
    
    private static func getIndex(at point: Point, in viewport: Rect) -> Int? {
        guard viewport.contains(point: point) else {return nil}
        let localPoint = point - viewport.origin
        return localPoint.x + localPoint.y * viewport.size.width
    }
    
    private static func resize(_ oldArray: [Cell], from oldViewport: Rect, to newViewport: Rect) -> [Cell] {
        return copy(oldArray, from: oldViewport, to: newViewport, new: Array<Cell>(repeating: .inactive, count: newViewport.area))
    }
    
    private static func copy(_ oldArray: [Cell], from oldViewport: Rect, to newViewport: Rect, new newArray: [Cell]) -> [Cell] {
        var newArray = newArray
        for point in oldViewport.indices {
            guard let newArrayIndex = Self.getIndex(at: point, in: newViewport) else {continue}
            guard let oldArrayIndex = Self.getIndex(at: point, in: oldViewport) else {continue}
            newArray[newArrayIndex] = oldArray[oldArrayIndex]
        }
        return newArray
    }
}
