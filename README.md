# babashka-dl


## What and Why


Installs [Babashka](https://github.com/babashka/babashka) on Windows.

I liked that [Michiel Borkent](https://github.com/borkdude) had the [install sh](https://raw.githubusercontent.com/babashka/babashka/master/install) and wanted something similar for Windows. 


## Use

```powershell
# to install in 'C:\Program Files\Babashka'
irm "https://raw.githubusercontent.com/mjhika/babashka-dl/main/install.ps1" | iex

# to install in your current directory
iex "& {$(irm https://raw.githubusercontent.com/mjhika/babashka-dl/main/install.ps1)} -Dir ."
```


## Known Issues


Right now I only have feature parity for install directory and download the latests version as that's my main use case. 

~~Also unfortunately, the script currently only supports PowerShell 7. I believe this is because `Expand-Archive` changed from version 5 to 7 somewhere. When trying to use on PS 5 `Expand-Archive` will throw an error because temp file that is created is not a proper zip archive?~~
