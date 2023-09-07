# JuxtaCode Integration

Swift API to launch [JuxtaCode's](https://juxtacode.app) diff tool and merge tool UIs.

#### To compare 2 changesets:
```swift
let repo = URL(filePath: "/path/to/repository")

try await DiffTool.compare("main", and: "feature", in: repo)
```

#### To open a merge tool:
```swift
let conflictedFile = URL(filePath: "/path/to/conflicted/file.txt")
let repo = URL(filePath: "/path/to/repository")

let result = try await MergeTool.open(conflictedFile, in: repo)
```
---

This package does not make use of JuxtaCode's command line tool and doesn't require the user to have it installed.

The [SampleClient](SampleClient/) project demonstrates how the API can be used.
