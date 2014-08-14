Launcher for NetIQ Validator v0.9.1

download url:  https://iam.is4it.de/public/download/ValidatorLauncher.zip
home page url: http://www.is4it.de/en/solution/identity-access-management/
source code:   https://github.com/NetIQValidator/ValidatorScripts/tree/master/ValidatorLauncher
license:       Mozilla Public License v2.0

NetIQ Validator comes with launch scripts for all supported platforms (Linux/Mac/Windows) but those are console mode shell scripts and offer not much comfort. The Launcher for NetIQ Validator is a drop-in replacement for the standard Windows script "runValidator.bat" that replaces the validator server console windows with a tray menu icon and (by default) auto-launches the validator client page. From the tray menu you can

- show/hide the server console
- open the validator client webpage
- open the validator runner webpage
- customize the tests folder
- disable autostart of the validator client
- choose your preferred browser
- enforce use of your custom license file
- enable debug mode

To install, just copy validator.exe into the same folder where you find runValidator.bat and run it. If you change any of the preferences from the default values, they will be saved to a validator.ini file in the same folder.

If you buy a validator license you'll receive a license.dat file that you need to copy into the config subfolder of your validator install. Since the validator download comes with an evaluation license file as well this will most likely overwrite your copy during an update. So simply keep your custom license somewhere in a safe place outside the install folder and point the Launcher to it - it will copy the license.dat into the right place on the fly.

This launcher has been developed for and tested with NetIQ Validator v1.1 and v1.2 (release versions) and v1.3.b1035 (beta 2).