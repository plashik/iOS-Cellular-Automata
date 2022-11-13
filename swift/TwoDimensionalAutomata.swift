public class TwoDimensionalCellularAutomata: CellularAutomata {
    public typealias State = AutomataState
    
    public var rule: ((State) -> BinaryCell)
    
    public init(rule: @escaping (State) -> BinaryCell) {
        self.rule = rule
    }
    
    public func simulate(_ state: AutomataState, generations: UInt) throws -> AutomataState {
        var state = state
        for _ in 0 ..< generations {
            guard state.viewport.area != 0
            else { return state }
            
            let oldState = state
            
            // if needed
            state.viewport = state.viewport
                .resizing(toInclude: oldState.viewport.bottomLeft + Point(x: -1, y: 0))
                .resizing(toInclude: oldState.viewport.topRight + Point(x: 0, y: -1))
            
            for y in state.viewport.yRange {
                for x in state.viewport.xRange {
                    state = getVicinity(state: state, oldState: oldState, x: x, y: y)
                }
            }
            //print(state)
        }
        return state
    }
    
    private func getVicinity(state: State, oldState: State, x: Int, y: Int) -> AutomataState {
        var state = state
        state[Point(x: x, y: y)] = self.rule(oldState[Rect(origin: Point(x: x - 1, y: y - 1), size: .vicinitySize)])
        return state
    }
}
