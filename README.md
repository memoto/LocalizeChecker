# LocalizeChecker

Tool that scans code for localize key usage and validates it.
Additionally you can attach the appropriate reporting mechanism to see erros or warnings just right in Xcode

## Package contents

Package consists of the following parts:

- Data source
- Parser
- Checker
- Reporter

In fact data flow between modules happens exactly in that order.

## Contribution rules

When contributing to this repository, please first discuss the change with the owners of this repository before making a change in case if there is no task for this.

### Rules
- Do follow [code conventions](https://gitlab.px019.net/mobile/ios/bankios/-/wikis/Code-conventions).
- Do add comments for public types, functions and variables. Documentation will be generated automatically.
- Do write unit tests to ensure that your code works as expected and to prevent breaking changes in the future.
- Don't add the header in source files.

### Merge Requests
Pushing to the main branch of the repository is prohibited. All changes are submitted via merge requests.
Add the owners of the repository as reviewers and wait for at least one approval.

