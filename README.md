# debian-packaging

A VSCode devcontainer setup for Debian/Ubuntu packaging.

# Setup after starting the devcontainer

 * `mk-sbuild unstable`
 * create `.envrc`
    ```sh
    export DEBEMAIL='andy@onthewings.net'
    export DEBFULLNAME='Andy Li'
    ```

# Updating the Haxe package

 1. `cd projects`

 2. `git clone git@github.com:HaxeFoundation/haxe-debian.git`

 3. `cd haxe`

 4. update `debian/changelog` with `dch`, particularly the new version string `1:x.x.x-1`

 5. get source archive `./debian/rules get-orig-source` for new versions

 6. `git stash` to store the changelog change, keep the git status clean for `gbp`

 7. make sure there is a local `upstream` branch and it's up-to-date

 8. `git config --global --add safe.directory $(pwd)` to avoid `gbp` triggering `fatal: detected dubious ownership in repository`

 9. `gbp import-orig ../haxe_*.orig.tar.gz`

 10. `git stash pop`

 11. modify files under `debian` as needed

 11. `sbuild .`

 12. ...

# Building an existing version of the Haxe package

Similar to the above, but download source archive `haxe_*.orig.tar.gz` from https://deb.debian.org/debian/pool/main/h/haxe/
