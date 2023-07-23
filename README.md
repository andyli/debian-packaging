# debian-packaging

A VSCode devcontainer setup for Debian/Ubuntu packaging.

# Setup after starting the devcontainer

 * create `.envrc`, replace the values as appropriate
    ```sh
    export DEBEMAIL='andy@onthewings.net'
    export DEBFULLNAME='Andy Li'
    ```
 * `mk-sbuild unstable`
 * `git config --global --add safe.directory '*'` to avoid `git`/`gbp` triggering `fatal: detected dubious ownership in repository`

# Update sbuild

```sh
sudo sbuild-update unstable
sudo sbuild-update --upgrade unstable
```

# Updating the Haxe package

 1. `cd projects`

 2. `git clone git@github.com:HaxeFoundation/haxe-debian.git`

 3. `cd haxe`

 4. update `debian/changelog` with `dch`, particularly the new version string `1:x.x.x-1`

 5. get source archive `./debian/rules get-orig-source` for new versions

 6. `git stash` to store the changelog change, keep the git status clean for `gbp`

 7. make sure there is a local `upstream` branch and it's up-to-date

 8. `gbp import-orig ../haxe_*.orig.tar.gz`

 9. `git stash pop`

 10. modify files under `debian` as needed

 11. `sbuild .`

 12. when everything is fine, build and sign the package with `sbuild . -k $KEYFINGERPRING`, where the 40-character `$KEYFINGERPRING` can be found by `gpg --list-keys`

 13. `dput ../haxe_*_source.changes`

 14. `git commit`, `git tag debian/...`, `git push --all`, `git push --tags`

# Updating a typical OCaml lib package

 1. `cd projects`

 2. `git clone git@salsa.debian.org:ocaml-team/$LIBNAME.git`

 3. `cd $LIBNAME`

 4. `uscan` to get source archive

 5. `gbp import-orig --pristine-tar ../$LIBNAME_*.orig.tar.gz`

 6. modify files under `debian` as needed

 7. `sbuild .`

 8. when everything is fine, build and sign the package with `sbuild . -k $KEYFINGERPRING`, where the 40-character `$KEYFINGERPRING` can be found by `gpg --list-keys`

 9. `dput ../$LIBNAME_*_source.changes`

 10. `git commit`, `git tag debian/...`, `git push --all`, `git push --tags`

# Building an existing version of the Haxe package

Similar to the above, but download source archive `haxe_*.orig.tar.gz` from https://deb.debian.org/debian/pool/main/h/haxe/

# Patching

https://wiki.debian.org/UsingQuilt
