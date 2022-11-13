public class ElementaryCellularAutomata: CellularAutomata {
    public typealias State = AutomataState
    
    let rule: UInt8
    
    public init(rule: UInt8) {
        self.rule = rule
    }
    
    public func simulate(_ state: AutomataState, generations: UInt) throws -> AutomataState {
        var state = state
        for _ in 0 ..< generations {
            guard let y = state.viewport.yRange.last, state.viewport.area != 0 else { return state }
            
            state.viewport = state.viewport
                .resizing(toInclude: state.viewport.bottomLeft + Point(x: -1, y: 0))
                .resizing(toInclude: state.viewport.bottomRight + Point(x: 1, y: 0))
            
            for x in state.viewport.xRange {
                let l = state[Point(x: x - 1, y: y)].rawValue
                let m = state[Point(x: x, y: y)].rawValue
                let r = state[Point(x: x + 1, y: y)].rawValue
                state[Point(x: x, y: y + 1)] = BinaryCell(rawValue: self.rule >> (l << 2 | m << 1 | r << 0) & 1)!
            }
        }
        return state
    }
}
