inputs: {config, lib, pkgs, ...}:
let 
  inherit (pkgs.stdenv.hostPlatform) system;
  package = inputs.self.packages.${system}.default;
  configDir =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "Library/Application\ Support/Firefox/Profiles/"
    else ".mozilla/firefox/";

  cfg = config.textfox;
in {

  imports = [
    inputs.nur.hmModules.nur

    ./options.nix
  ];

  options.textfox = {
    profile = lib.mkOption {
      type = lib.types.str;
      description = "The profile to apply the textfox configuration to";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      profiles."${cfg.profile}" = {
        extraConfig = builtins.readFile "${package}/user.js";
        extensions = [ config.nur.repos.rycee.firefox-addons.sidebery ];
      };
    };

    home.file."${configDir}${cfg.profile}/chrome" = {
      source = "${package}/chrome";
      recursive = true;
    };
    home.file."${configDir}${cfg.profile}/chrome/config.css" = {
      text = cfg.configCss;
    };
  };
}
