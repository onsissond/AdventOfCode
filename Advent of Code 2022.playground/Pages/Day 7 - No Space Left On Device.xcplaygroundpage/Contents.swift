/*
 https://adventofcode.com/2022/day/7
 
 https://www.kodeco.com/1053-swift-algorithm-club-swift-tree-data-structure
 */

enum Command: CustomDebugStringConvertible {
    enum CDArg {
        case folderName(String)
        case up
        case root
    }

    case cd(CDArg)
    case ls
    
    var debugDescription: String {
        switch self {
        case .cd(.folderName(let folderName)):
            return "$ cd \(folderName)"
        case .cd(.up):
            return "$ cd .."
        case .cd(.root):
            return "$ cd /"
        case .ls:
            return "$ ls"
        }
    }
}

enum FileType: Equatable, CustomDebugStringConvertible {
    case folder(Folder)
    case file(File)
    
    var debugDescription: String {
        switch self {
        case .folder(let folder):
            return folder.debugDescription
        case .file(let file):
            return file.debugDescription
        }
    }
}
    
struct Folder: Equatable, CustomDebugStringConvertible {
    let name: String
    var size: Int?
    
    var debugDescription: String {
        "dir \(name)"
    }
}

struct File: Equatable, CustomDebugStringConvertible {
    let name: String
    let size: Int
    
    var debugDescription: String {
        "\(size) \(name)"
    }
}

extension Parser where Output == Command {
    static let commandParser = cdCommandParser.or(lsCommandParser)
    
    private static let cdCommandParser = Parser<Command> { input in
        guard input.starts(with: "$ cd ") else { return nil }
        var path = input.dropFirst(5)
        switch path {
        case "/":
            return .cd(.root)
        case "..":
            return .cd(.up)
        default:
            return .cd(.folderName(String(path)))
        }
    }
    
    private static let lsCommandParser = Parser { input in
        guard input == "$ ls" else { return nil }
        return .ls
    }
}

extension Parser where Output == FileType {
    static let fileTypeParser = folderParser.or(fileParser)
    
    private static let folderParser = Parser<FileType> { input in
        guard input.starts(with: "dir ") else { return nil }
        var folderName = input.dropFirst(4)
        return .folder(Folder(name: String(folderName)))
    }
    
    private static let fileParser = Parser<FileType> { input -> FileType? in
        let rawValue = input.split(separator: " ")
        guard let name = rawValue.last.map({ String($0) }) else { return nil }
        guard let size = rawValue.first.flatMap({ Int(String($0)) }) else { return nil }
        return .file(File(name: name, size: size))
    }
}

enum InputLine: CustomDebugStringConvertible {
    case command(Command)
    case fileType(FileType)
    
    var debugDescription: String {
        switch self {
        case .command(let command):
            return "\(command.debugDescription)"
        case .fileType(let fileType):
            return "\(fileType.debugDescription)"
        }
    }
}

extension Parser where Output == InputLine {
    static let inputLineParser =
    Parser<Command>.commandParser.map(InputLine.command)
        .or(Parser<FileType>.fileTypeParser.map(InputLine.fileType))
}

// --------

protocol FileSystemItem {
    var name: String { get }
}

extension Folder: FileSystemItem {}
extension File: FileSystemItem {}
extension Node where Element == FileSystemItem {
    var size: Int {
        if var folder = value as? Folder {
            if let size = folder.size { return size }
            let size = children.map(\.size).reduce(0, +)
            folder.size = size
            self.value = folder
            return size
        }
        if let file = value as? File {
            return file.size
        }
        fatalError("Unknown type")
    }
}

struct FileSystem {
    let root = Node<FileSystemItem>(value: Folder(name: "\\"))
    var cursor: Node<FileSystemItem>
    
    init() {
        cursor = root
    }
    
    mutating func execute(inputLine: InputLine) {
        switch inputLine {
        case .command(let command):
            execute(command: command)
        case .fileType(.folder(let folder)):
            add(item: folder)
        case .fileType(.file(let file)):
            add(item: file)
        }
    }
    
    mutating func execute(command: Command) {
        switch command {
        case .cd(.root):
            cursor = root
        case .cd(.up):
            cursor = cursor.parent!
        case .cd(.folderName(let name)):
            guard let folder = cursor.children.first(where: { $0.value.name == name }) else {
                let folder = Folder(name: name)
                let node = add(item: folder)
                cursor = node
                return
            }
            cursor = folder
        case .ls:
            break
        }
    }
    
    @discardableResult
    func add(item: FileSystemItem) -> Node<FileSystemItem> {
        let node = Node(value: item)
        cursor.add(child: node)
        return node
    }
}

func solutionPart1(input: String) -> Int {
    let lines = input.split(separator: "\n")
        .map { Parser<InputLine>.inputLineParser.parse(String($0))! }
    var fileSystem = FileSystem()
    lines.forEach { fileSystem.execute(inputLine: $0) }
    let result = fileSystem.root.items
        .filter { $0.value is Folder }
        .map { $0.size }
        .filter { $0 < 100000 }
        .reduce(0, +)
    return result
}

func solutionPart2(input: String) -> Int {
    let diskSpace = 70000000
    let updateSize = 30000000
    
    let lines = input.split(separator: "\n")
        .map { Parser<InputLine>.inputLineParser.parse(String($0))! }
    
    var fileSystem = FileSystem()
    lines.forEach { fileSystem.execute(inputLine: $0) }
    let sizes = fileSystem.root.items
        .filter { $0.value is Folder }
        .map { $0.size }
        .sorted(by: >)
    
    let sizeToRemoveFile = updateSize - (diskSpace - sizes.first!)

    var left = 0
    var right = sizes.count - 1
    while left < right {
        let mid = left + (right - left) / 2
        if sizes[mid] >= sizeToRemoveFile && sizes[mid + 1] < sizeToRemoveFile {
            return sizes[mid]
        } else if sizes[mid] > sizeToRemoveFile {
            left = mid + 1
        } else {
            right = mid
        }
    }
    
    return 0
}

let input = readInput()
solutionPart1(input: input)
solutionPart2(input: input)
