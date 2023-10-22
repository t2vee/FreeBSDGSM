<p align="center">
	<a href="https://linuxgsm.com"><img src="https://cdn.t2v.city/content/vSKyC7YoiXXpaUMHd76H/freebsdgsm.sh/freebsdgsmv2.webp" alt="LinuxGSM">
	<img src="https://img.shields.io/badge/got-badges!_:)_>>-red">
	<a href="https://developer.valvesoftware.com/wiki/SteamCMD"><img src="https://img.shields.io/badge/SteamCMD-000000?style=flat-square&amp;logo=Steam&amp;logoColor=white" alt="SteamCMD"></a>
	<a href="https://github.com/t2vee/FreeBSDGSM/blob/main/LICENSE_lgsm"><img alt="Static Badge" src="https://img.shields.io/badge/LinuxGSM_license-MIT-lime?style=flat-square&logo=gpl"></a>
	<a href="https://github.com/t2vee/FreeBSDGSM/blob/main/LICENSE_fbsdgsm"><img alt="Static Badge" src="https://img.shields.io/badge/FreeBSDGSM_license-GPLv3-darkred?style=flat-square&logo=gpl"></a>
</p>

**[FreeBSDGSM](https://freebsdgsm.sh) is the LinuxGSM compatibility project for FreeBSD and other BSD based distros**

## Very Much Alphabeta

This adaptation is mega jank and a very work in progress. Stuff **will** break. But progress is constantly being made, so keep hopes high!

## 🤔 But why? You may ask
In reality there really isnt much use to a project like this. To get LinuxGSM to run on freebsd, all you have to do is install bash and change a few apt commands to pkg... BUT, wheres the fun in that! 
Its also a learning oppotunity for me since I dont actually have that much experience with bash scripting so converting it to sh is fun 👍

## 🛠 Compatibility

FreeBSDGSM ironically is mainly tested on hardenedbsd and provides the most compatibility for it.
But should work on anything similar.

-   <span><img src="https://cdn.t2v.city/content/vSKyC7YoiXXpaUMHd76H/freebsdgsm.sh/300px-Freebsd.webp" width="15" height="15"></span> FreeBSD
-   <span><img src="https://cdn.t2v.city/content/vSKyC7YoiXXpaUMHd76H/freebsdgsm.sh/HardenedBSD.svg-1.webp" width="15" height="15"></span> HardenedBSD
-   <span><img src="https://cdn.t2v.city/content/vSKyC7YoiXXpaUMHd76H/freebsdgsm.sh/MidnightBSDLogo.svg.webp" width="15" height="15"></span> Any FreeBSD based distros (e.g MidnightBSD)

## ❗❗ Requirements

- pkg
- some form of root access (only for dependency installation) e.g:
  - doas (sudo is **NOT** supported)
  - root user
  - simply having access to the pkg command itself
- thats it lol. **_you dont even need bash_**

## 🤓 Documentation

operation is pretty much the same as linuxgsm just using bsd/posix command syntax.
HIGHLY recommend running fbsdgsm under some form of containerisation.
bsdpot is [officially supported](https://github.com/t2vee/freebsdgsm-pot) and **can** be a lot more stable then running "bare metal"

## 👉👈 Support

no support just yet. basically if you have issues or problems its best to use github issues.
if you have vulnerability concerns and dont feel it can be public dont hesitate to [email me](mailto:me@t2v.ch)

## 😍 Sponsor
i dont deserve it just yet (or ever)

