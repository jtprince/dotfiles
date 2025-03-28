
CLI options
(from https://github.com/koekeishiya/skhd?tab=readme-ov-file#usage)
----------- 

```
--install-service: Install launchd service file into ~/Library/LaunchAgents/com.koekeishiya.skhd.plist
    skhd --install-service

--uninstall-service: Remove launchd service file ~/Library/LaunchAgents/com.koekeishiya.skhd.plist
    skhd --uninstall-service

--start-service: Run skhd as a service through launchd
    skhd --start-service

--restart-service: Restart skhd service
    skhd --restart-service

--stop-service: Stop skhd service from running
    skhd --stop-service

-V | --verbose: Output debug information
    skhd -V

-P | --profile: Output profiling information
    skhd -P

-v | --version: Print version number to stdout
    skhd -v

-c | --config: Specify location of config file
    skhd -c ~/.skhdrc

-o | --observe: Output keycode and modifiers of event. Ctrl+C to quit
    skhd -o

-r | --reload: Signal a running instance of skhd to reload its config file
    skhd -r

-h | --no-hotload: Disable system for hotloading config file
    skhd -h

-k | --key: Synthesize a keypress (same syntax as when defining a hotkey)
    skhd -k "shift + alt - 7"

-t | --text: Synthesize a line of text
    skhd -t "hello, worldシ"
```


Config reference
----------------

NOTE(koekeishiya): A list of all built-in modifier and literal keywords can
                   be found at https://github.com/koekeishiya/skhd/issues/1

                   A hotkey is written according to the following rules:

                     hotkey       = <mode> '<' <action> | <action>

                     mode         = 'name of mode' | <mode> ',' <mode>

                     action       = <keysym> '[' <proc_map_lst> ']' | <keysym> '->' '[' <proc_map_lst> ']'
                                    <keysym> ':' <command>          | <keysym> '->' ':' <command>
                                    <keysym> ';' <mode>             | <keysym> '->' ';' <mode>

                     keysym       = <mod> '-' <key> | <key>

                     mod          = 'modifier keyword' | <mod> '+' <mod>

                     key          = <literal> | <keycode>

                     literal      = 'single letter or built-in keyword'

                     keycode      = 'apple keyboard kVK_<Key> values (0x3C)'

                     proc_map_lst = * <proc_map>

                     proc_map     = <string> ':' <command> | <string>     '~' |
                                    '*'      ':' <command> | '*'          '~'

                     string       = '"' 'sequence of characters' '"'

                     command      = command is executed through '$SHELL -c' and
                                    follows valid shell syntax. if the $SHELL environment
                                    variable is not set, it will default to '/bin/bash'.
                                    when bash is used, the ';' delimeter can be specified
                                    to chain commands.

                                    to allow a command to extend into multiple lines,
                                    prepend '\' at the end of the previous line.

                                    an EOL character signifies the end of the bind.

                     ->           = keypress is not consumed by skhd

                     *            = matches every application not specified in <proc_map_lst>

                     ~            = application is unbound and keypress is forwarded per usual, when specified in a <proc_map>

NOTE(koekeishiya): A mode is declared according to the following rules:

                     mode_decl = '::' <name> '@' ':' <command> | '::' <name> ':' <command> |
                                 '::' <name> '@'               | '::' <name>

                     name      = desired name for this mode,

                     @         = capture keypresses regardless of being bound to an action

                     command   = command is executed through '$SHELL -c' and
                                 follows valid shell syntax. if the $SHELL environment
                                 variable is not set, it will default to '/bin/bash'.
                                 when bash is used, the ';' delimeter can be specified
                                 to chain commands.

                                 to allow a command to extend into multiple lines,
                                 prepend '\' at the end of the previous line.

                                 an EOL character signifies the end of the bind.
