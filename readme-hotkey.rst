Hotkey Activation for Nerd Dictation
====================================

This document describes the hotkey functionality for nerd-dictation, which provides
instant voice-to-text activation using a double-tap hotkey.

Features
--------

- **Double-tap activation**: Quick double-tap to toggle dictation on/off
- **Configurable hotkeys**: Choose from Caps Lock (default), Right Alt, AltGr, or Menu key
- **Audio feedback**: Plays sounds when starting/stopping dictation
- **Model ready detection**: Prevents activation attempts before model loads (with error sound)
- **Fast response**: Keeps model loaded in memory using suspend/resume
- **Auto-recovery**: Automatically restarts if nerd-dictation crashes
- **Device selection**: Support for specific audio input devices

Installation
------------

1. Install the required Python module:

   .. code-block:: bash

      pip install pynput

2. Ensure you have audio playback support (PipeWire or PulseAudio)

3. Place the ``hotkey.py`` script in your nerd-dictation directory

Usage
-----

Basic usage with default settings (double-tap Caps Lock):

.. code-block:: bash

   python hotkey.py

Use a different activation key:

.. code-block:: bash

   # Right Alt key
   python hotkey.py --key alt_r

   # AltGr key (international keyboards)
   python hotkey.py --key alt_gr

   # Menu/Compose key
   python hotkey.py --key menu

Specify an audio device:

.. code-block:: bash

   python hotkey.py --device "alsa_input.usb-webcam.analog-stereo"

Configuration
-------------

The script uses the following settings:

- **Double-tap timeout**: 300ms between taps
- **Audio format**: 16kHz sample rate (optimal for speech recognition)
- **Input method**: PW-CAT (PipeWire) or SOX
- **Output method**: SIMULATE_INPUT with xdotool

Sound Files
-----------

The script looks for audio feedback files in ``sounds/`` directory:

- ``sounds/start.wav``: Played when model is ready and when dictation starts
- ``sounds/stop.wav``: Played when dictation stops
- ``sounds/error.wav``: Played when action cannot be performed (e.g., model not ready)

If these files don't exist, the script will run silently.

The included sounds are derived from Pixabay and are free for use under the Pixabay Content
License. See ``sounds/LICENSE`` for attribution details.

Troubleshooting
---------------

**No text appears when speaking:**

- Check that your microphone is working and not muted
- Verify the VOSK model is properly installed in ``~/.config/nerd-dictation/model``
- Try running ``nerd-dictation begin --verbose 2`` directly to debug

**Double-tap not detected:**

- Ensure you're tapping quickly enough (within 300ms)
- Some keyboards may have limitations with certain keys
- Try using a different activation key

**"xdotool not found" error:**

- Install xdotool: ``sudo apt install xdotool`` (Debian/Ubuntu)
- For Wayland, you may need to configure ``--simulate-input-tool`` differently

Technical Details
-----------------

The hotkey script:

1. Starts nerd-dictation in suspended state when launched
2. Monitors keyboard events for double-tap detection
3. Sends resume/suspend commands instead of begin/end for instant response
4. Keeps the speech recognition model loaded in memory
5. Handles process crashes with automatic recovery

This approach provides near-instant activation compared to loading the model
each time dictation starts.

Desktop Autostart
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create ``~/.config/autostart/nerd-dictation-hotkey.desktop``:

.. code-block:: ini

   [Desktop Entry]
   Type=Application
   Name=Nerd Dictation Hotkey
   Comment=Double-tap Caps Lock for voice dictation
   Exec=/path/to/nerd-dictation/hotkey.py
   Icon=audio-input-microphone
   Hidden=false
   NoDisplay=false
   X-GNOME-Autostart-enabled=true
   StartupNotify=false
   Terminal=false

Or use your desktop environment's GUI:

- **GNOME**: Settings → Startup Applications
- **KDE**: System Settings → Startup and Shutdown → Autostart
- **XFCE**: Settings Manager → Session and Startup → Application Autostart
