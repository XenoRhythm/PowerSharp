if ($args.Length -ne 3) {
    Write-Host "Usage: resEmbed.ps1 <powersharp directory path> <script1.ps1 path> <output.exe>"
} 
else {

    $powersharpDirectoryPath = $args[0]
    $scriptPath = $(get-item $args[1]).FullName
    $outputExe = $args[2]

    $csprojFilePath = Join-Path -Path $powersharpDirectoryPath -ChildPath "powersharp\powersharp.csproj"

    try {
	[Reflection.Assembly]::LoadWithPartialName("System.Xml.Linq") | Out-Null
        [System.Xml.Linq.XDocument]$csprojDocument = [System.Xml.Linq.XDocument]::Load($csprojFilePath)
        [System.Xml.Linq.XElement]$itemGroup = $csprojDocument.Descendants().Where({ $_.Name.LocalName -eq "ItemGroup" }) | Select-Object -Last 1

        if ($itemGroup -ne $null) {
	    [System.Xml.Linq.XName]$xname = "EmbeddedResource"
            [System.Xml.Linq.XElement]$embeddedResourceElement = [System.Xml.Linq.XElement]::new($xname)
            $embeddedResourceElement.SetAttributeValue("Include", $scriptPath)
            $itemGroup.Add($embeddedResourceElement)
            $csprojDocument.Save($csprojFilePath)

	    #invoke cli msbuild
	    if (!(get-command msbuild -erroraction silentlycontinue))
	    {
	    	$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
	    	$vspath = &$vswhere -nologo -latest -property installationPath
	    	if (Test-Path $vspath\Bin\MSBuild.exe) { $msbpath = "$vspath\Bin\MSBuild.exe" }
	    	if (Test-Path $vspath\msbuild\current\bin\msbuild.exe) { $msbpath = "$vspath\msbuild\current\bin\msbuild.exe" }
	    }
	    else { $msbpath = msbuild.exe }

	    if ($msbpath)
	    {
		&$msbpath "$powersharpDirectoryPath\powersharp.sln" | out-null
		Copy-Item -Path (Join-Path -Path $powersharpDirectoryPath -ChildPath "powersharp\bin\Release\powersharp.exe") -Destination $outputExe -Force
	    }
	    else {Write-Host "MSBuild isn't found" }
	
            $itemGroup.Remove()
            $csprojDocument.Save($csprojFilePath)
        } else {
            Write-Host "No <ItemGroup> found in the .csproj file."
        }
    } catch {
        Write-Host "Error: $($_.Exception.Message)"
    }
}
