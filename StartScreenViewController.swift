import Foundation
import UIKit
import CellularAutomataSimulator

public func gameOfLife(state: AutomataState) -> BinaryCell {
    var neighbourCount = 0
    let currentPoint = Point(x: state.viewport.origin.x + 1, y: state.viewport.origin.y + 1)
    for y in state.viewport.yRange {
        for x in state.viewport.xRange {
            if state[Point(x: x, y: y)].rawValue == 1
            {
                if x != currentPoint.x || y != currentPoint.y {
                    neighbourCount += 1
                }
            }
        }
    }
    
    if state[currentPoint] == .active {
        if neighbourCount < 2 || neighbourCount > 3 {
            return .inactive
        }
        return .active
    }
    if neighbourCount == 3 {
        return .active
    }
    return .inactive
}

public var isGoL = true
public var currentRule = 1
public var defaultTileSize = CGFloat(48 * 2)
public var fieldHeight = 10
public var fieldWidth = 10
public var state = AutomataState()
public var savedState = AutomataState()
public var autstart = TwoDimensionalCellularAutomata(rule: gameOfLife(state:))
public var speed = TimeInterval(1)
public var isPaused = false
//public var automataTitle = "a"
var heightAnchor : NSLayoutConstraint!
var widthAnchor : NSLayoutConstraint!

class StartScreenViewController: UIViewController {
    let scrollView = UIScrollView()
    let tiledView = GridCellularAutomataView()
    
    var animationTimer : Timer?
    public var loadButton = UIBarButtonItem()
    public var saveButton = UIBarButtonItem()
    public var playPauseButton = UIBarButtonItem()
    public var nextButton = UIBarButtonItem()
    public var addButton = UIBarButtonItem()
    public var flexibleSpace = UIBarButtonItem()
    
    ///
    ///state[Point(Rect(origin: touch, size: 3 x 3 (get from figure))] = figureAsset(code)
    ///
    ///popover?
    
    fileprivate func initializeState() {
        state.viewport = Rect(origin: Point(x: -2, y: -2), size: Size(width: 5, height: 5))
        for y in state.viewport.yRange {
            for x in state.viewport.xRange {
                state[Point(x: x, y: y)] = .inactive
            }
        }
        state[Point(x: 0, y: 0)] = .active
        state[Point(x: 1, y: 0)] = .active
        state[Point(x: 2, y: 0)] = .active
        state[Point(x: 2, y: 1)] = .active
        state[Point(x: 1, y: 2)] = .active
        state = try! autstart.simulate(state, generations: 2)
        print(state)
    }
    
    fileprivate func getAut() -> (GoL: TwoDimensionalCellularAutomata, elementary: ElementaryCellularAutomata, isGoL: Bool) {
        return (TwoDimensionalCellularAutomata(rule: gameOfLife(state:)), ElementaryCellularAutomata(rule: UInt8(currentRule)), isGoL)
    }
    
    fileprivate func setUpTapRecognizer() {
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(invertOnTap))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        self.tiledView.addGestureRecognizer(singleTap)
    }
    
    fileprivate func setUpToolbar() {
        flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil);
        saveButton = UIBarButtonItem(image: UIImage(systemName: "tray.and.arrow.down"), style: .plain, target: self, action: #selector(saveAction))
        loadButton = UIBarButtonItem(image: UIImage(systemName: "tray.and.arrow.up"), style: .plain, target: self, action: #selector(loadAction))
        playPauseButton = UIBarButtonItem(image: UIImage(systemName: "pause"), style: .plain, target: self, action: #selector(playPauseAction))
        nextButton = UIBarButtonItem(image: UIImage(systemName: "forward"), style: .plain, target: self, action: #selector(nextAction))
        addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(libraryAction))
        self.setToolbarItems(
            [saveButton, flexibleSpace, loadButton, flexibleSpace, playPauseButton, flexibleSpace, nextButton, flexibleSpace, addButton],
            animated: true
        )
        view.addSubview(scrollView)
    }
    
    @objc func saveAction (sender: UIButton) {
        savedState = state
    }
    
    @objc func loadAction (sender: UIButton) {
        state = savedState
        self.tiledView.setNeedsDisplay()
    }
    
    fileprivate func step() {
        if getAut().isGoL {
            let aut = getAut().GoL
            state = try! aut.simulate(state, generations: 1)
        }
        else {
            let aut = getAut().elementary
            state = try! aut.simulate(state, generations: 1)
        }
    }
    
    @objc func nextAction (sender: UIButton) {
        if isPaused {
            step()
            self.tiledView.setNeedsDisplay()
        }
    }
    
    @objc func playPauseAction (sender: UIButton) {
        isPaused = !isPaused
        if !isPaused {
            //resume
            playPauseButton = UIBarButtonItem(image: UIImage(systemName: "pause"), style: .plain, target: self, action: #selector(playPauseAction))
            self.setToolbarItems(
                [saveButton, flexibleSpace, loadButton, flexibleSpace, playPauseButton, flexibleSpace, nextButton, flexibleSpace, addButton],
                animated: true
            )
            animationTimer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true, block: { (timer) in
                //state = try! aut.simulate(state, generations: 1)
                self.step()
                self.tiledView.setNeedsDisplay()
            })
        }
        else { //pause
            playPauseButton = UIBarButtonItem(image: UIImage(systemName: "play"), style: .plain, target: self, action: #selector(playPauseAction))
            self.setToolbarItems(
                [saveButton, flexibleSpace, loadButton, flexibleSpace, playPauseButton, flexibleSpace, nextButton, flexibleSpace, addButton],
                animated: true
            )
            animationTimer?.invalidate()
        }
    }
    
    @objc func libraryAction (sender: UIButton) {
        let libraryViewController = MainScreenViewController()
        self.navigationController?.pushViewController(libraryViewController, animated: true)
        
        self.tiledView.setNeedsDisplay()
        //present(libraryViewController, animated: true, completion: nil)
    }
    
    @objc func invertOnTap(recognizer: UITapGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizer.State.ended) && isPaused {
            //let deltaWidth = (state.viewport.size.width - 1) / 2
            //let deltaHeight = (state.viewport.size.height - 1) / 2
            let deltaWidth = (fieldWidth - 1) / 2
            let deltaHeight = (fieldHeight - 1) / 2
            let point = recognizer.location(in: self.tiledView)
            let x = Int(point.x / defaultTileSize)
            let y = Int(point.y / defaultTileSize)
            //print(point.x)
            //print(point.y)
            //print(tiledView.tiledLayer.tileSize)
            if state[Point(x: x - deltaWidth, y: y - deltaHeight)] == .inactive {
                state[Point(x: x - deltaWidth, y: y - deltaHeight)] = .active
            }
            else {
                state[Point(x: x - deltaWidth, y: y - deltaHeight)] = .inactive
            }
            self.tiledView.setNeedsDisplay()
        }
    }
    
    fileprivate func setUpScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 5.0
        scrollView.addSubview(tiledView)
    }
    
    fileprivate func setUpTiledView() {
        tiledView.translatesAutoresizingMaskIntoConstraints = false
        tiledView.tiledLayer.tileSize = CGSize(width: defaultTileSize, height: defaultTileSize)
        //tiledView.contentScaleFactor = 5.0
        //tiledView.contentScaleFactor = 1.0
    }
    
    fileprivate func setUpConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            
            tiledView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            tiledView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            tiledView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            tiledView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor)
        ])
        //heightAnchor = tiledView.heightAnchor.constraint(equalToConstant: CGFloat(state.viewport.size.height) * c50)
        heightAnchor = tiledView.heightAnchor.constraint(equalToConstant: CGFloat(10) * defaultTileSize)
        heightAnchor.isActive = true
        //widthAnchor = tiledView.widthAnchor.constraint(equalToConstant: CGFloat(state.viewport.size.width) * c50)
        widthAnchor = tiledView.widthAnchor.constraint(equalToConstant: CGFloat(10) * defaultTileSize)
        widthAnchor.isActive = true
    }
    
    override func viewDidLoad() {
        autstart = TwoDimensionalCellularAutomata(rule: gameOfLife(state:))
        state = AutomataState()
        
        initializeState()
        
        super.viewDidLoad()
        
        view.backgroundColor = .white
        //self.navigationItem.title = automataTitle
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: nil)
        
        let changeFieldSize = UIAction(title: "Change field size", image: UIImage(systemName: "square.and.pencil")) { (action) in
            let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)

            let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
                let firstTextField = alertController.textFields![0] as UITextField
                let secondTextField = alertController.textFields![1] as UITextField
                let newHeight = Int(firstTextField.text!) ?? 0
                let newWidth = Int(secondTextField.text!) ?? 0
                heightAnchor.constant = CGFloat(newHeight) * defaultTileSize
                widthAnchor.constant = CGFloat(newWidth) * defaultTileSize
                fieldHeight = newHeight
                fieldWidth = newWidth
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
            })

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil )

            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = ""
                textField.keyboardType = .numberPad
            }
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = ""
                textField.keyboardType = .numberPad
            }

            alertController.addAction(cancelAction)
            alertController.addAction(saveAction)

            self.present(alertController, animated: true, completion: nil)
        }
        
        let clearField = UIAction(title: "Clear field", image: UIImage(systemName: "trash")) { (action) in
            let alert = UIAlertController(
                title: nil,
                message: nil,
                preferredStyle: .actionSheet
            )
            alert.addAction(UIAlertAction(
                title: "Clear field",
                style: .destructive,
                handler: { _ in
                    state = AutomataState()
                    self.tiledView.setNeedsDisplay()
                })
            )
            alert.addAction(UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: { _ in
            }))
            self.present(alert,
                    animated: true,
                    completion: nil
            )
        }
        clearField.attributes = .destructive
        
        let setUpGoL = UIAction(title: "Game of Life", image: UIImage(systemName: "")) { (action) in
            //aut = TwoDimensionalCellularAutomata(rule: gameOfLife(state:))
            isGoL = true
            state = AutomataState()
            //state[Point(x: 0, y: 0)] = .active
            self.initializeState()
            self.view.setNeedsDisplay()
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
            //alert to input rule
        }
        
        let setUpWolfram = UIAction(title: "Elementary", image: UIImage(systemName: "")) { (action) in
            let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)

            let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
                let firstTextField = alertController.textFields![0] as UITextField
                let n = Int(firstTextField.text!) ?? 0
                //aut = ElementaryCellularAutomata(rule: n)
                isGoL = false
                currentRule = n
                state = AutomataState()
                state[Point(x: 0, y: 0)] = .active
                self.view.setNeedsDisplay()
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
            })

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil )

            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = ""
                textField.keyboardType = .numberPad
            }

            alertController.addAction(cancelAction)
            alertController.addAction(saveAction)

            self.present(alertController, animated: true, completion: nil)
        }

        let setUp = UIMenu(title: "Set up", options: .displayInline, children: [setUpGoL, setUpWolfram])
        let setUpSection = UIMenu(title: "Set up", children: [setUp])
        let menu = UIMenu(title: "", options: .displayInline, children: [setUpSection, changeFieldSize, clearField])
        self.navigationItem.rightBarButtonItem?.menu = menu
        
        setUpToolbar()
        
        setUpTiledView()
        
        setUpScrollView()
        
        setUpTapRecognizer()
        
        setUpConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        if let nav = self.navigationController {
           nav.isToolbarHidden = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animationTimer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true, block: { (timer) in
            self.step()
            //state = try! aut.simulate(state, generations: 1)
            self.tiledView.setNeedsDisplay()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        animationTimer!.invalidate()
        animationTimer = nil
    }
}

extension StartScreenViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        tiledView
    }
}

class GridCellularAutomataView : UIView {
    var sideLength: CGFloat = defaultTileSize //wrong one?
    
    override class var layerClass: AnyClass {
        return CATiledLayer.self
    }
    
    var tiledLayer: CATiledLayer { layer as! CATiledLayer }
    
    override func draw(_ rect: CGRect) {
        //c50 = rect.size.width
        //c50 = 2 * rect.size.width
        //sideLength = rect.size.width
        let context = UIGraphicsGetCurrentContext()
        
        tiledLayer.tileSize = CGSize(width: defaultTileSize, height: defaultTileSize)
        
        //let deltaWidth = (state.viewport.size.width - 1) / 2
        //let deltaHeight = (state.viewport.size.height - 1) / 2
        
        let deltaWidth = (fieldWidth - 1) / 2
        let deltaHeight = (fieldHeight - 1) / 2
        
        let thisx = Int(rect.origin.x / defaultTileSize) - deltaWidth
        let thisy = Int(rect.origin.y / defaultTileSize) - deltaHeight
        
        if (state[Point(x: thisx, y: thisy)] == .inactive)
        {
            context?.setFillColor(red: 100, green: 100, blue: 100, alpha: 1)
        }
        else
        {
            context?.setFillColor(red: 0, green: 0, blue: 0, alpha: 1)
        }
        
        context?.fill(rect)
        
        UIColor.lightGray.setStroke()
        
        if (Int(rect.origin.y) % Int(defaultTileSize) == 0) {
            let a = UIBezierPath()
            a.move(to: CGPoint(x: rect.origin.x + rect.size.height, y: rect.origin.y))
            a.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
            a.stroke()
        }
        
        if (Int(rect.origin.x) % Int(defaultTileSize) == 0) {
            let a = UIBezierPath()
            a.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height))
            a.addLine(to: CGPoint(x: rect.origin.x, y: rect.origin.y))
            a.stroke()
        }
        
        //let dp = UIBezierPath.init(rect: rect)
        //dp.stroke()
        //let p2 = UIBezierPath.init(ovalIn: rect)
    }
}
