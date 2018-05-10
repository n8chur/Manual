# Manual

Manual generates unit test fixtures and Go model objects from an [OpenAPI 2.0](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/2.0.md) spec.

See [Example](Example) folder for an example of an input spec and output test fixtures / Go models.

## Why is this awesome?

This tool enables teams to keep their API in sync between servers and clients by using a single source of truth. This is acheived by having a server utilize generated Go model objects and clients write unit tests against the generated test fixtures.

When using this tool it is recommended that the team keeps a repository where the spec, the generated fixtures, and generated Go model objects can reside which is reviewed by all teams. The mobile clients only need to import the test fixtures while the server engineers only need to import the Go model package.

Manual supports unique OpenAPI 2.0 features like:
- abstract model schemas (genreated as interfaces in Go) using `x-abstract` (`true`/`false`)
- representing polymorphism using the [discriminator](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/2.0.md#schema-object) and `x-abstract`
- nullability using `x-nullable`
- specs with external file refrences to model schemas

You can use [ManualReaderObjC](https://github.com/Automatic/ManualReaderObjC) to easily manage your generated fixtures in your iOS project. [ManualReaderObjC](https://github.com/Automatic/ManualReaderObjC) makes it easy to stub requests/reponses, parse fixtures into a type safe object, and pull out JSON examples of defined objects to test model object parsing in your unit tests.

## Usage

Print the usage description.

```bash
$ manual --help
Usage:
  manual -i [input] [flags]

Flags:
  -f, --fixtures string         Generates test fixtures in the provided output directory.
  -g, --go-models string        Generates Go models in the provided output directory.
  -p, --go-package-name string  Specifies the name of the generated Go package. Defaults to Go models\' output directory name.
  -i, --input string            The input Swagger JSON specification file. (required)
```

Generate test fixtures and Go models using an OpenAPI 2.0 spec as an input.

```bash
$ manual --input "~/api/spec/index.json" --fixtures "~/api/gen_files/fixtures" --go-models "~/api/gen_files/models"
```

### Prerequisites

You'll need MacOS 10.13+ (High Sierra) and to have the Xcode 9.2+ command line tools installed.

### Installing

#### [Mint](https://github.com/yonaskolb/mint)
```
$ mint run Automatic/Manual
```

#### Make
```bash
$ make
```

### Usage

```bash
$ manual --help
```

## Running the tests

Tests must be run on macOS 10.13 (High Sierra) since the validation JSON fixtures are generated with [.sortedKeys](https://developer.apple.com/documentation/foundation/jsonencoder.outputformatting/2919670-sortedkeys) which is only supported by macOS 10.13 (High Sierra).

```bash
$ make test
```

### Lint

```
$ make lint
```

## Built With

* [SwaggerParser](https://github.com/AttilaTheFun/SwaggerParser) - OpenAPI spec parser in Swift (currently using [a fork](https://github.com/automatic/SwaggerParser/tree/separated) that supports separated spec files)
* [Guaka](https://github.com/nsomar/Guaka) - POSIX compliant CLI framework for Swift

## Contributing

Fork the repository and and open a pull request to the master branch.

Please report any issues found on Github in the issues section.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/Automatic/Manual/tags).

## Acknowledgments

* @AttilaTheFun for [SwaggerParser](https://github.com/AttilaTheFun/SwaggerParser)
