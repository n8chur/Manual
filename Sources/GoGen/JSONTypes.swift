// MARK: - JSONTimeType

struct JSONTimeType: NamedType {
    let name: String
    let timeFormat: String
    let timeParseFormat: String
    let underlyingType = "time.Time"
    let isDefinedInline = false
    
    init(name: String, timeFormat: String, timeParseFormat: String) {
        self.name = name
        self.timeFormat = timeFormat
        self.timeParseFormat = timeParseFormat
    }
    
    var marshalContentLines: [String] {
        return [
            "t := time.Time(o).Format(\(self.timeFormat))",
            // Use '%/q' string formatting to escape unicode characters.
            "return []byte(fmt.Sprintf(\"%+q\", t)), nil",
        ]
    }
    
    var unmarshalContentLines: [String]? {
        return [
            "t, err := time.Parse(\(self.timeParseFormat), string(bytes))",
            "if err != nil ".appendingScopedGoContent([
                "return err",
            ]),
            "*o = \(self.name)(t)",
            "return nil",
        ]
    }
}

extension JSONTimeType: ModuleImportable {
    var importedModules: [String] {
        return [
            "time",
            "fmt",
        ]
    }
}

// MARK: JSONTimeType: Concrete Time Types

extension JSONTimeType {
    static func date() -> JSONTimeType {
        let timeFormat = "\"2006-01-02\""
        let timeParseFormat = "`\(timeFormat)`"
        return self.init(name: "JSONDate", timeFormat: timeFormat, timeParseFormat: timeParseFormat)
    }
    
    static func dateTime() -> JSONTimeType {
        let timeFormat = "time.RFC3339Nano"
        let timeParseFormat = "fmt.Sprintf(\"%+q\", \(timeFormat))"
        return self.init(name: "JSONDateTime", timeFormat: timeFormat, timeParseFormat: timeParseFormat)
    }
}

// MARK: - JSONWeek

struct JSONWeek: NamedType {
    let name = "JSONWeek"
    let underlyingType = "time.Time"
    let isDefinedInline = false
    
    var helperFunctionContentLines: [String] {
        return [
            "func FormatISO8601Week(t time.Time) string ".appendingScopedGoContent([
                "year, week := time.Time(t).ISOWeek()",
                "return fmt.Sprintf(\"%04dW%02d\", year, week)"
            ]),
            "func ParseISO8601Week(str string) (*time.Time, error) ".appendingScopedGoContent([
                "// Must be 7 characters long to match \"0001W01\" format",
                "if len(str) != 7 ".appendingScopedGoContent([
                    "return nil, fmt.Errorf(\"expected week string %+q to be 7 bytes, but got %d\", str, len(str))",
                ]),
                "components := strings.Split(str, \"W\")",
                "if len(components) != 2 ".appendingScopedGoContent([
                    "return nil, fmt.Errorf(\"week string %+q could not be parsed\", str)",
                ]),
                "year, err := strconv.Atoi(components[0])",
                "if err != nil ".appendingScopedGoContent([
                    "return nil, fmt.Errorf(\"year could not be parsed from week string %+q\", str)",
                ]),
                "week, err := strconv.Atoi(components[1])",
                "if err != nil ".appendingScopedGoContent([
                    "return nil, fmt.Errorf(\"week could not be parsed from week string %+q\", str)",
                ]),
                "day := 1",
                "date := time.Date(year, 1, day, 0, 0, 0, 0, time.UTC)",
                "dYear, dWeek := date.ISOWeek()",
                "// Since this could be a week in the year previous, increment the day until we get to the desired week year",
                "for dYear != year && dWeek > 1 ".appendingScopedGoContent([
                    "day++",
                    "date = time.Date(year, 1, day, 0, 0, 0, 0, time.UTC)",
                    "dYear, dWeek = date.ISOWeek()",
                ]),
                "// Find monday of that week",
                "for date.Weekday() > 1 ".appendingScopedGoContent([
                    "day--",
                    "date = time.Date(year, 1, day, 0, 0, 0, 0, time.UTC)",
                ]),
                "// Get the first day of the provided week",
                "date = date.AddDate(0, 0, (week-1)*7)",
                "for date.Year() > year ".appendingScopedGoContent([
                    "date = date.AddDate(0, 0, -7)",
                ]),
                "return &date, nil",
            ])
        ]
    }
    
    var marshalContentLines: [String] {
        return [
            "str := FormatISO8601Week(time.Time(o))",
            "return []byte(fmt.Sprintf(\"%+q\", str)), nil",
        ]
    }
    
    var unmarshalContentLines: [String]? {
        return [
            "str, err := strconv.Unquote(string(bytes))",
            "if err != nil ".appendingScopedGoContent([
                "return err",
            ]),
            "date, err := ParseISO8601Week(str)",
            "if err != nil ".appendingScopedGoContent([
                "return err",
            ]),
            "*o = JSONWeek(*date)",
            "return nil",
        ]
    }
}

extension JSONWeek: ModuleImportable {
    var importedModules: [String] {
        return [
            "time",
            "fmt",
            "strconv",
            "strings",
        ]
    }
}

// MARK: - JSONURLType

struct JSONURLType: NamedType {
    let name = "JSONURL"
    let underlyingType = "url.URL"
    let isDefinedInline = false
    
    var marshalContentLines: [String] {
        return [
            "u := url.URL(o)",
            // Use '%/q' string formatting to escape unicode characters.
            "str := fmt.Sprintf(\"%+q\", u.String())",
            "return []byte(str), nil",
        ]
    }
    
    var unmarshalContentLines: [String]? {
        return [
            "s, err := strconv.Unquote(string(bytes))",
            "if err != nil ".appendingScopedGoContent([
                "return err",
            ]),
            "u, err := url.Parse(s)",
            "if err != nil ".appendingScopedGoContent([
                "return err",
            ]),
            "*o = JSONURL(*u)",
            "return nil",
        ]
    }
}

extension JSONURLType: ModuleImportable {
    var importedModules: [String] {
        return [
            "net/url",
            "fmt",
            "strconv",
        ]
    }
}

// MARK: - File: JSONTypes

extension File {
    static func JSONTypes(withPackageName package: String) -> File {
        return File(filename: "JSONTypes.go", package: package, schemas: [
            .namedType(JSONTimeType.date()),
            .namedType(JSONTimeType.dateTime()),
            .namedType(JSONWeek()),
            .namedType(JSONURLType()),
        ])
    }
}
