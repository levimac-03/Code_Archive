# Title: Download Manager
# Made by: Levi
# Date: 2024-09-23
# NON-FUNCTIONAL VERSION

Add-Type -AssemblyName System.Windows.Forms

$form = New-Object System.Windows.Forms.Form
$form.Text = "Download Manager"
$form.Size = New-Object System.Drawing.Size(600, 700)  # Increased height to accommodate the RichTextBox

$menuStrip = New-Object System.Windows.Forms.MenuStrip
$form.MainMenuStrip = $menuStrip
$form.Controls.Add($menuStrip)

$fileMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$fileMenu.Text = "File"
$menuStrip.Items.Add($fileMenu)

$setDownloadLocationItem = New-Object System.Windows.Forms.ToolStripMenuItem
$setDownloadLocationItem.Text = "Set Download Location"
$fileMenu.DropDownItems.Add($setDownloadLocationItem)

$exitItem = New-Object System.Windows.Forms.ToolStripMenuItem
$exitItem.Text = "Exit"
$fileMenu.DropDownItems.Add($exitItem)

$settingsMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$settingsMenu.Text = "Settings"
$menuStrip.Items.Add($settingsMenu)

$changeProgressBarStyleItem = New-Object System.Windows.Forms.ToolStripMenuItem
$changeProgressBarStyleItem.Text = "Change Progress Bar Style"
$settingsMenu.DropDownItems.Add($changeProgressBarStyleItem)

$helpMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$helpMenu.Text = "Help"
$menuStrip.Items.Add($helpMenu)

$aboutItem = New-Object System.Windows.Forms.ToolStripMenuItem
$aboutItem.Text = "About"
$helpMenu.DropDownItems.Add($aboutItem)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10, 40)
$textBox.Size = New-Object System.Drawing.Size(300, 20)
$form.Controls.Add($textBox)

$buttonStart = New-Object System.Windows.Forms.Button
$buttonStart.Text = "Start Download"
$buttonStart.Location = New-Object System.Drawing.Point(320, 40)
$buttonStart.Size = New-Object System.Drawing.Size(120, 20)
$form.Controls.Add($buttonStart)

$dataGridView = New-Object System.Windows.Forms.DataGridView
$dataGridView.Location = New-Object System.Drawing.Point(10, 70)
$dataGridView.Size = New-Object System.Drawing.Size(580, 250)

$colUrl = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$colUrl.HeaderText = "URL"
$dataGridView.Columns.Add($colUrl)

$colFilePath = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$colFilePath.HeaderText = "File Path"
$dataGridView.Columns.Add($colFilePath)

$colProgress = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$colProgress.HeaderText = "Progress (%)"
$colProgress.Width = 80
$dataGridView.Columns.Add($colProgress)

$colStatus = New-Object System.Windows.Forms.DataGridViewTextBoxColumn
$colStatus.HeaderText = "Status"
$colStatus.Width = 120
$dataGridView.Columns.Add($colStatus)

$form.Controls.Add($dataGridView)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 350)
$progressBar.Size = New-Object System.Drawing.Size(580, 20)
$form.Controls.Add($progressBar)

$logTextBox = New-Object System.Windows.Forms.RichTextBox
$logTextBox.Location = New-Object System.Drawing.Point(10, 380)
$logTextBox.Size = New-Object System.Drawing.Size(580, 280)
$logTextBox.ReadOnly = $true
$logTextBox.Multiline = $true
$form.Controls.Add($logTextBox)

function LogEvent {
    param([string]$message)

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logTextBox.AppendText("[$timestamp] $message`r`n")
    $logTextBox.ScrollToCaret()
}

$downloadLocation = [System.IO.Path]::GetTempPath()

$setDownloadLocationItem.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $downloadLocation = $folderBrowser.SelectedPath
        LogEvent "Download location set to: $downloadLocation"
    }
})

$exitItem.Add_Click({
    [System.Windows.Forms.Application]::Exit()
})

$changeProgressBarStyleItem.Add_Click({
    $progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
    LogEvent "Progress bar style changed to Marquee"
})

$aboutItem.Add_Click({
    [System.Windows.Forms.MessageBox]::Show("Download Manager v1.0", "About", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})

class Download {
    [string]$Url
    [string]$FilePath
    [int]$Progress
    [string]$Status
    [int64]$TotalSize
    [int64]$DownloadedBytes
}

function Get-FilenameFromUrl {
    param([string]$Url)

    $uri = [System.Uri]::new($Url)
    return [System.IO.Path]::GetFileName($uri.AbsolutePath)
}

function Get-FileSize {
    param([string]$Url)

    try {
        $client = New-Object System.Net.Http.HttpClient
        $response = $client.GetAsync($Url, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).Result
        $response.EnsureSuccessStatusCode()

        $contentLength = $response.Content.Headers.ContentLength
        if (-not $contentLength) {
            throw "No content length found."
        }
        LogEvent "File size retrieved: $contentLength bytes for URL: $Url"
        return $contentLength
    } catch {
        LogEvent "Unable to retrieve file size for URL: $Url. Error: $_"
        return 0
    } finally {
        $client.Dispose()
    }
}

function Start-Download {
    param(
        [Download]$Download
    )

    LogEvent "Starting download: $($Download.Url)"

    $task = [System.Threading.Tasks.Task]::Run({
        try {
            $client = New-Object System.Net.Http.HttpClient
            $request = New-Object System.Net.Http.HttpRequestMessage 'Get', $Download.Url

            if ([System.IO.File]::Exists($Download.FilePath)) {
                $Download.DownloadedBytes = (Get-Item $Download.FilePath).Length
                if ($Download.DownloadedBytes -lt $Download.TotalSize) {
                    $request.Headers.Range = [System.Net.Http.Headers.RangeHeaderValue]::new($Download.DownloadedBytes, $Download.TotalSize - 1)
                    LogEvent "Resuming download from byte $($Download.DownloadedBytes) for $($Download.FilePath)"
                }
            } else {
                $Download.DownloadedBytes = 0
            }

            $response = $client.SendAsync($request, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).Result
            $response.EnsureSuccessStatusCode()

            $stream = $response.Content.ReadAsStreamAsync().Result
            $outputStream = [System.IO.File]::Open($Download.FilePath, [System.IO.FileMode]::Append)

            $buffer = New-Object byte[] 8192  # 8 KB buffer
            $bytesRead = 0

            while (($bytesRead = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                $outputStream.Write($buffer, 0, $bytesRead)
                $Download.DownloadedBytes += $bytesRead

                $Download.Progress = [math]::Round(($Download.DownloadedBytes / $Download.TotalSize) * 100, 2)

                $form.Invoke([System.Action]{
                    $dataGridView.Rows[$dataGridView.Rows.Count - 1].Cells[2].Value = $Download.Progress
                    $progressBar.Value = $Download.Progress
                })
            }

            $outputStream.Close()
            LogEvent "Download completed: $($Download.Url)"
        } catch {
            LogEvent "Error during download of $($Download.Url): $_"
        } finally {
            $client.Dispose()
        }
    })
}

$buttonStart.Add_Click({
    $downloadUrl = $textBox.Text
    if (-not $downloadUrl) {
        LogEvent "No URL provided. Please enter a valid URL."
        return
    }

    $fileName = Get-FilenameFromUrl $downloadUrl
    $filePath = [System.IO.Path]::Combine($downloadLocation, $fileName)

    $download = [Download]::new()
    $download.Url = $downloadUrl
    $download.FilePath = $filePath
    $download.TotalSize = Get-FileSize $downloadUrl

    if ($download.TotalSize -eq 0) {
        LogEvent "Download aborted due to unknown file size."
        return
    }

    $rowIndex = $dataGridView.Rows.Add($download.Url, $download.FilePath, 0, "In Progress")
    
    Start-Download -Download $download
})

[System.Windows.Forms.Application]::Run($form)
