# Prompt for Imgur Client ID
$clientId = Read-Host -Prompt "Enter your Imgur Client ID"

# Define the directory containing your images
$directory = ".\images"

# Define a function to get the upload date from Imgur
function Get-ImgurDate {
    param (
        [string]$imgurId,
        [string]$clientId
    )
    $url = "https://api.imgur.com/3/image/$imgurId"
    $headers = @{ "Authorization" = "Client-ID $clientId" }
    $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
    return $response.data.datetime
}

# Function to convert Unix timestamp to DateTime
function ConvertFrom-UnixTime {
    param (
        [int64]$unixTime
    )
    $epoch = [System.DateTime]::UnixEpoch
    return $epoch.AddSeconds($unixTime)
}

# Change to the directory
Set-Location $directory

# Iterate through each image file in the directory
Get-ChildItem -Filter *.png | ForEach-Object {
    $fileName = $_.Name
    if ($fileName -match "\d+ - (\w+)\.png") {
        $imgurId = $matches[1]
        $imgurDate = Get-ImgurDate -imgurId $imgurId -clientId $clientId
        if ($imgurDate) {
            $filePath = $_.FullName
            $dateTime = ConvertFrom-UnixTime -unixTime $imgurDate
            
            # Set the file's creation and modification dates
            [System.IO.File]::SetCreationTime($filePath, $dateTime)
            [System.IO.File]::SetLastWriteTime($filePath, $dateTime)

            Write-Output "Updated $filePath with date $dateTime"
        } else {
            Write-Output "Failed to get date for Imgur ID: $imgurId"
        }
    } else {
        Write-Output "File name $fileName does not match the expected pattern."
    }
}
