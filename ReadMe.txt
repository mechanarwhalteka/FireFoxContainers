Firefox Containers


Most of these functions are set up to create a backup of the JSON file before making changes. The backup is stored at '$env:temp\Firefox Containers'

When editing/adding containers, here is the list of possible colors and icons:
Color List:
    "blue",
    "turquoise",
    "green",
    "yellow",
    "orange",
    "red",
    "pink",
    "purple",
    "toolbar"
		
Icon List:
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


List of Functions:

Connect-FFCProfile
	This function finds all Firefox profiles and allows you to select one for editing.

Get-FFCProfile
	Returns the currently selected profile.

FFCAlphabetize
	This will alphabetize the containers in the selected profile.
	Optional parameters: [switch]AllProfiles, [switch]Recolor
	AllProfiles will alphabetize all containers in all profiles under the current user.
	Recolor will color the containers in order.

FFCRandomize
	This will randomize the containers in the selected profile. Mostly useless but helped me test the other functions.
	Optional parameters: [switch]AllProfiles, [switch]Recolor
	AllProfiles will randomize all containers in all profiles under the current user.
	Recolor will randomize the color the containers.

New-FFContainer
	This will add a new container to the bottom of the container list. You must specify Name.
	Optional parameters: [string]Color, [string]Icon
	Use Color and Icon to set the Icon and Icon Color for the new container.

Remove-FFContainer
	This will remove the selected container from the connected profile. You must include either the Name or usercontextID (ContextID) to be removed.
	optional parameter: [switch]Force
	Because containers can have the same name, I safeguarded the removal of multiple containers by name. If you use the Force switch, all containers with the matching name will be removed.
	
Get-FFContainerJSON
	This returns the raw JSON of the connected profile.

Get-FFContainer
	This function returns an array of all container objects in the connected profile.
	Optional parameters: [string]Name, [Int]ContextID, [String]Color, [String]Icon
	Using the Name or ContextID will return only the matching container(s). Color and Icon will filter to only return containers matching the specified Color/Icon, respectively.
	
Set-FFContainer
	This function allows you to edit the name, icon, or color of a specified container. You must include either the Name or usercontextID (ContextID) to be changed.
	Optional parameters: [string]Icon, [string]Color, [String]NewName
	Use these to set the new values for the Icon, Color, and/or Name.

Move-FFContainer
	This function lets you reorder the containers of the connected profile. You must include either the Name or usercontextID (ContextID) to be moved.
	Optional parameters: [switch]First, [switch]Last, [Int]Up, [Int]Down
	Using First or Last will move the container to the respective position. using Up or Down, you specify the number of positions to move the container in the respective direction.
	I meant to make a [int]Position that would move it to the position given, but I guess I forgot. Maybe will add that.