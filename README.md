# antigravity-ide.tar.gz-2-deb-install
Converts "Antigravity IDE.tar.gz" to .deb Debian/Ubuntu install

The script download antigravity-ide from https://antigravity.google/download and creates a .deb package.

1. Create the .deb package:

```bash
./build_antigravity_deb.sh
```

2. Install the .deb package:

```bash
sudo dpkg -i antigravity-ide_2.0.3_amd64.deb
``` 

3. Uninstall antigravity-ide

```bash
sudo apt remove antigravity-ide
```

4. Remove antigravity-ide completely

```bash
sudo dpkg --purge antigravity-ide
sudo apt autoremove
``` 