# debian-packaging

A VSCode devcontainer setup for Debian/Ubuntu packaging.

# WSL config

If WSL is used, make sure gpg works.

```
echo "test" | gpg --clearsign
```

https://www.39digits.com/signed-git-commits-on-wsl2-using-visual-studio-code

# Setup after starting the devcontainer

 * update `.devcontainer/timezone` to your local timezone, if wanted
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

 3. `cd haxe-debian`

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

[`gbp export-orig`](https://manpages.debian.org/unstable/git-buildpackage/gbp-export-orig.1.en.html) can also generate the source archive from git repo.

# Patching

https://wiki.debian.org/UsingQuilt


# backportpackage

https://manpages.debian.org/unstable/ubuntu-dev-tools/backportpackage.1.en.html

```sh
# $SOURCE and $DEST should be release code names
# Debian: https://www.debian.org/releases/
# Ubuntu: https://wiki.ubuntu.com/Releases
export SOURCE=unstable
export DEST=jammy
# $PPA should be a host name defined in .devcontainer/dput.cf
export PPA=onthewings-ocaml

# edit .devcontainer/.sbuildrc if needed:
# - set $extra_repositories to use ubuntu backports and/or PPA
# - set $force_orig_source = 1 if it's a new version

mk-sbuild $DEST
backportpackage --source=$SOURCE --destination=$DEST --release-pocket --build --upload=$PPA
```
