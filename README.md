# fix-helium-drm-plz
![huh](https://i.giphy.com/GRk3GLfzduq1NtfGt5.webp)

## wtf is this
Helium browser is great but its DRM support is... not. This script yoinks the Widevine CDM from the latest stable Chrome `.deb`, extracts it, and shoves it into your Helium install directory so you can actually watch and listen to shit.

It auto-detects where Helium lives on your system, and if you've somehow got multiple installs it'll fix all of them. You're welcome.

## how to run this shit

### prerequisites
- `curl`, `wget`, `ar`, and `tar` (you probably already have these)
- `sudo` access (the script will ask nicely...)

### the easy way
```bash
git clone https://github.com/your-user/fix-helium-drm-plz.git
cd fix-helium-drm-plz
chmod +x fixdrmplz.sh
./fixdrmplz.sh
```

### the lazy way
```bash
curl -s https://raw.githubusercontent.com/tuibird/fix-helium-drm-plz/main/fixdrmplz.sh | sh
```

### after it runs
1. Close Helium completely (yes, ALL the windows)
2. Reopen Helium
3. Check `chrome://components` - Widevine should be there now
4. If it still doesn't work, try restarting your PC dingus
5. Honestly just keep restarting, it might not doing anything but it'll make me warm and fuzzy inside.

## known helium locations
The script checks these paths automatically:
| Distro | Path |
|--------|------|
| Fedora | `/usr/share/helium` |
| CachyOS | `/opt/helium-browser-bin` |

If you have a weird ass vegan OS with some strange Helium path, Spam me on discord with it or make an issue on the github and I'll get you sorted.

## tested on
- Fedora 43
- CachyOS

"it works on my system 🤣" -probably you in 5 minutes
