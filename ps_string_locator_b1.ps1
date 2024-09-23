# Levi McCarty
# 9/23/2024
# NON-FUNCTIONAL VERSION

# Import necessary assemblies
Add-Type -AssemblyName System.Windows.Forms

# Create a new Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "String Locator b1.0"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable

# Create a new RichTextBox
$richTextBox = New-Object System.Windows.Forms.RichTextBox
$richTextBox.Dock = [System.Windows.Forms.DockStyle]::Fill

# Create a button
$button = New-Object System.Windows.Forms.Button
$button.Text = "Test Script"
$button.Location = New-Object System.Drawing.Point(10, 10)
$button.Size = New-Object System.Drawing.Size(100, 30)

# Function to handle text highlighting
$highlightTextHandler = {
    try {
        # Clear previous highlights
        $richTextBox.SelectAll()
        $richTextBox.SelectionColor = [System.Drawing.Color]::Black

        # Get the text from the RichTextBox
        $text = $richTextBox.Text

        # Corrected Regex pattern for strings in single, double, or backticks
        $matches = [regex]::Matches($text, '(?<!\w)(\'[^\']*\'|"[^"]*"|`[^`]*`)(?!\w)')

        # Loop through matches and highlight them in green
        foreach ($match in $matches) {
            $richTextBox.SelectionStart = $match.Index
            $richTextBox.SelectionLength = $match.Length
            $richTextBox.SelectionColor   
 = [System.Drawing.Color]::Green
        }
    } catch {
        # Handle exceptions and display error message
        Write-Warning "An error occurred: $_"
    }
}

# Register the event handler for TextChanged
Register-ObjectEvent -InputObject $richTextBox -EventName TextChanged -Action $highlightTextHandler

# Button click event to load sample text
$button.Add_Click({
    $richTextBox.Text = @'
# Random strings for junk code
$randomString1 = "Ljkadf93jfa09a8df"
$randomString2 = "skjfl92348sladkfj"
$randomString3 = "sdf9sd8f7s9df7sdf"
$randomString4 = "LKJLKjoioisdf9823"
$randomString5 = "0923kljsdfkjsdkf"

# Junk function 1
function Get-RandomJunk1 {
    $junkVariable1 = "This is a junk function with no real purpose"
    Write-Host "Executing Junk Function 1"
    for ($i = 0; $i -lt 5; $i++) {
        Write-Host $junkVariable1
        $temp = $randomString1 + $randomString2 + $randomString3
        $junkResult = $temp + " More junk text"
    }
}

# Junk function 2
function Set-JunkConfig {
    param (
        [string]$param1 = "DefaultJunkValue1",
        [string]$param2 = "DefaultJunkValue2"
    )
    $junkConfig = "Configuring junk parameters"
    Write-Host "Setting Junk Configuration"
    Write-Host "Param1: $param1"
    Write-Host "Param2: $param2"
    $junkConcatenation = $param1 + $param2 + " JunkSuffix"
}

# Junk function 3
function Add-JunkNumbers {
    param (
        [int]$num1 = 42,
        [int]$num2 = 99
    )
    Write-Host "Adding two junk numbers"
    $sum = $num1 + $num2
    Write-Host "The junk result is: $sum"
    return $sum
}

# More junk strings and variables
$junkVariable1 = "junksampletext"
$junkVariable2 = "MoreRandomJunk"
$junkVariable3 = "ldksjf9834jdkfj"

# Another pointless loop
for ($i = 0; $i -lt 3; $i++) {
    $uselessVar = $junkVariable1 + $junkVariable2
    Write-Host "Looping through junk code iteration $i"
}

# Junk logic that doesn't do anything useful
if ($junkVariable1 -eq "junksampletext") {
    Write-Host "Junk condition met"
    $moreJunk = Add-JunkNumbers -num1 13 -num2 37
} else {
    Write-Host "Junk condition not met"
}

# Junk function 4
function Do-NothingSpecial {
    Write-Host "This function is here to pad out the script."
    $nothingVar = $randomString3 + " completely useless"
    Write-Host $nothingVar
}

# Random function calls
Get-RandomJunk1
Set-JunkConfig -param1 "Example1" -param2 "Example2"
Do-NothingSpecial
'@
})

# Add the RichTextBox and button to the form
$form.Controls.Add($richTextBox)
$form.Controls.Add($button)

# Show the form
$form.ShowDialog()
