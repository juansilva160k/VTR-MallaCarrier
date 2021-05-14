BEGIN {
  FS=";"
  OFS=""
  archivo = ARGV[1]
}
{
  print archivo,"-"NR"-"$1,";"$2";"$3
}
END {
  print ""
}
