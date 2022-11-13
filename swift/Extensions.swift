extension Size: Equatable {
    static let zero = Self(width: 0, height: 0)
    static let vicinitySize = Self(width: 3, height: 3)
    
    var area: Int {
        self.width * self.height
    }
    
    public static func == (lhs: Size, rhs: Size) -> Bool {
        return lhs.width == rhs.width && lhs.height == rhs.height
    }
}

extension Point: Equatable {
    static let zero = Self(x: 0, y: 0)
    
    public static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    public static func +(lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    public static func -(lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

extension Rect: Equatable {
    static let zero = Self(origin: .zero, size: .zero)
    
    var area: Int {
        self.size.area
    }
    
    public var xRange: Range<Int> {
        self.origin.x ..< self.origin.x + self.size.width
    }
    public var yRange: Range<Int> {
        self.origin.y ..< self.origin.y + self.size.height
    }
    
    var indices: [Point] {
        self.xRange.flatMap {x in self.yRange.map {y in Point(x: x, y: y)}}
    }
    
    var bottomLeft: Point {
        Point(x: self.origin.x, y: self.origin.y + self.size.height)
    }
    var bottomRight: Point {
        Point(x: self.origin.x + self.size.width, y: self.origin.y + self.size.height)
    }
    var topLeft: Point {
        Point(x: self.origin.x, y: self.origin.y)
    }
    var topRight: Point {
        Point(x: self.origin.x + self.size.width, y: self.origin.y)
    }
    
    public static func == (lhs: Rect, rhs: Rect) -> Bool {
        return lhs.origin == rhs.origin && lhs.size == rhs.size
    }
    
    func contains(point: Point) -> Bool {
        return self.xRange.contains(point.x) && self.yRange.contains(point.y)
    }
    
    func resizing(toInclude point: Point) -> Rect {
        let newOrigin = Point(x: min(self.origin.x, point.x), y: min(self.origin.y, point.y))
        let newSize = Size(
            width: max(self.origin.x + self.size.width, point.x + 1) - newOrigin.x,
            height: max(self.origin.y + self.size.height, point.y + 1) - newOrigin.y
        )
        return Rect(origin: newOrigin, size: newSize)
    }
}
