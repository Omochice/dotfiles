{
  runCommand,
  nkf,
  skkDictionaries,
}:
# nskk has no option for the dictionary coding and misdetects the EUC-JP original.
runCommand "skk-jisyo-l-utf8" { nativeBuildInputs = [ nkf ]; } ''
  nkf -w ${skkDictionaries.l}/share/skk/SKK-JISYO.L > $out
''
