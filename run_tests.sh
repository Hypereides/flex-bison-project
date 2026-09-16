#!/bin/sh
# Runs every file in tests/ and checks it gives the expected outcome.
#
#   exit 0 = SUCCESS (correct program)
#   exit 2 = lexical or syntax error
#   exit 3 = semantic error(s)
#
# Usage:  ./run_tests.sh            run all tests, print PASS/FAIL per file
#         ./run_tests.sh -v         also print the full parser output
#         ./run_tests.sh 24         run only the test(s) whose name contains "24"

PARSER=./myParser.exe
VERBOSE=0
FILTER=""
for a in "$@"; do
    case "$a" in
        -v) VERBOSE=1 ;;
        *)  FILTER="$a" ;;
    esac
done

[ -x "$PARSER" ] || { echo "myParser.exe not built - run 'make' first"; exit 1; }

# expected exit code for each test file
expected() {
    case "$1" in
        00_endeiktiko_paradeigma_autousio.sql) echo 3 ;;  # column missing its alias
        00b_*|0[1-9]_ok_*)                     echo 0 ;;
        1[0-9]_err_*)                          echo 2 ;;  # lexical / syntax
        [23][0-9]_err_*)                       echo 3 ;;  # semantic
        *)                                     echo "?" ;;
    esac
}

pass=0; fail=0; unknown=0
for f in tests/*.sql; do
    b=$(basename "$f")
    case "$b" in *"$FILTER"*) ;; *) continue ;; esac

    exp=$(expected "$b")
    out=$("$PARSER" "$f" 2>&1); got=$?
    verdict=$(printf '%s\n' "$out" | grep -E '^(SUCCESS|FAILURE)' | head -1)
    ndiag=$(printf '%s\n' "$out" | grep -c '^\*\*\* ')

    if [ "$exp" = "?" ]; then
        printf '  ??  %-42s exit %s  (no expectation recorded)\n' "$b" "$got"
        unknown=$((unknown+1))
    elif [ "$got" = "$exp" ]; then
        printf 'PASS  %-42s exit %s  %s diagnostic(s)\n' "$b" "$got" "$ndiag"
        pass=$((pass+1))
    else
        printf 'FAIL  %-42s expected exit %s, got %s\n' "$b" "$exp" "$got"
        printf '      %s\n' "$verdict"
        fail=$((fail+1))
    fi

    if [ "$VERBOSE" = 1 ]; then
        printf '%s\n' "$out" | sed 's/^/      | /'
        echo
    fi
done

echo "--------------------------------------------------------------"
echo "$pass passed, $fail failed, $unknown without expectation"
[ "$fail" -eq 0 ]
