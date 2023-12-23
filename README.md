# Iw5-Survival-Public
This is the new repo for my Iw5 Survival Mod for Plutonium Iw5. Incudes Server/Private match files, as well as Client Files for servers.
Both Private Match and Server Guides are Below.

# Install: (Private Match)
* Download Zip
* Open the *Server-Private_Match* folder
  * Move the *iw5_survival* folder into your mod folder *%localappdata%\Plutonim\storage\iw5\mods* you may have to make the mods folder if you do not have any installed mods
  * Launch the game
    * ON THE MAIN SCREEN!! Press the *~* key to open the consle.
       * Type in *fs_game iw5_survival*
          * Press Private Match, and choose one of the following maps
              Supported Maps:
                Dome
                Seatown
                Resistance
                Interchange
                Village
                Mission
                Carbon
                NukeTown

# Playing With Freinds: (Private Match Only)
* If you wish for freids to join you, have them download the zip, and install the *Cleint* files,
  * Then have them set their *fs_game* to *iw5_survival* and then they may join you.



# Install: (Server)
* Downlaod zip file
* Open the *Server-Private_Match* folder
  * Move the *iw5_survival* folder into your servers mod folder
* Create a FastDL dir for your server
    * Open the *Client* folder
      * Move the *iw5_survival* folder into your FastDL dir 
      (if you use your servers mod folder for FastDL, make a new folder called *client* then make a *mods* folder inside that, and move the *iw5_survival* folder inside that mods           folder, and set your FastDL link to something like this **192.168.1.1/mods/cleint/mods/**)
* Edit Your servers CFG to be set to *war* gamemode (I lost my dsr file, but TDM works) 
  * Set the max players to 4, This version of the mod only supports 4 players for now
  * Make sure FastDL is set up
  * Edit your map Rotaion to the any of the Following maps (not all are added yet, any non supported map will result in no buy stations) 
    Supported Maps:
      Dome
      Seatown
      Resistance
      Interchange
      Village
      Mission
      Carbon
      NukeTown

* Edit your server.bat file, and the *fs_game* or mod, to *iw5_survival* 
* Launch your server, and test the client files are downloading correctly, using server files for FastDL may result in bugs on the cleint side
* THERE WILL BE CONSOLE ERRORS!!!


# THERE IS BUGS:
  * Sometimes on a map rotate the mod breaks, and the AI wont progress waves, this doesnt normally happen unless playing solo on a server for a long time
  * There is NO AI re-skins, sucide bombers are a fucking surprise, thats for sure.
  * Sometimes waves past wave 10 crash the server, I think its due to the JUG code not loading correclty.
  * dying is litterly fucking half ass coded and broken, you can stright change teams while dead, dont do this, it will fuck up waves.

# Known Issues:
   * Yes buy stations were never compleated, the weapons armory is the only thing that is near done. 
   * Yes kill streaks will be enabled...however when I find the DSR file for the mod it will fix that.
   * Not all prices are right
   * Yes buy-able kill streaks gives you like 30 of the one streak...no fucking clue why
   * Yes this mod was made mostly when I was running on no sleep, sorry for all the broken shit, 2.0 is in the works and well...back to the coding board

# Thanks To: 
  * Swifty: for alot of code revision and re-wirtes
  * Soliderror: for the idea of the mod and inspiring other mod creators showing that online survival is possible and making the shit code in the first place.
  * Ball: Just for being here and testing shit...you are still usless in my eyes
  * ZechReaper (yes ik its spelled diffrent): Thanks for all the help when I got stuck on simple ass syntax errors...because GSC
