# LocalizeChecker

Linter that scans code for localize key usage and validates it.
Additionally you can attach the appropriate reporting mechanism to see erros or warnings just right in Xcode

## Installation

### Swift Package Manager

```swift
.package(url: "https://github.com/memoto/LocalizeChecker.git, from: "0.1.6")
```

## Usage

### As SPM executable

Suppose you're located in the package root directory
```bash
swift run -c release \
    LocalizeCheckerCLI check-localize \
    --sources-directory $SOURCES_PATH \
    --localized-bundle-path "$LOCALIZATION_RESOURCES_PATH/de.lproj" \
    --strictlicity warning
```

## Package contents

Package consists of the following parts:

- Data source
- Parser
- Checker
- Reporter

In fact data flow between modules happens exactly in that order.

## [Contributing](CONTRIBUTING.md)
