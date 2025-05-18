function GetLnks {
    Get-ChildItem -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs","$env:AppData\Microsoft\Windows\Start Menu\Programs" -Filter *.lnk -Recurse
}

function ListPrograms {
    GetLnks | Select-Object BaseName
}

function SearchProgram {
    param ([String]$name)
    GetLnks | Where-Object { $_.Name -ieq "$name.lnk" } | Select-Object -First 1 
}

function OpenNormal {
    param ([String]$name)
    
    $program = SearchProgram($name)
    if ($program){
        Write-Output ("Opening $($program.BaseName)...")
        Start-Process $program.FullName
    }else{
        Write-Output "Program not found."
    }
}

function OpenAdmin {
    param ([String]$name)
    $program = SearchProgram($name)

    if ($program){
        Write-Output ("Opening $($program.BaseName) as Administrator...")
        Start-Process $program.FullName -Verb runas
    }else{
        Write-Output "Program not found."
    }
}

if ($args.Count -eq 0){
    Write-Output "Use 'opn --help' for use instructions."
    exit 0
}else{
    if ($args[0] -in ("--help", "-h")){
        Write-Output @"
Uso:
    - opn <Program Name>                      : Open program.
    - opn [--help, -h]                        : Show this message.
    - opn [--list, -l]                        : Show programs list.
    - opn [--adm, --admin, -a] <Program Name> : Open program as Administrator.
"@
        exit 0
    }

    if ($args[0] -in ("--list", "-l")){
        ListPrograms
        exit 0
    }

    if ($args[0] -in ("--adm", "--admin", "-a")){
        if ($args.Count -eq 1){
            Write-Output ("Use opn $($args[0]) <Program Name>")
            exit 0
        }else{
            $program_name  = $args[1]
        }
        OpenAdmin($program_name)
    }

    else{
        $program_name  = $args[0]

        if ($program_name[0] -eq "-"){
            Write-Output "Unknown parameter: $program_name"
            exit 0
        }
        
        OpenNormal($program_name)
    }
}



