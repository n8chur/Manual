import ManualKit

extension Folder {
    static let FixturesName = "fixtures"
    
    func add(fixtures: [Fixture], withPathString pathString: String) throws {
        guard !self.subfolders.contains(where: {$0.name == Folder.FixturesName}) else {
            fatalError("Fixtures subfolder already exists in \(self.name).")
        }
        
        let fixturesFolder = Folder(name: Folder.FixturesName)
        fixturesFolder.files = fixtures
        self.subfolders.append(fixturesFolder)
        
        let fixturePaths = fixturesFolder.files.map {"\(Folder.FixturesName)/\($0.filename)"}
        
        let pathInfo = PathInfo(pathString: pathString, fixturePaths: fixturePaths)
        self.files.append(pathInfo)
    }
}
