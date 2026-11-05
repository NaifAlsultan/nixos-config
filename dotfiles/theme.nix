# Ayu Mirage colours, as hex without the leading '#'.
rec {
  background = "1f2430";
  backgroundAlt = "212733";
  surface = "323844";
  foreground = "cbccc6";
  muted = "686868";
  white = "ffffff";
  accent = "60b8d6";
  yellow = "fdcc60";
  red = "f08778";

  # Terminal colours 0-15.
  ansi = [
    backgroundAlt
    red
    "53bf97"
    yellow
    accent
    "ec7171"
    "98e6ca"
    "fafafa"
    muted
    "f58c7d"
    "58c49c"
    "ffd165"
    "65bddb"
    "f17676"
    "9debcf"
    white
  ];
}
