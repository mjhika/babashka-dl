# babashka-dl


## What and Why


Installs [Babashka](https://github.com/babashka/babashka) on Windows.

I liked that [Michiel Borkent](https://github.com/borkdude) had an 
[install sh](https://raw.githubusercontent.com/babashka/babashka/master/install). 
I wanted something similar for Windows. 

This isn't intended to replace using a tool like `scoop` but instead for systems
where scoop is just more overhead than you want to manage. For that reason this 
script installs to the end of `$env:PATH`


## Usage

```powershell
# to install in 'C:\Program Files\Babashka'
irm "https://raw.githubusercontent.com/mjhika/babashka-dl/main/install.ps1" | iex
# or
irm "https://bb-dl.mjhika.com" | iex
# By default you must run with Administrator so that it's on the PATH
# otherwise use the other method to install to a different directory

# to install in your current directory
iex "& {$(irm https://raw.githubusercontent.com/mjhika/babashka-dl/main/install.ps1)} -Dir ."
# or to a specific directory
iex "& {$(irm bb-dl.mjhika.com)} -Dir ."
# or a specific version
iex "& {$(irm bb-dl.mjhika.com)} -Version v1.3.176"
# or both
iex "& {$(irm bb-dl.mjhika.com)} -Version v1.3.176 -Dir ."
```


## Known Issues


~~Right now I only have feature parity for install directory and download the latests version as that's my main use case.~~

~~Also unfortunately, the script currently only supports PowerShell 7. I believe this is because `Expand-Archive` changed from version 5 to 7 somewhere. When trying to use on PS 5 `Expand-Archive` will throw an error because temp file that is created is not a proper zip archive?~~
