# PowerSharp

Can be run either standalone - compile and use as powershell.exe replacement - or with embedded script resource.

To compile with embedded resource:
resEmbed.ps1 <solution_dir_path> <script.ps1> <output.exe>

For complicated commands, supports base64-encoded input to alleviate any query-breaking symbols:
powersharp.exe -b64 <base64_encoded_commands>