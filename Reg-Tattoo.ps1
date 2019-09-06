function Get-PatchLevel {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
    }
    
    process {
        $Hotfixes = Get-HotFix | Where-Object { $null -ne $_.InstalledOn } | Sort-Object -Property 'InstalledOn'
        $Hotfixes[-1].HotFixID
    }
    
    end {
    }
}

$Tattoo = @{
    CanvasRoot = 'HKEY_LOCAL_MACHINE\SYSTEM\Tattoo'
    Deployment = @{
        SleeveRoot = [string]'Deployment'
        Tattoo     = @{
            'Version'     = [string]'1.1.1'
            'Deploy Date' = [string]$(Get-Date -Format 'u')
        }
    }
    WIM        = @{
        SleeveRoot = [string]'Deployment\WIM'
        Tattoo     = @{
            'Version'     = [string]'1.1.1'
            'Build Date'  = [string]$(Get-Date -Format 'u')
            'Patch Level' = [string]$(Get-PatchLevel)
        }
    }
}


function Write-Tattoo {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
        )] 
        [ValidateScript( {
                [bool]$ValidCanvas = $true
                $_Canvas = $_
                $ValidCanvas = $ValidCanvas -and $_Canvas.ContainsKey('CanvasRoot')
                $ValidCanvas = $ValidCanvas -and ($_Canvas.Keys).Count -gt 1
                $_Canvas.keys | Where-Object { $_ -ne 'CanvasRoot' } | ForEach-Object {
                    $ValidCanvas = $ValidCanvas -and ($_Canvas.$_).containskey('SleeveRoot')
                }
                $ValidCanvas
            })]
        [hashtable]$Canvas
    )
    
    begin {
        if (!(Test-Path "Registry::$($Canvas.CanvasRoot)")) {
            New-Item -Path "Registry::$($Canvas.CanvasRoot)" -ItemType Registry -Force
        }
        # Create root for all future registry actions
        $CanvasRoot = New-PSDrive -Name 'CanvasRoot' -PSProvider Registry -Root $Canvas.CanvasRoot
    }
    
    process {
        $Sleeves = $Canvas.Keys | Where-Object { $_ -ne 'SleeveRoot' }
        foreach ($Sleeve in $Sleeves) {
            [string]$SleeveRoot = "CanvasRoot:\$($Canvas[$Sleeve].SleeveRoot)"
            $Tattoos = $Canvas[$Sleeve].Tattoo
            foreach ($Tattoo in $Tattoos.keys) {
                switch (($Tattoos[$Tattoo].GetType()).Name) {
                    string {
                        Write-Output "`"$($SleeveRoot)\$($Tattoo)`" Reg_SZ `"$($Tattoos[$Tattoo])`""
                        if (!(Test-Path -Path $SleeveRoot)) {
                            New-Item -Path $SleeveRoot -Force | Out-Null
                        }
                        New-ItemProperty -Path $SleeveRoot -Name $Tattoo -PropertyType String -Value $Tattoos[$Tattoo] -Force
                        break
                    }
                    Default {
                        return "$result\$arg"
                    }
                }
            }
        }
    }
    end {
        Remove-PSDrive -Name $CanvasRoot
    }
}


Write-Tattoo -Canvas $Tattoo
exit

