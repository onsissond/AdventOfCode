/*
 https://adventofcode.com/2022/day/8
 */

struct TreePosition: Hashable, CustomDebugStringConvertible {
    let row: Int
    let column: Int
    
    var debugDescription: String {
        "[\(row), \(column)]"
    }
}

enum Part1 {
    enum Cursor: Hashable {
        case column(Int)
        case row(Int)
    }

    static func solution(_ input: String) -> Int {
        let trees = input
            .split(separator: "\n")
            .map { $0.map { Int(String($0))! } }
        let leftTopTrees = traversal(
            trees: trees,
            rows: stride(from: 0, to: trees.count, by: 1),
            columns: { row in stride(from: 0, to: trees[row].count, by: 1) }
        )
        let rightBottomTrees = traversal(
            trees: trees,
            rows: stride(from: trees.count - 1, to: -1, by: -1),
            columns: { row in stride(from: trees[row].count - 1, to: -1, by: -1) }
        )
        return leftTopTrees.union(rightBottomTrees).count
    }

    private static func traversal(
        trees: [[Int]],
        rows: StrideTo<Int>,
        columns: (Int) -> StrideTo<Int>
    ) -> Set<TreePosition> {
        var maxHeight: [Cursor: Int] = [:]
        var visibleTrees: Set<TreePosition> = []
        for row in rows {
            for column in columns(row) {
                if maxHeight[.row(row)] == nil {
                    maxHeight[.row(row)] = trees[row][column]
                }
                if maxHeight[.column(column)] == nil {
                    maxHeight[.column(column)] = trees[row][column]
                }
                if row == 0 || column == 0 || row == trees.count - 1 || column == trees[row].count - 1 {
                    visibleTrees.insert(TreePosition(row: row, column: column))
                    continue
                }
                if trees[row][column] > maxHeight[.row(row)]! || trees[row][column] > maxHeight[.column(column)]! {
                    visibleTrees.insert(TreePosition(row: row, column: column))
                }
                if trees[row][column] > maxHeight[.row(row)]! {
                    maxHeight[.row(row)] = trees[row][column]
                }
                if trees[row][column] > maxHeight[.column(column)]! {
                    maxHeight[.column(column)] = trees[row][column]
                }
            }
        }
        return visibleTrees
    }
}

extension Array {
    subscript<T>(_ tree: TreePosition) -> T where Element == Array<T> {
        self[tree.row][tree.column]
    }
}

enum Part2 {
    static func solution(_ input: String) -> Int {
        let forest = input
            .split(separator: "\n")
            .map { $0.map { Int(String($0))! } }
        var map = Array(
            repeating: Array(repeating: ViewingDistance(), count: forest[0].count),
            count: forest.count
        )
        Measure.start("fill data")
        fillLeftTop(forest: forest, viewingMap: &map)
        fillBottomRight(forest: forest, viewingMap: &map)
        Measure.finish("fill data")
        return map.flatMap { $0 }.map(\.score).max()!
    }

    typealias ViewingMap = [[ViewingDistance]]

    struct ViewingDistance: CustomDebugStringConvertible {
        var left = 0
        var top = 0
        var right = 0
        var bottom = 0

        var score: Int { left * right * top * bottom }
        
        var debugDescription: String {
            "{ left: \(left), top: \(top), right: \(right), bottom: \(bottom) }"
        }
    }
    
    typealias Column = Int
    typealias Row = Int
    
    class TreeHeightCache {
        typealias TreeIndex = Int
        private var indexes: [TreeIndex?]
        private let maxTreeHeight: Int
        
        init(maxTreeHeight: Int) {
            self.maxTreeHeight = maxTreeHeight
            // height values will be [0...9]
            indexes = Array<Column?>(repeating: nil, count: maxTreeHeight + 1)
        }
        
        func addTree(height: Int, index: TreeIndex) {
            indexes[height] = index
        }

        func blockingTreeIndex(height: Int, isReversed: Bool) -> TreeIndex? {
            let indexes = indexes[height...maxTreeHeight].compactMap { $0 }
            return isReversed ? indexes.min() : indexes.max()
        }
    }
    
    static private func fillLeftTop(
        forest: [[Int]],
        viewingMap: inout ViewingMap
    )  {
        var columnsCache: [Column: TreeHeightCache] = Dictionary(
            uniqueKeysWithValues: (0..<forest[0].count)
                .map { ($0, TreeHeightCache(maxTreeHeight: 9)) }
        )
        for row in 0..<forest.count {
            Measure.start("fillLeftTop")
            var rowCache = TreeHeightCache(maxTreeHeight: 9)
            for column in 0..<forest[row].count {
                let position = TreePosition(row: row, column: column)
                let treeHeight = forest[row][column]

                // set left distance for the tree
                let blockingTreeColumn = rowCache.blockingTreeIndex(height: treeHeight, isReversed: false)
                let leftDistance = column - (blockingTreeColumn ?? 0)
                viewingMap[position.row][position.column][keyPath: \.left] = leftDistance

                rowCache.addTree(height: treeHeight, index: column)
                
                // set top distance for the tree
                let blockingTreeRow = columnsCache[column]!.blockingTreeIndex(height: treeHeight, isReversed: false)
                let topDistance = row - (blockingTreeRow ?? 0)
                viewingMap[position.row][position.column][keyPath: \.top] = topDistance

                columnsCache[column]!.addTree(height: treeHeight, index: row)
            }
            Measure.finish("fillLeftTop")
        }
    }
    
    static private func fillBottomRight(
        forest: [[Int]],
        viewingMap: inout ViewingMap
    )  {
        var columnsCache: [Column: TreeHeightCache] = Dictionary(
            uniqueKeysWithValues: (0..<forest[0].count)
                .map { ($0, TreeHeightCache(maxTreeHeight: 9)) }
        )
        for row in (0..<forest.count).reversed() {
            Measure.start("fillBottomRight")
            var rowCache = TreeHeightCache(maxTreeHeight: 9)
            for column in (0..<forest[row].count).reversed() {
                let position = TreePosition(row: row, column: column)
                let treeHeight = forest[row][column]

                // set left distance for the tree
                let blockingTreeColumn = rowCache.blockingTreeIndex(height: treeHeight, isReversed: true)
                let rightDistance = (blockingTreeColumn ?? forest[row].count - 1) - column
                viewingMap[position.row][position.column][keyPath: \.right] = rightDistance

                rowCache.addTree(height: treeHeight, index: column)
                
                // set top distance for the tree
                let blockingTreeRow = columnsCache[column]!.blockingTreeIndex(height: treeHeight, isReversed: true)
                let bottomDistance = (blockingTreeRow ?? forest.count - 1) - row
                viewingMap[position.row][position.column][keyPath: \.bottom] = bottomDistance

                columnsCache[column]!.addTree(height: treeHeight, index: row)
            }
            Measure.finish("fillBottomRight")
        }
    }
}

let input = readInput()
print(Part2.solution(input))
