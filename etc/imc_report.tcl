load ./cov_work/scope/spi
exec mkdir -p report
exec mkdir -p report/coverage
report -out report/coverage/coverage.rpt -detail -metrics covergroup -all -aspect both -assertionStatus -allAssertionCounters -type *
