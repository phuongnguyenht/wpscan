# Can not open wpscan

```
root@Lucky:~# wpscan
[ERROR] cannot load such file -- xmlrpc/client
root@Lucky:~# gem install xmlrpc

root@Lucky:~# wpscan
[ERROR] cannot load such file -- ffi_c
[TIP] Try to run 'gem install ffi_c' or 'gem install --user-install ffi_c'. If you still get an error, Please see README file or https://github.com/wpscanteam/wpscan

-->  
root@Lucky:~# gem install bundler
root@Lucky:~# gem install wpscan
Fetching: nokogiri-1.8.5.gem (100%)
Building native extensions. This could take a while...

Successfully installed nokogiri-1.8.5
...
Installing ri documentation for wpscan-3.4.0
Done installing documentation for nokogiri, activesupport, opt_parse_validator, ruby-progressbar, ffi, typhoeus, yajl-ruby, cms_scanner, wpscan after 52 seconds
9 gems installed
root@Lucky:~# wpscan
/usr/share/wpscan/lib/common/hacks.rb:81: warning: constant ::Fixnum is deprecated
_______________________________________________________________
        __          _______   _____                  
        \ \        / /  __ \ / ____|                 
         \ \  /\  / /| |__) | (___   ___  __ _ _ __  
          \ \/  \/ / |  ___/ \___ \ / __|/ _` | '_ \ 
           \  /\  /  | |     ____) | (__| (_| | | | |
            \/  \/   |_|    |_____/ \___|\__,_|_| |_|

        WordPress Security Scanner by the WPScan Team 
                       Version 2.9.1
          Sponsored by Sucuri - https://sucuri.net
   @_WPScan_, @ethicalhack3r, @erwan_lr, pvdl, @_FireFart_
_______________________________________________________________


Examples :

```