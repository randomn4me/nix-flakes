{ pkgs, ... }:
{
    home.packages = with pkgs; [ zotero ];

    systemd.user.services.zotero = {
        Unit.Description = "zotero";
        ServiceExecStart = "${pkgs.zotero}/bin/zotero --headless";
        Install.WantedBy = [ "default.target" ];
    };

}

