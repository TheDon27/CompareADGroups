#Custom function to compare ADGroups by users
function Compare-UserMembership{
    param(
        [Parameter(Mandatory=$true,Position=1)]
        [array]$Users,
        [Parameter(Mandatory=$true,Position=2)]
        [string]$Path
    )

    #First we will create a data table
    $Global:CompareTable = New-Object System.Data.DataTable

    #Next we will add the first column for the names of the ADGroups
    $CompareTable.Columns.Add("ADGroup") | Out-Null

    #For each user that is listed
    foreach($User in $Users)
    {
        #Add a column to our data table for the current user in the loop
        $CompareTable.Columns.Add($User) | Out-Null

        #Collect the groups that they are a member of
        $userGroups = Get-ADPrincipalGroupMembership -Identity $User

        #For each group we will add a new row and specify the column where to put the X
        foreach($userGroup in $userGroups)
        {
            #If the ADGroup doesn't exist in the table then we will create a new row.
            if(!($CompareTable.Select() | Where-Object {$_.ADGroup -eq $userGroup.name}))
            {
                $row = $CompareTable.NewRow()
                $row.ADGroup = $userGroup.name
                $row[$User] = "X"
                $CompareTable.Rows.Add($row)
            }

            #If the row already exists from a previous user in the loop we will update it to include the current user in the loop
            elseif($CompareTable.Select() | Where-Object {$_.ADGroup -eq $userGroup.name})
            {
                    $row = $CompareTable.Rows | Where-Object {$_.ADGroup -eq $userGroup.name}
                    $row[$User] = "X"
            }
        }
    }

    #Method to export the data sorted to a csv file at the path specified.
    $CompareTable | Sort-Object -Property 'ADGroup' | Export-Csv $Path
}

#Edit these users and the path to the csv file that is exported. Note: you can add as many users to compare as you want since this is built to be dynamic
Compare-UserMembership -Users ("UserA", "UserB", "UserC") -Path C:\Users.csv

