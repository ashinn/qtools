#!/bin/bash

PASSED=0
FAILED=0

function check() {
   expected="$1"
   shift
   if ! [ -f "$expected" ]; then
       tmp=$(mktemp)
       cat "$expected" > "$tmp"
       expected="$tmp"
   fi
   actual=$("$@")
   if diff -q "$expected" - <<<"$actual" 2>&1 >/dev/null; then
       echo $'\e[32m'"✓ $@"$'\e[39m'
       PASSED=$((PASSED + 1))
   else
       echo $'\e[31m'"✗ $@"$'\e[39m'
       diff -Naur "$expected" - <<<"$actual" 2>&1 | awk '{print "  " $0}'
       FAILED=$((FAILED + 1))
   fi
   if [ -f "$tmp" ]; then
       rm -f "$tmp"
   fi
}

function finish() {
    echo "$PASSED / $((PASSED + FAILED)) tests passed ($((100*PASSED/(PASSED+FAILED)))%)"
}
trap finish EXIT

check test/data/state-pop-sort.tsv \
      qsort -f state,g:2018_estimate test/data/cities.tsv

check <(tail -n +2 test/data/state-pop-sort.tsv) \
      qsort -O -f state,g:2018_estimate test/data/cities.tsv

check test/data/year-of-the-people.csv \
      qsort -f first_name,last_name test/data/people-of-the-year.csv

check test/data/nobel-prize-by-cat.json \
      qsort -f category,rn:year test/data/nobel-prize.json

check test/data/state-population.tsv \
      qagg -f state -e 2018_estimate test/data/cities.tsv

check test/data/state-averages.tsv \
      qagg -o avg -f state -e 2018_estimate,2016_sqmi,2016_pop_per_sqmi test/data/cities.tsv

check test/data/people-counts.csv \
      qagg -o count -f first_name,last_name -e year test/data/people-of-the-year.csv

check test/data/nobel-prizes-by-year.json \
      qagg -o count -f category -e year test/data/nobel-prize.json

check test/data/employee_departments.tsv \
      qjoin -f DepartmentId test/data/employees.tsv test/data/departments.tsv

check test/data/employee_full.tsv \
      qjoin -f DepartmentId test/data/employees.tsv test/data/departments.tsv test/data/department_budgets.tsv

check test/data/employee_departments.json \
      qjoin -f DepartmentId test/data/employees.json test/data/departments.json

check test/data/johns.csv \
      qgrep -f first_name,last_name John test/data/people-of-the-year.csv

check test/data/nobel-prize-james.json \
      qgrep -f 'laureates[0].firstname' James test/data/nobel-prize.json
