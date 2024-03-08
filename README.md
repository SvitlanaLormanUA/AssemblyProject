# Svitlana Lorman, third option
This a repository for the Computer Architecture assembly project.

1) Read N lines from stdin until EOF appears (maximum 10000 lines).
Lines are separated EITHER by the sequence of bytes 0x0D and 0x0A (CR LF), or by a single character - 0x0D or 0x0A.
Each line is a pair "<key> <value>" (separated by a space), where the key is a text identifier with a maximum of 16 characters (any characters except white space chars - space or newline), and the value is a decimal integer in the range [-10000, 10000].
2) Perform grouping: fill two arrays (or an array of structures with 2 values) to store the pair <key> and <average>, which will include only unique values of <key>, and <average> is the average value calculated for all <value> corresponding to a specific <key>.
3) Sort using the merge sort algorithm by <average>, and output the key values to stdout from larger to smaller (average desc), each key on a separate line."
