# Svitlana Lorman, third option
This is a repository for the Computer Architecture assembly project.
<ol>
<li> Read N lines from stdin until EOF appears (maximum 10000 lines). </li>
Lines are separated EITHER by the sequence of bytes 0x0D and 0x0A (CR LF), or by a single character - 0x0D or 0x0A.
Each line is a pair "<key> <value>" (separated by a space), where the key is a text identifier with a maximum of 16 characters (any characters except white space chars - space or newline), and the value is a decimal integer in the range [-10000, 10000].
<li> Perform grouping: fill two arrays (or an array of structures with 2 values) to store the pair <key> and <average>, which will include only unique values of <key>, and <average> is the average value calculated for all <value> corresponding to a specific <key>. </li> 
<li> Sort using the merge sort algorithm by <average>, and output the key values to stdout from larger to smaller (average desc), each key on a separate line.</li>

</ol>

<h2>TESTING</h2>
Dosbox-x and dosbox do not work. Thus, jsdos is used in testing.
I input files V3TEST1.IN, V3TEST2.in, V3TEST3.in and the content is transfered to console. Then te code functions and outputes the results.
TESTS ARE PASSED
