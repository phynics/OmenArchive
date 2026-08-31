import Foundation
import OmenArchiveKit

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

func usage() {
    print("usage: omen-archive classify <archive-root> <relative-path>")
    print("       omen-archive validate-layout <archive-root>")
    print("       omen-archive validate <archive-root>")
}

let arguments = Array(CommandLine.arguments.dropFirst())
guard let command = arguments.first else {
    usage()
    exit(2)
}

do {
    switch command {
    case "classify":
        guard arguments.count == 3 else {
            usage()
            exit(2)
        }
        let format = try ArchiveFormat(archiveRoot: URL(fileURLWithPath: arguments[1]))
        let classification = try format.classify(arguments[2])
        switch classification.kind {
        case .publication:
            print("publication \(classification.publicationID) \(classification.schema)")
        case .resource(let familyID):
            print("\(familyID) \(classification.publicationID) \(classification.schema)")
        }
    case "validate-layout":
        guard arguments.count == 2 else {
            usage()
            exit(2)
        }
        let format = try ArchiveFormat(archiveRoot: URL(fileURLWithPath: arguments[1]))
        let files = try format.files()
        print("Validated \(files.count) authored file(s)")
    case "validate":
        guard arguments.count == 2 else {
            usage()
            exit(2)
        }
        let format = try ArchiveFormat(archiveRoot: URL(fileURLWithPath: arguments[1]))
        let report = try ArchiveValidator(format: format).validateAll()
        for diagnostic in report.diagnostics {
            let message = "\(diagnostic.relativePath): \(diagnostic.message)\n"
            FileHandle.standardError.write(Data(message.utf8))
        }
        for diagnostic in report.mechanicsDiagnostics {
            let message = "\(diagnostic.relativePath): mechanics [\(diagnostic.kind.rawValue)] \(diagnostic.message)\n"
            FileHandle.standardError.write(Data(message.utf8))
        }
        guard report.isValid else { exit(1) }
        print("Validated \(report.filesValidated) authored file(s)")
    default:
        usage()
        exit(2)
    }
} catch {
    let message = "omen-archive: \(error)\n"
    FileHandle.standardError.write(Data(message.utf8))
    exit(1)
}
