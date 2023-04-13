# debian-packaging

A VSCode devcontainer setup for Debian/Ubuntu packaging.

# Setup sbuild

 1. `mk-sbuild unstable`

# Setup env

 1. create `.envrc`
    ```sh
    export DEBEMAIL='andy@onthewings.net'
    export DEBFULLNAME='Andy Li'
    ```

# Updating the Haxe package

 1. `cd projects`

 2. `git clone git@github.com:HaxeFoundation/haxe-debian.git`

 3. `cd haxe`

 4. update `debian/changelog` with `dch`, particularly the new version string `1:x.x.x-1`

 5. get source archive
    - `./debian/rules get-orig-source` for new versions, or
    - download `haxe_*.orig.tar.gz` from https://deb.debian.org/debian/pool/main/h/haxe/

 6. `sbuild .`

 7. ...
