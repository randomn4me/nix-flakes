{
  description = "Store present hints";

  outputs = { self, nixpkgs }: {
    defaultPackage.x86_64-linux = self.packages.x86_64-linux.presents;

    packages.x86_64-linux.presents =
      let
        pkgs = import nixpkgs { system = x86_64-linux; };

        my-name = "presents";
        my-script = pkgs.writeShellScriptBin my-name ''
        FILE=$HOME/usr/docs/misc/presents

        usage() {
          echo "Usage: $(basename $0) [saeh]"
          exit 1
        }

        add() {
          local NAME PRESENT CHOICE
          while [ -z "$NAME" ]; do
          read -p "Name: " NAME
          done

          while [ -z "$PRESENT" ]; do
          read -p "Present: " PRESENT
          done

          read -p "Correct? $NAME;$PRESENT [y/N] " CHOICE
          if [ "$CHOICE" = "y" ]; then
          echo "$NAME;$PRESENT" >> $FILE
          else
          exit 1
          fi
        }

        show() {
          column -t -s\; $FILE
        }

        [ ! -f $FILE ] && touch $FILE

        case $1 in
        s*) show ;;
        a*) add ;;
        e*) vim $FILE ;;
        h*) usage ;;
        *) show ;;
        esac

        sort $FILE -o $FILE
        '';
        my-buildInputs = with pkgs; [ vim column coreutils ];
      in pkgs.symlinkJoin {
        name = my-name;
        paths = [ my-script ] ++ my-buildInputs;
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = "wrapProgram $out/bin/${my-name} --prefix PATH : $out/bin";
      };
  };
}
