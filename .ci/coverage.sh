#!/bin/sh

PROF_DATA=".build/debug/codecov/default.profdata"
XCTESTS=".build/debug/${FRAMEWORK_NAME}PackageTests.xctest/Contents/MacOS/${FRAMEWORK_NAME}PackageTests"
IGNORE_REGEX='checkouts|Tests'
xcrun llvm-cov export -format="lcov" --ignore-filename-regex=$IGNORE_REGEX $XCTESTS --instr-profile $PROF_DATA > info.lcov

echo "size: $(wc -c info.lcov)"

lcov_cobertura info.lcov
COVERAGE_DEC=$(xmlstarlet sel -t -v "number(//coverage/@line-rate)" coverage.xml  2>log.info)
COVERAGE_PCT=$(echo "100 * $COVERAGE_DEC" | bc)
printf "gitlab-coverage %s%%\n" "$COVERAGE_PCT"
