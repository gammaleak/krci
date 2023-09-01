# ARCHIVED
This codebase is now unmaintained and archived for posterity only.

# Kujata Reborn Client Installer.
Windows 10 version 10.0.19041 (aka “version 2004”, aka May 2020 Update) is required for the automated installer.

Download the automated installer: [Download](https://sleeplessknightz.net/index.php/s/8ACMyv4M0nT2b9R/download)

The automated installer guides you through a list of options for installing the game client. After you have made your selections, it downloads all the necessary files and options you chose and installs them. Please be aware that a minimum download is over 7GB.

### Known Issues:

Sometimes the game client will refuse to launch after installation. The problem is intermittent and precisely what causes it is not understood. However, usually it can be fixed by launching the SquareEnix PlayOnline Viewer and perform a “Check Files.” To do that, follow these steps:

1. Go to the directory where you installed the client and find the ..\SquareEnix\PlayOnlineViewer folder. Inside that folder, rename pol.exe to pol-modified.exe
2. Inside that same folder, rename pol-modified.exe to pol.exe
3. Run pol.exe and let it self-update.
4. After the self-update is finished, open pol.exe
5. At the main menu choose Existing User and use 1234ABCD as the “playonline member ID” – nothing else matters. You can name it “fake” or “dummy” and use no password.
6. On the left side of the screen click Check Files
7. On the next screen where it says “PlayOnlineViewer” click the two arrows and change it to “Final Fantasy XI”. The “version” should be “UNKNOWN”. If you can’t change that item to “Final Fantasy XI” something else has gone wrong and this method won’t work for you. Please try our manual installation steps.
8. Click on the Check Files button
9. PlayOnline will then check all the FINAL FANTASY XI files (usually takes about 15-20 minutes) and prompt you on what to do because it found errors.
10. You should then choose to fix the errors. They are errors after all and need to be fixed.
11. PlayOnline will then automatically start checking and updating files. Depending on your internet connection this may take some time. Once it starts downloading you can leave it unattentended if you wish to do so.
12. Once the update is finished, close the PlayOnline Viewer.
13. Back in the PlayOnline Viewer directory, rename pol.exe to pol-original.exe
14. Rename pol-modified.exe to pol.exe
15. Open your chosen launcher (Windower or Ashita) and try to connect to Kujata Reborn again. This time, it should work.
