#
# read verilog source files for mcac
#
set all_modules [list \
"spi" "spi_defines" "spi_clock_gen" "spi_shift" "spi_defines" \
]

echo ""
echo "Reading Verilog Source Files"
echo ""

foreach this_module $all_modules {
	read_file -format verilog [list [format "%s%s" $this_module ".v"]]
}
