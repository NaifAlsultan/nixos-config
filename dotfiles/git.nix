{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Naif Alsultan";
        email = "contact@naifalsultan.com";
      };
      pull = {
        rebase = true;
      };
      rerere = {
        enabled = true;
      };
      core = {
        editor = "hx";
      };
      init.defaultBranch = "main";
      # A bare repo planted in ~/remote could run commands through its config.
      safe.bareRepository = "explicit";
    };
  };
}
