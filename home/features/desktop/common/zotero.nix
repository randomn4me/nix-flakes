{ pkgs, ... }:
{
    home.packages = with pkgs; [ zotero ];

    systemd.user.services.zotero = {
        Unit.Description = "zotero";
        Service.ExecStart = "${pkgs.zotero}/bin/zotero --headless";
        Install.WantedBy = [ "default.target" ];
    };

}

