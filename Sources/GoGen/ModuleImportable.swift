protocol ModuleImportable {
    var importedModules: [String] { get }
}

extension ModuleImportable {
    var importedModules: [String] {
        return []
    }
}
