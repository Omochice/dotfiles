{ source, tree-sitter }:
tree-sitter.buildGrammar {
  language = "moonbit";
  inherit (source) version src;
}
