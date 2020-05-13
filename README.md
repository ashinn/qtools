
A suite of tools for easily and scalably processing data in the spirit
of the classic Unix utilities sort, join and grep.  Whereas the
classic utilities work only on TSV files, we also support CSV and
JSON.  Formats are inferred by default, with options to specify
explicitly.

The current implementation in fact simply wraps the underlying Unix
commands, translating fields and reformatting as necessary.  For JSON
support you need the jq command installed, and for CSV the Text::CSV
Perl module.

Note the "q" prefix doesn't stand for anything in particular, mostly
being chosen to avoid conflicts.  You can think of it as standing for
the "quarantine" during which it was written.

Summary:

* qsort [-f [spec1:]field1,[spec2:]field2,...] [sources...]
* qagg [-o op] [-f field1,field2,...] [-e expr] [sources...]
* qjoin [-f field1[=field2]] file1 file2 ...
* qgrep [-f field1,field2,...] [-i] [-v] pattern [sources...]

Commands:

# qsort [-f [spec1:]field1,[spec2:]field2,...] [sources...]

Sorts the sources (default stdin) on the given fields, with successive
fields as secondary sorts.  Any field can be prefixed with a
comparator specifier followed by a colon, where the specifiers are the
same as the single charactor options used in GNU sort(1):

* b - ignore leading blanks
* d - consider only blanks and alphanumeric characters
* f - ignore case
* g - general numeric sort (handles decimals, scientific notation)
* i - consider only printable characters
* M - month sort (JAN < ... < DEC)
* h - compare human readable numbers (e.g. 2K, 1G)
* n - numeric sort
* R - random sort (shuffle)
* V - version sort
* r - reverse the order (can be combined with other specifiers)

e.g. qsort -f name,rn:age

# qagg [-o op] [-f field1,field2,...] [-e expr] [sources...]

Performs an aggregate operation "op" on the values of expr.  If fields
are provided they are used as a grouping and the input is sorted,
otherwise the aggregate is over all data.  The following operations
are defined:

* count - counts the number of records
* sum - sums expr
* avg - computes the arithmetic mean of expr
* median - computes the median expr (non-scalable)
* variance - computes the variance of expr
* stdev - computes the standard deviation of expr
* min - computes the minimum of expr
* max - computes the maximum of expr
* join - concatenates the values (non-scalable)

When joining the additional option "-j <SEP>" is supported.

# qjoin [-f field1[=field2]] file1 file2 ...

Joins the files on equal values of the given field and outputs the
joined results.  If the fields are named differently you can use the
field1=field2 notation.  More than two files can be joined.

# qgrep [-f field1,field2,...] [-i] [-v] pattern [sources...]

Filters only records where pattern matches within any of the specified
fields.  ^ and $ anchors bind to the start and end of the field, not
line, respectively.

# Common Options:

* -x, --format <format>
* -t, --separator <separator>
* -S, --sorted
* -h, --header <header>
* -I, --no-input-header
* -O, --no-output-header

# Header Inference

TSV and CSV files assume an initial header row by default, to enable
named fields instead of fragile position counting.  This header will
be preserved on output and updated as necessary, e.g. combining
multiple fields for qjoin or including the aggregated expression for
qagg.  Several options can be used to change this behavior:

* -h, --header <header>

Explicitly specify the field names, separated by commas.  This
overrides any names in the input.

* -I, --no-input-header

Signifies that there is no header row in the input.  If fields are
referred to be name and this option is provided without explicit -h
headers, then an error is signalled.

* -O, --no-output-header

The default is to always output a header if available (either from the
first row or -h).  If this option is provided, the output header is
omitted.
