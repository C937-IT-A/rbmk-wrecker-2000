**INSTALLATION**
1. Via Internet (must have internet card)
     - Run ``wget -f https://raw.githubusercontent.com/C937-IT-A/rbmk-wrecker-2000/refs/heads/main/rbmk.lua /rbmk/rbmk.lua;wget -f https://raw.githubusercontent.com/C937-IT-A/rbmk-wrecker-2000/refs/heads/main/rbmkTorchMan.lua /rbmk/rbmkTorchMan.lua;/rbmk/rbmkTorchMan``

     - Automatically installs both programs and starts up the installation wizard. Current working directory is not relevant, though directory ``/rbmk/`` (absolute path) must not be otherwise in use.

3. Manual

     - Run ``edit /rbmk/rbmk.lua``

     - Copy over text from ``https://raw.githubusercontent.com/C937-IT-A/rbmk-wrecker-2000/refs/heads/main/rbmk.lua`` less than 255 lines at a time.

       - Run ``edit /rbmk/rbmkTorchMan.lua``.

       - Copy over text from ``https://raw.githubusercontent.com/C937-IT-A/rbmk-wrecker-2000/refs/heads/main/rbmkTorchMan.lua`` less than 255 lines at a time (likely unnecessary limit).

5. Both Methods (first install only)

     - Use four Redstone-over-Radio (RoR) logic receivers to map raw values read from the central fuel channel to the 1-15 analog scale. Retransmit them on a second frequency (*this* frequency is to be registered by the computer). If you are opting not to use certain data measures, you may omit the radio repeater for that frequency and data type. It is no longer necessary to set up an identity transmitter for unused frequencies.

     - Set up an RoR controller for each control rod column; set controllers that correspond to different rod colors different frequencies, and controllers that correspond to similar rod colors the same frequency.

     - If desired, connect an RoR reader to a fluid gauge between the steam channels and turbine(s) which will allow the computer to indicate if the turbine(s) is/are running.

7. Both Methods (on update as well)

     - Edit ``controlRodRegistry`` in the program to correspond to rod controller frequencies by color; ``nil`` if no such frequency or rod color exists.

     - Edit ``dataRegistry`` in the program to correspond to *mapped* data RoR repeater frequencies. *Raw* and *mapped* data frequencies must not overlap.

**UPDATING**

1. Via Internet (must have internet card)
     - See *INSTALLATION*.

3. Manual

      - Check this GitHub repository's history to check which individual files have been updated since last use, use ``rm`` to remove them from your device, then see *INSTALLATION*.

*Important for both ***INSTALLATION and UPDATING****:

   - Run ``edit /rbmk/rbmk.lua`` and change values under the ``USER INPUTS`` comment header to your relevant values. Updating *will* overwrite them to the values I use for testing!

   - Do **not** use default values that come with the program for your frequencies just because I used them. Otherwise, you're using "admin" as your username and "admin" as your password for your pressurized water channel-type nuclear fission reactor control. Avoid.

   - Do **not** edit anything under the ``PROGRAM BODY`` comment header unless you need to make your own version of the program. If so, please do so with the rule ``dialDisableMeltdown`` set firmly to ``false``.

**USAGE**

1. Setting Control Rods

      - Click on the gray box under the column ``SET`` and type the percentile value for rod height (not rod insertion; 0 is fully inserted and 100 is fully extracted). Press ``BACKSPACE`` on your keyboard to correct an error and ``ENTER`` to confirm the new value.

      - The indicator light under the column ``P`` shows the control rod's progress toward the new set value from its previous value. **This indicator light is an estimate**. In the event of a lengthy fully blocking operation taking place, such as a long audio beep, the light will lag behind the actual rod. This is known to happen during SCRAM events. It is ideal to be able to see the reactor from the control room to mitigate this issue.

2. Making, Removing, and Using Presets

      - Click ``SAVE`` in the toolbar on the top right and type a name for the new preset (maximum 9 characters). Press ``BACKSPACE`` on your keyboard to correct an error and ``ENTER`` to confirm the new preset's name. This preset will represent the heights the rods were set to (not the rods' actual height) at the time it was registered.

      - Press ``DELETE`` under the ``PRESETS`` box to delete all presets if necessary.

      - Click ``LOAD`` under the ``PRESETS`` box for the relevant preset to automatically set all rod values to the recorded values.

3. Emergency Procedures

      - Click ``SCRAM`` in the toolbar on the top right to set all rod heights to zero immediately. This procedure does *not* vent any gases from the reactor.

      - The program will automatically SCRAM if either fuel rod or column heat meets the maximum value (set in the RoR repeater's logic receiver, repeated as analog signal of 15) if ``autoScram`` is set to ``true`` (by default).

4. Reading Data

      - If installed properly, unread values will be denoted as ``D/C`` and read values as ``CONN.`` next to their respective readout.

      - The bars will fill as their respective data approaches its maximum value.

      - The ``TRB`` indicator light in the bottom right will light up green if there is turbine throughput (if transmitted and read).

      - The ``DEP`` indicator light in the bottom right will flash red if the fuel rod has depleted completely.
  
      - The ``NOMINAL`` indicator light in the bottom right will rapidly flash red, display the word ``OVERHEAT``, and beep if the column or fuel rod heat data read from the reactor constitutes automatic scram conditions.

5. The Graph

      - The graph in the top right displays current and past data for a given data type selected by pressing the green ``GRAPH`` button next to said type. The graph is extremely basic and may not always appear continuous.

      - I have more important things to do than make the graph look nice.

**KNOWN PROBLEMS**

1. An irrelevant, unread value is being read as the same as the one before it that is read.

      - Use ``nil`` or ``false`` for frequencies under ``dataRegistry`` for irrelevant values. Empty strings are no longer used, and identity transmitters are no longer necessary.

2. The program does not deny data entry to control rods that do not exist.

      - Use ``nil`` or ``false`` for frequencies under ``controlRodRegistry`` for irrelevant values. Empty strings are no longer used and will cause this issue in new versions of the program.

3. People can control my reactor remotely without permission.

      - Change your RoR frequencies.
