<#########################
 #                       #
 #  author Mechanarwhal  #
 #   v1.0   2025-11-25   #
 #                       #
 #########################>


$Script:ConnectedProfile = ""
$Script:ConnectedProfilePath = ""
$Script:ColorList = @(
        "blue",
        "turquoise",
        "green",
        "yellow",
        "orange",
        "red",
        "pink",
        "purple",
        "toolbar"
    )
$Script:IconList = @(
        "fingerprint",
        "briefcase",
        "dollar",
        "cart",
        "vacation",
        "gift",
        "food",
        "fruit",
        "pet",
        "tree",
        "chill",
        "circle",
        "fence"
    )

function Connect-FFCProfile {
    param(
        [string]$ProfilePath
    )

    if($profilepath){
        if(test-path("$profilepath\containers.json")){
            $Script:ConnectedProfile = (get-item $profilepath).Name
            $Script:ConnectedProfilePath = $profilepath
            Write-Host "Connected to $($profile) successfully!"
        }else{
            Throw "Error: Can't connect to Profile at $profilepath. not found or containers.json file missing"
        }
    }else{
        $choices = @("Dummy")
        $place = get-childitem "$env:appdata\Mozilla\Firefox\Profiles"
        $x=1
        write-host "Select a profile or option."
        foreach($item in $place){
            if(test-path "$($item.fullname)\containers.json"){
                write-host "[$x] $($item.name)"
                $choices+=$item
                $x+=1
            }
        }
        write-host "[$x] View all Users' Profiles"
        $choices+="Other"
        $x+=1
        write-host "[$x] Exit"
        $choices+="Exit"
        $select = [int](read-host "Choice")
        if(($select -eq 0) -or ($select -ge $choices.Length)){
            throw "Please choose a given option."
        }else{
            if($choices[$select] -eq "Other"){


                #build table of Usernames and profiles.
                $allusers = get-childitem "$env:SystemDrive\Users"
                $choices = @("dummy")
                $x = 1
                write-host "Select a profile or option."
                foreach($user in $allusers){
                    if(test-path "$($user.fullname)\Appdata\Roaming\Mozilla\Firefox\Profiles"){
                        $profiles = get-childitem "$($user.fullname)\Appdata\Roaming\Mozilla\Firefox\Profiles"
                        foreach($Folder in $profiles){
                            if(test-path "$($folder.fullname)\containers.json"){
                                $choices+= $folder.fullname
                                write-host "[$x] User $($user.name) with Profile $($folder.name)"
                                $x+=1
                            }
                        }
                    }
                }
                write-host "[$x] Exit"
                $choices+="Exit"
                $select = [int](read-host "Choice")
                if(($select -eq 0) -or ($select -ge $choices.Length)){
                    throw "Please choose a given option."
                }elseif($choices[$select] -eq "Exit"){
                    return "Exiting."
                }else{
                    $Script:ConnectedProfile = ($choices[$select]).name
                    $Script:ConnectedProfilePath = ($choices[$select]).fullname
                    write-host "Successfully connected to profile $Script:ConnectedProfile"
                }


            }elseif($choices[$select] -eq "Exit"){
                return "Exiting."
            }else{
                $Script:ConnectedProfile = ($choices[$select]).name
                $Script:ConnectedProfilePath = ($choices[$select]).fullname
                write-host "Successfully connected to profile $Script:ConnectedProfile"
            }
        }
    }
}
function Get-FFCProfile{
    param(
        [switch]$ListAvailable,
        [switch]$AllUsers
    )

    if((-not $Listavailable) -and (-not $allusers)){
        return $Script:ConnectedProfile
    }else{
        $list = @()
        if(-not $allusers){
            if(test-path "$env:appdata\Mozilla\Firefox\Profiles"){
                $profiles = get-childitem "$env:appdata\Mozilla\Firefox\Profiles"
                foreach($profile in $profiles){
                    if(test-path "$($profile.fullname)\containers.json"){
                        $list += [pscustomobject]@{Profile = $profile.name}
                    }
                }
            }
            return $list
        }else{
            $users = get-childitem "$env:SystemDrive\Users"
            foreach($user in $users){
                if(test-path "$($user.fullname)\Appdata\Roaming\Mozilla\Firefox\Profiles"){
                    $profiles = get-childitem "$($user.fullname)\Appdata\Roaming\Mozilla\Firefox\Profiles"
                    foreach($profile in $profiles){
                        if(test-path "$($profile.fullname)\containers.json"){
                            $list += [pscustomobject]@{ Profile = $profile.name; User = $user.name}
                        }
                    }
                }
            }
            return $list
        }
    }
}

function FFCAlphabetize{

#Change function to default to connectedprofile, and call connect-ffcprofile if it is blank. 

#This will alphabetize all containers for each profile in the current user's appdata folder.
#Recolor optionally colors them in order


    param(
        [switch]$ReColor,
        [switch]$AllProfiles
    )
    if((-not $Script:ConnectedProfile) -and (-not $AllProfiles)){
        throw "Error: You must connect a profile first using Connect-FFCProfile. Optionally, you can Randomize all profiles under the current user with the -AllProfiles switch."
        $Script:ConnectedProfile
    }

    if(-not $allusers){
        $jsonfile = "$script:connectedprofilepath\containers.json"

        #check for and create temp directory for backups
        if( -not (test-path("$env:temp\Firefox Containers Backup\$script:connectedprofile\"))){
            New-Item "$env:temp\Firefox Containers Backup\$script:ConnectedProfile\" -ItemType Directory
        }
        copy-item $jsonfile -Destination "$env:temp\Firefox Containers Backup\$script:connectedprofile\containers-json-$(get-date -format yyyyMMddhhmmss).json"
            
        #convert JSON to object array and sort
        $containers = get-content $jsonfile | convertfrom-json
        $containers.identities = $containers.identities | Sort-Object -Property name
        
          
            
            
        #Recolor
        if($recolor){
            $colors = @()
            $stopper = $containers.identities.Count
            for($i=0;$i -lt ([math]::ceiling($stopper/($Script:ColorList.Count)));$i++){
                $colors +=$Script:ColorList
            }
            for($i=0;$i -lt $stopper; $i++){
                $containers.identities[$i].color = $colors[$i]
            }
        }
        #Apply Changes
        $containers | ConvertTo-Json | set-content $jsonfile
        if($recolor){
            write-host "Successfully Alphabetized and Recolored Firefox Containers for profile $script:connectedprofile"
        }else{
            write-host "Successfully Alphabetized Firefox Containers for profile $script:connectedprofile"
        }
    }

    if($allprofiles){
        $place = get-childitem "$env:appdata\Mozilla\Firefox\Profiles"
        foreach($profilepath in $place){
            if((get-childitem $profilepath.fullname).name -like "containers.json"){
                $jsonfile = "$($profilepath.fullname)\containers.json"

                #check for and create temp directory for backups
                if( -not (test-path("$env:temp\Firefox Containers Backup\$($profilepath.name)\"))){
                    New-Item "$env:temp\Firefox Containers Backup\$($profilepath.name)\" -ItemType Directory
                }
                copy-item $jsonfile -Destination "$env:temp\Firefox Containers Backup\$($profilepath.name)\containers.json"
            
                #convert JSON to object array and sort
                $containers = get-content $jsonfile | convertfrom-json
                $containers.identities = $containers.identities | Sort-Object -Property name
            
            
            
            
                #Recolor
                if($recolor){
                    $colors = @()
                    $stopper = $containers.identities.Count
                    for($i=0;$i -lt ([math]::ceiling($stopper/($Script:ColorList.Count)));$i++){
                        $colors +=$Script:ColorList
                    }
                    for($i=0;$i -lt $stopper; $i++){
                        $containers.identities[$i].color = $colors[$i]
                    }
                }
                #Apply Changes
                $containers | ConvertTo-Json | set-content $jsonfile
                if($recolor){
                    write-host "Successfully Alphabetized and Recolored $($env:USERNAME)'s Firefox Containers for profile $($profilepath.name)"
                }else{
                    write-host "Successfully Alphabetized $($env:USERNAME)'s Firefox Containers for profile $($profilepath.name)"
                }
            }
        }
    }
}
function FFCRandomize{
#This will alphabetize all containers for the connected profile in the current user's appdata folder.
#Recolor optionally colors them in order


    param(
        [switch]$ReColor,
        [switch]$AllProfiles
    )
    if((-not $Script:ConnectedProfile) -and (-not $AllProfiles)){
        throw "Error: You must connect a profile first using Connect-FFCProfile. Optionally, you can Randomize all profiles under the current user with the -AllProfiles switch."
    }

    if(-not $AllProfiles){

        $jsonfile = "$script:connectedprofilepath\containers.json"

        #check for and create temp directory for backups
        if( -not (test-path("$env:temp\Firefox Containers Backup\$script:connectedprofile\"))){
            New-Item "$env:temp\Firefox Containers Backup\$script:connectedprofile\" -ItemType Directory
        }
        copy-item $jsonfile -Destination "$env:temp\Firefox Containers Backup\$script:connectedprofile\containers-json-$(get-date -format yyyyMMddhhmmss).json"
            
        #convert JSON to object array and sort
        $containers = get-content $jsonfile | convertfrom-json
        $containers.identities = $containers.identities | Sort-Object {get-random}
        
          
            
            
        #Recolor
        if($recolor){
            foreach($identity in $containers.identities){
                $identity.color = $Script:ColorList[(get-random -maximum ($Script:ColorList.count))]
            }
        }
        #Apply Changes
        $containers | ConvertTo-Json | set-content $jsonfile
        if($recolor){
            write-host "Successfully Randomized and Recolored Firefox Containers for profile $script:connectedprofile"
        }else{
            write-host "Successfully Randomized Firefox Containers for profile $script:connectedprofile"
        }
    }else{
        $place = get-childitem "$env:appdata\Mozilla\Firefox\Profiles"
        foreach($profilepath in $place){
            if((get-childitem $profilepath.fullname).name -like "containers.json"){
                $jsonfile = "$($profilepath.fullname)\containers.json"

                #check for and create temp directory for backups
                if( -not (test-path("$env:temp\Firefox Containers Backup\$($profilepath.name)\"))){
                    New-Item "$env:temp\Firefox Containers Backup\$($profilepath.name)\" -ItemType Directory
                }
                copy-item $jsonfile -Destination "$env:temp\Firefox Containers Backup\$script:connectedprofile\containers-json-$(get-date -format yyyyMMddhhmmss).json"
            
                #convert JSON to object array and sort
                $containers = get-content $jsonfile | convertfrom-json
                $containers.identities = $containers.identities | Sort-Object {get-random}
            
            
            
            
                #Recolor
                if($recolor){
                    foreach($identity in $containers.identities){
                        $identity.color = $Script:ColorList[(get-random -maximum ($Script:ColorList.count))]
                    }
                }
                #Apply Changes
                $containers | ConvertTo-Json | set-content $jsonfile
                if($recolor){
                    write-host "Successfully Randomized and Recolored $($env:USERNAME)'s Firefox Containers for profile $($profilepath.name)"
                }else{
                    write-host "Successfully Randomized $($env:USERNAME)'s Firefox Containers for profile $($profilepath.name)"
                }
            }
        }
    }
}

function New-FFContainer{
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [string]$Color,
        [string]$Icon
    )

    $NewIdentity = [pscustomobject]@{
            "userContextId" = 0;
            "public"=$true;
            "icon"="circle";
            "color"="toolbar";
            "name" = $name
        }

    
    #Verify icon
    if($icon){
        if($icon -in $Script:IconList){
            $NewIdentity.icon = ($icon.ToLower())
        }else{
            write-warning "Your specified Icon did not match the list: $Script:IconList. Using default 'circle'"
        }
    }
    
    #Verify color
    if($color){
        if($color -in $Script:ColorList){
            $NewIdentity.color = ($color.tolower())
        }else{
            write-warning "Your specified Color did not match the list: $Script:ColorList. Using default 'toolbar'"
        }
    }

    $jsonfile = "$Script:ConnectedProfilePath\containers.json"
    
    
    #check for and create temp directory for backups
    if( -not (test-path("$env:temp\Firefox Containers Backup\$script:connectedprofile\"))){
            New-Item "$env:temp\Firefox Containers Backup\$script:connectedprofile\" -ItemType Directory
        }
        copy-item $jsonfile -Destination "$env:temp\Firefox Containers Backup\$script:connectedprofile\containers-json-$(get-date -format yyyyMMddhhmmss).json"
            
        #convert JSON to object array
        $containers = get-content $jsonfile | convertfrom-json
        $containers.lastusercontextid++
        $NewIdentity.usercontextid = ($containers.lastUserContextId)
        $containers.identities += $NewIdentity
        
        #Apply Changes
        $containers | ConvertTo-Json | set-content $jsonfile
        write-host "Successfully added Container $name to $script:ConnectedProfile"
}

function Remove-FFContainer{
    param (
        [string]$Name,
        [Int]$ContextID,
        [switch]$Force
    )
    if(-not $Script:ConnectedProfile){
        throw "Error: You need to first connect a profile with Connect-FFCProfile" 
    }
    if($name -and $ContextID){
        throw "Error: Please include Container Name or ContextID, but not both."
    }
    if(-not $name -and -not $ContextID){
        throw "Error: You need to include either the Container name or Context ID."
    }
    $jsonfile = "$Script:Connectedprofilepath\containers.json"
    $containers = get-content $jsonfile | convertfrom-json
    
    if($name){
        if($containers.identities | where name -like $name){
            if((-not ($containers.identities | where name -like $name).count) -or $force){ #This is a funny way to check if there is only one, but it works as far as I can tell. Also bypassing check if Force is enabled.
                $containers.identities = $containers.identities | where name -notlike $name
                $containers.lastUserContextId = (@(($containers.identities | where public).usercontextid | sort -Descending)[0]) # This finds the largest public UserContextID and sets it. I think Firefox uses this to track what the next ID should be.
                $containers | ConvertTo-Json | set-content $jsonfile
                 write-host "Successfully Removed Container with Name $name."
            }
            else{
                Write-Warning "There were more than one Container that matched by name. Please use -ContextID to specify which Container should be removed, or -Force to remove them all"
            }
        }
    }elseif($ContextID){
        if($containers.identities | where UsercontextID -like $contextID){
            $containers.identities = $containers.identities | where usercontextID -notlike $ContextID
            $containers.lastUserContextId = (@(($containers.identities | where public).usercontextid | sort -Descending)[0]) # This finds the largest public UserContextID and sets it. I think Firefox uses this to track what the next ID should be.
            $containers | ConvertTo-Json | set-content $jsonfile
            write-host "Successfully Removed Container with UserContextID $contextID."
        }
    }
}

function Get-FFContainerJSON{
    if(-not $Script:ConnectedProfile){
        throw "Error: You must first connect a FireFox Profile with Connect-FFCProfile"
    }
    $jsonfile = get-content "$script:connectedprofilepath\containers.json"
    return $jsonfile
}

function Get-FFContainer{
    param(
        [String]$Name,
        [Int]$ContextID,
        [String]$Color,
        [String]$Icon
    )

    if(-not $Script:ConnectedProfile){
        throw "Error: You must first connect a FireFox Profile with Connect-FFCProfile"
    }
    $jsonfile = "$script:connectedprofilepath\containers.json"
    $containers = get-content $jsonfile | convertfrom-json
    $returnItem = $containers.identities
    if($Name){
        $returnItem = $returnItem | where name -like $name
    }
    if($ContextID){
        $returnItem = $returnItem | where usercontextid -like $contextid
    }
    if($Color){
        $returnItem = $returnItem | where color -like $color
    }
    if($icon){
        $returnitem = $returnItem | where icon -like $icon
    }
    return $returnitem
}
function Set-FFContainer{
    param(
        [string]$Name,
        [int]$ContextID,
        [string]$Icon,
        [string]$Color,
        [string]$NewName
    )

    if(-not $Script:ConnectedProfile){
        throw "Error: You must first connect a FireFox Profile with Connect-FFCProfile"
    }
    if($name -and $ContextID){
        throw "Error: Please use either the Name or Context ID for Container lookup, not both. If you are trying to rename the container, use -NewName."
    }
    if((-not $name) -and (-not $ContextID)){
        throw "Error: You must specify either a Container Name or Context ID to make changes."
    }
    if($color){
        if(-not ($color -in $Script:ColorList)){
            throw "Error: The color was not found in the list of valid Colors: $script:Colorlist"
        }
    }
    if($icon){
        if(-not ($icon -in $Script:IconList)){
            throw "Error: The icon was not found in the list of valid Icons: $script:Iconlist"
        }
    }
    if((-not $newname) -and (-not $color) -and (-not $icon)){
        throw "Error: You have to include a new name, icon, or color to change."
    }
    $jsonfile ="$script:connectedprofilepath\containers.json"
    $containers = get-content $jsonfile | convertfrom-json

    #check for and create temp directory for backups
    if( -not (test-path("$env:temp\Firefox Containers Backup\$script:connectedprofile\"))){
        New-Item "$env:temp\Firefox Containers Backup\$script:connectedprofile\" -ItemType Directory
    }
    copy-item $jsonfile -Destination "$env:temp\Firefox Containers Backup\$script:connectedprofile\containers-json-$(get-date -format yyyyMMddhhmmss).json"

    if($name){
        $Updatecheck = @($containers.identities | where Name -like $name)
        $updateObject = $containers.identities | where Name -like $name
        write-host "sanity check"
        if(-not $updatecheck){
            throw "Error: Could not find a container in $Script:ConnectedProfile with name $name"
        }
        if($updatecheck.count -gt 1){
            throw "Error: There are more than one containers in $Script:ConnectedProfile with the name $name. Please use Context ID instead"
        }
        if($color){
            $updateObject.color = $color
        }
        if($icon){
            $Updatecheck.icon = $icon
        }
        if($NewName){
            $Updatecheck.name = $NewName
        }
        $containers | ConvertTo-Json | set-content $jsonfile
        Write-Host "Successfully updated Container $name."

    }elseif($ContextID){
        $updateObject = $containers.identities | where usercontextid -like $ContextID
        if(-not $updateobject){
            throw "Error: Could not find a container in $Script:ConnectedProfile with UserContextID $contextid"
        }
        if($color){
            $updateObject.color = $color
        }
        if($icon){
            $UpdateObject.icon = $icon
        }
        if($NewName){
            $UpdateObject.name = $NewName
        }
        $containers | ConvertTo-Json | set-content $jsonfile
        Write-Host "Successfully updated Container $ContextID."
    }
}


function Move-FFContainer{
    param (
        [string]$Name,
        [int]$ContextID,
        [switch]$First,
        [switch]$Last,
        [int]$Up,
        [int]$Down
    )
    
    if(-not ($First -xor $Last -xor $up -xor $down)){
        throw "Error: You must include excactly one of (First, Last, Up, Down)"
    }
    if(-not ($name -xor $ContextID)){
        throw "Error: You must include excactly one of (Name, ContextID)"
    }
    $jsonfile = "$script:connectedprofilepath\containers.json"
    $containers = get-content $jsonfile | convertfrom-json

    #check for and create temp directory for backups
    if( -not (test-path("$env:temp\Firefox Containers Backup\$script:connectedprofile\"))){
        New-Item "$env:temp\Firefox Containers Backup\$script:connectedprofile\" -ItemType Directory
    }
    copy-item $jsonfile -Destination "$env:temp\Firefox Containers Backup\$script:connectedprofile\containers-json-$(get-date -format yyyyMMddhhmmss).json"

    if($up -or $first){
        if($name){ $index = ([array]::IndexOf($containers.identities,($containers.identities | where name -like $name))) }
        else{ $index = ([array]::IndexOf($containers.identities,($containers.identities | where usercontextid -like $contextid))) }
        if($up){
            $NewIndex = $index - $up
        if($NewIndex -lt 0){
            $NewIndex = 0
            write-warning "Cannot move container up $up spaces. Moving to first position instead."
        }
        }else{
            $newindex = 0
        }
        if($index -gt 0){
            $Identities = [system.collections.arraylist]::new($containers.identities)
            $identities.RemoveAt($index)
            if($name){ $identities.Insert(($NewIndex),($containers.identities | where name -like $name)) }
            else{  $identities.Insert(($NewIndex),($containers.identities | where usercontextid -like $contextid)) }
            $containers.identities = $Identities.ToArray()
            $containers | ConvertTo-Json | set-content $jsonfile
            write-host "Successfully Moved Container."
        }else{
           throw "Specified container is already at the top."
        }
    }else{
        if($name){ $index = ([array]::IndexOf($containers.identities,($containers.identities | where name -like $name))) }
        else{ $index = ([array]::IndexOf($containers.identities,($containers.identities | where usercontextid -like $contextid))) }
        $NewIndex = $index + $down
        if($down){
            if($NewIndex -ge $containers.identities.Count){
                $NewIndex = ($containers.identities.count) -1
                write-warning "Cannot move container down $down spaces. Moving to last position instead instead."
            }
        }else{
            $NewIndex = ($containers.identities.count) -1
        }
        if($index -lt ($containers.identities.count -1)){
            $Identities = [system.collections.arraylist]::new($containers.identities)
            $identities.RemoveAt($index)
            if($name){ $identities.Insert(($NewIndex),($containers.identities | where name -like $name)) }
            else{  $identities.Insert(($NewIndex),($containers.identities | where usercontextid -like $contextid)) }
            $containers.identities = $Identities.ToArray()
            $containers | ConvertTo-Json | set-content $jsonfile
            write-host "Successfully Moved Container."
        }else{
           throw "Specified container is already at the bottom."
        }
    }
}
