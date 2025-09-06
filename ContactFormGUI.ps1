Function Show-ContactDeveloperForm {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    # Create Form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Contact the Developer"
    $form.Size = New-Object System.Drawing.Size(500, 480)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false

    # Labels & TextBoxes
    $lblName = New-Object System.Windows.Forms.Label
    $lblName.Text = "Your Name:"
    $lblName.Location = New-Object System.Drawing.Point(30,30)
    $lblName.AutoSize = $true
    $form.Controls.Add($lblName)

    $txtName = New-Object System.Windows.Forms.TextBox
    $txtName.Location = New-Object System.Drawing.Point(150, 25)
    $txtName.Width = 300
    $form.Controls.Add($txtName)

    $lblEmail = New-Object System.Windows.Forms.Label
    $lblEmail.Text = "Your Email:"
    $lblEmail.Location = New-Object System.Drawing.Point(30,70)
    $lblEmail.AutoSize = $true
    $form.Controls.Add($lblEmail)

    $txtEmail = New-Object System.Windows.Forms.TextBox
    $txtEmail.Location = New-Object System.Drawing.Point(150, 65)
    $txtEmail.Width = 300
    $form.Controls.Add($txtEmail)

    $lblSubject = New-Object System.Windows.Forms.Label
    $lblSubject.Text = "Subject:"
    $lblSubject.Location = New-Object System.Drawing.Point(30,110)
    $lblSubject.AutoSize = $true
    $form.Controls.Add($lblSubject)

    $txtSubject = New-Object System.Windows.Forms.TextBox
    $txtSubject.Location = New-Object System.Drawing.Point(150, 105)
    $txtSubject.Width = 300
    $form.Controls.Add($txtSubject)

    $lblMessage = New-Object System.Windows.Forms.Label
    $lblMessage.Text = "Message:"
    $lblMessage.Location = New-Object System.Drawing.Point(30,150)
    $lblMessage.AutoSize = $true
    $form.Controls.Add($lblMessage)

    $txtMessage = New-Object System.Windows.Forms.TextBox
    $txtMessage.Location = New-Object System.Drawing.Point(150, 145)
    $txtMessage.Width = 300
    $txtMessage.Height = 180
    $txtMessage.Multiline = $true
    $txtMessage.ScrollBars = "Vertical"
    $form.Controls.Add($txtMessage)

    # Buttons
    $btnSend = New-Object System.Windows.Forms.Button
    $btnSend.Text = "Send"
    $btnSend.Location = New-Object System.Drawing.Point(150, 350)
    $btnSend.Width = 100
    $form.Controls.Add($btnSend)

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Cancel"
    $btnCancel.Location = New-Object System.Drawing.Point(270, 350)
    $btnCancel.Width = 100
    $form.Controls.Add($btnCancel)

    # Spinner (loading label)
    $lblSpinner = New-Object System.Windows.Forms.Label
    $lblSpinner.Text = "Sending..."
    $lblSpinner.Location = New-Object System.Drawing.Point(150, 390)
    $lblSpinner.AutoSize = $true
    $lblSpinner.ForeColor = "Blue"
    $lblSpinner.Visible = $false
    $form.Controls.Add($lblSpinner)

    # Cancel action
    $btnCancel.Add_Click({ $form.Close() })

    # Validate Email Function
    function Test-ValidEmail {
        param([string]$email)
        return $email -match '^[^@\s]+@[^@\s]+\.[^@\s]+$'
    }

    # Send action
    $btnSend.Add_Click({
        # Validation
        if ([string]::IsNullOrWhiteSpace($txtName.Text)) {
            [System.Windows.Forms.MessageBox]::Show("Name is required.","Missing/Invalid","OK","Error"); return
        }
        if ([string]::IsNullOrWhiteSpace($txtEmail.Text)) {
            [System.Windows.Forms.MessageBox]::Show("Email is required.","Missing/Invalid","OK","Error"); return
        }
        if (-not (Test-ValidEmail $txtEmail.Text)) {
            [System.Windows.Forms.MessageBox]::Show("Please enter a valid email address.","Missing/Invalid","OK","Error"); return
        }
        if ([string]::IsNullOrWhiteSpace($txtSubject.Text)) {
            [System.Windows.Forms.MessageBox]::Show("Subject is required.","Missing/Invalid","OK","Error"); return
        }
        if ([string]::IsNullOrWhiteSpace($txtMessage.Text)) {
            [System.Windows.Forms.MessageBox]::Show("Message is required.","Missing/Invalid","OK","Error"); return
        }

        # Show spinner and disable button
        $lblSpinner.Visible = $true
        $btnSend.Enabled = $false
        $form.Refresh()

        $success = $false
        $errorMsg = ""

        try {
            # === First try SMTP ===
            $smtpServer = "smtp.office365.com"
            $smtpPort   = 587
            $from       = $txtEmail.Text
            $to         = "yourmail@domain.com"   # replace with your address
            $subject    = $txtSubject.Text
            $body       = "Name: $($txtName.Text)`r`nEmail: $($txtEmail.Text)`r`n`r`nMessage:`r`n$($txtMessage.Text)"

            $cred = New-Object System.Net.NetworkCredential("yourmail@domain.com","YourPasswordHere")

            Send-MailMessage -From $from -To $to -Subject $subject -Body $body -SmtpServer $smtpServer -Port $smtpPort -UseSsl -Credential $cred

            $success = $true
        }
        catch {
            $errorMsg = $_.Exception.Message
            try {
                # === Fall back to Formspree ===
                $formspreeEndpoint = "<FormsPree Endpoint>"   # your endpoint

                $bodyFs = @{
                    name    = $txtName.Text
                    email   = $txtEmail.Text
                    subject = $txtSubject.Text
                    message = $txtMessage.Text
                }

                Invoke-RestMethod -Uri $formspreeEndpoint -Method Post -Body $bodyFs -ContentType "application/x-www-form-urlencoded"
                $success = $true
            }
            catch {
                $errorMsg = $_.Exception.Message
            }
        }

        # Hide spinner and enable button
        $lblSpinner.Visible = $false
        $btnSend.Enabled = $true

        if ($success) {
            [System.Windows.Forms.MessageBox]::Show("Your message has been sent successfully.","Success","OK","Information")

            # Clear form
            $txtName.Text = ""
            $txtEmail.Text = ""
            $txtSubject.Text = ""
            $txtMessage.Text = ""
        }
        else {
            [System.Windows.Forms.MessageBox]::Show("Failed to send message. Error: $errorMsg","Error","OK","Error")
        }
    })

    # Show Form
    $form.Topmost = $true
    $form.Add_Shown({$form.Activate()})
    [void]$form.ShowDialog()
}

# Launch the form
Show-ContactDeveloperForm
