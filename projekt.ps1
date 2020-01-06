[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

Function confirmSettings ($Form) 
{
    $Form.Close()             
}

Function startClick
{
    if ($StartButton.Text -eq "Start")
    {
        $StartButton.Text = "Restart"
        For ([int]$i=0; $i -lt $DimensionUpDown.Value; $i++) 
        {

            For ($j=0; $j -lt $DimensionUpDown.Value; $j++) 
            {
                $GameElements[$i,$j].Visible=1
                $GameElements[$i,$j].Name='nic'
            }
         }        

    }
    elseif ($StartButton.Text -eq "Restart")
    {
        For ([int]$i=0; $i -lt $DimensionUpDown.Value; $i++) 
        {
            For ($j=0; $j -lt $DimensionUpDown.Value; $j++) 
            {
                try{$Global:ElementsOrder.RemoveAt(0)} catch {}
                $GameElements[$i,$j].Image =$Image
                $GameElements[$i,$j].Visible=1
                $GameElements[$i,$j].Name='nic'
            }
        }
    }  
    
    $infoLabel.Text = "gra w trakcie..."         
}

Function restartAfterWin ($Form) 
{
    $Form.Text = "Wygrywa: " + $global:buttonType
    $Form.Hide()
    startClick 
    $infoLabel.Text = "gra w trakcie..."
}

Function elementClick ($a, $b)
{
    [string] $type
    if($global:buttonType -eq "X")
    {
    $type = "X.png"
    }
    elseif($global:buttonType -eq "O")
    {
    $type = "O.png"
    }    

    #Blokada dodania elementu jesli jakis juz jest w danym polu (0 - pole puste)
    if($GameElements[$a,$b].Name -eq 'nic')
    {
        $GameElements[$a,$b].Image = [system.drawing.image]::FromFile($PSScriptRoot + "\" + $type)
        $GameElements[$a,$b].Name = $global:buttonType
        #Write-Host $a
        checkIfGameOver ($a,$b)
        typeChange
    }        
}

Function typeChange 
{    
    if($global:buttonType -eq "O")
    {
        $global:buttonType = "X"
    }
    else
    {
        $global:buttonType = "O"
    }  

    $typeButton.Image = [system.drawing.image]::FromFile($PSScriptRoot + "\" + $global:buttonType + ".png")              
}

Function checkIfGameOver ($a,$b)
{
    #Write-Host $DimensionUpDown.Value

    [string] $winO = ("OOOOOOO").Substring(0, $DimensionUpDown.Value)
    [string] $winX = ("XXXXXXX").Substring(0, $DimensionUpDown.Value)
    [string] $checkHeight = ""
    [string] $checkWidth = ""
    [string] $checkDiagonal1 = ""
    [string] $checkDiagonal2 = ""
    #Write-Host $winO
    #Write-Host $a[0]#0-pion 1-poziom
    #Write-Host $a[1]

    For ([int]$i=0; $i -lt $DimensionUpDown.Value; $i++) 
    {
        For ([int]$j=0; $j -lt $DimensionUpDown.Value; $j++) 
        {
            Write-Host $GameElements[$i, $j].Name
            $checkHeight = $checkHeight + $GameElements[$i, $j].Name
            $checkWidth = $checkWidth + $GameElements[$j, $i].Name
            $checkDiagonal1 = $checkDiagonal1 + $GameElements[$j, $j].Name
            $checkDiagonal2 = $checkDiagonal2 + $GameElements[[int]($DimensionUpDown.Value-$j-1), $j].Name
        }

        Write-Host $checkHeight
        
        if($checkWidth -eq $winO -or $checkHeight -eq $winO -or $checkDiagonal1 -eq $winO -or $checkDiagonal2 -eq $winO)
        {
            $infoLabel.Text = "Wygrana: O"
            $winWindow.Show()
        }
        elseif($checkWidth -eq $winX -or $checkHeight -eq $winX -or $checkDiagonal1 -eq $winX -or $checkDiagonal2 -eq $winX)
        {
            $infoLabel.Text = "Wygrana: X"
            $winWindow.Show()
        }
        else
        {
            $checkHeight = ""
            $checkWidth = ""
            $checkDiagonal1=""
            $checkDiagonal2=""
        }
    }
} 

##############################################Ustawienia początkowe użytkownika
#Okno ustawień
$SettingsWindow = New-Object system.Windows.Forms.Form
$SettingsWindow.Width = 300
$SettingsWindow.Height = 150
$SettingsWindow.MaximizeBox = $False
$SettingsWindow.MinimizeBox = $False
$SettingsWindow.WindowState = "Normal"
$SettingsWindow.SizeGripStyle = "Hide"
$SettingsWindow.StartPosition = "CenterScreen"
$SettingsWindow.FormBorderStyle = 'Fixed3D' #None
$SettingsWindow.Text = "Rozmiar planszy"

#SetButton 
$SetButton = New-Object System.Windows.Forms.Button
$SetButton.Location=New-Object System.Drawing.Size(25,70) 
$SetButton.Size = New-Object System.Drawing.Size(250,40)
$SetButton.Font = New-Object System.Drawing.Font("Lucida Console",16,[System.Drawing.FontStyle]::Regular)
$SetButton.Text = "Rozpocznij grę"
$SetButton.Add_Click({confirmSettings($SettingsWindow)})

#WidthUpDown - ile kolumn w grze
$DimensionUpDown = New-Object System.Windows.Forms.NumericUpDown
$DimensionUpDown.Location=New-Object System.Drawing.Size(100,10) 
$DimensionUpDown.Width = 50
$DimensionUpDown.Value=6
$DimensionUpDown.Maximum=7
$DimensionUpDown.Minimum=3

#HeightLabel
$DimensionLabel = New-Object System.Windows.Forms.Label
$DimensionLabel.Text = "ilość kolumn"
$DimensionLabel.Location=New-Object System.Drawing.Size(160,10) 

###########dodawanie obiektów do ustawien poczatkowych

$SettingsWindow.Controls.Add($SetButton)
$SettingsWindow.Controls.Add($DimensionUpDown)
$SettingsWindow.Controls.Add($DimensionLabel)

#Okno gry
$GameWindow = New-Object system.Windows.Forms.Form
$GameWindow.Width = 1000
$GameWindow.Height = 667
$GameWindow.MaximizeBox = $False
$GameWindow.MinimizeBox = $False
$GameWindow.WindowState = "Normal"
$GameWindow.SizeGripStyle = "Hide"
$GameWindow.StartPosition = "CenterScreen"
$GameWindow.FormBorderStyle = 'Fixed3D'

#Obiekty w oknie głównym
$GameImage = [system.drawing.image]::FromFile($PSScriptRoot + "\background.jfif")
$GameWindow.BackgroundImage = $GameImage

$StartButton= New-Object System.Windows.Forms.Button
$StartButton.Location=New-Object System.Drawing.Size(350,20) 
$StartButton.Size = New-Object System.Drawing.Size(300,100)
$StartButton.Text = "Start"
$StartButton.Font = New-Object System.Drawing.Font("Lucida Console",30,[System.Drawing.FontStyle]::Regular)
$StartButton.Add_Click({startClick})
$GameWindow.controls.add($StartButton)

#zmienna do przełączania znaku, którym gra użytkownik (początkowo to kółko)
$global:buttonType = "O"

$typeButton = new-object Windows.Forms.PictureBox
$typeImage = [system.drawing.image]::FromFile($PSScriptRoot + "\O.png")
$typeButton.Width = $typeImage.Size.Width
$typeButton.Height = $typeImage.Size.Height
$typeButton.Image = $typeImage
$typeButton.Location = New-Object System.Drawing.Size(900,300) 
#$typeButton.Add_Click({typeClick})
$GameWindow.controls.add($typeButton)

#InfoLabel - informacja o wygranej i ruchach
$infoLabel = New-Object System.Windows.Forms.Label
$infoLabel.Text = "gra w trakcie..."
$infoLabel.Location=New-Object System.Drawing.Size(475,600) 
$GameWindow.controls.add($infoLabel)

#Okno informujace o wygranej
$winWindow = New-Object system.Windows.Forms.Form
$winWindow.Width = 400
$winWindow.Height = 250
$winWindow.MaximizeBox = $False
$winWindow.MinimizeBox = $False
$winWindow.WindowState = "Normal"
$winWindow.SizeGripStyle = "Hide"
$winWindow.StartPosition = "CenterScreen"
$winWindow.FormBorderStyle = 'Fixed3D' #None
$winWindow.Text = ""

#Button do restartu gry po wygranej
$restartButton = New-Object System.Windows.Forms.Button
$restartButton.Location=New-Object System.Drawing.Size(25,70) 
$restartButton.Size = New-Object System.Drawing.Size(300,50)
$restartButton.Font = New-Object System.Drawing.Font("Lucida Console",14,[System.Drawing.FontStyle]::Regular)
$restartButton.Text = "Zagraj ponownie!"
$restartButton.Add_Click({restartAfterWin($winWindow)})

###########dodawanie obiektów do ustawien poczatkowych
$winWindow.Controls.Add($restartButton)


#Image - obraz który jest początkowo na GameElementach, po prostu pusty kwadrat
$Image = [system.drawing.image]::FromFile($PSScriptRoot + "\field.png")

#Gra
$SettingsWindow.ShowDialog()
#Obiekty wstawione dynamicznie, po ustawieniu opcji
$GameElements = New-Object 'object[,]' ($DimensionUpDown.Value),($DimensionUpDown.Value)
#Tablica przechowujaca dane o polach, 0 - puste, 1 - krzyzyk, 2 - kolko
[int[,]]$GameData = [int[,]]::new(($WidthUpDown.Value),($HeightUpDown.Value))

$global:isWin=0      #0 - rozgrywka trwa, 1 - zwycięstwo, -1 - porażka

#Tworzenie pól ( Bartek mówił że niestety nie da się tego ładnie zrobić, trzeba switch casem)
For ([int]$i=0; $i -lt $DimensionUpDown.Value; $i++) 
{
    For ($j=0; $j -lt $DimensionUpDown.Value; $j++) 
    {                  
        $GameElements[$i,$j] = new-object Windows.Forms.PictureBox
        $GameElements[$i,$j].Width = $Image.Size.Width
        $GameElements[$i,$j].Height = $Image.Size.Height
        $GameElements[$i,$j].Image = $Image
        $GameElements[$i,$j].Visible=0
        $GameElements[$i,$j].Location = New-Object System.Drawing.Size((300+ $i * $Image.Width),(150 + $j*$Image.Height))
        $GameElements[$i,$j].Name='nic'       

        $temp =10*$i+$j
        switch($temp)
        {
        
        00 {$GameElements[$i,$j].Add_Click({elementClick 0 0})}
        01 {$GameElements[$i,$j].Add_Click({elementClick 0 1})}
        02 {$GameElements[$i,$j].Add_Click({elementClick 0 2})}
        03 {$GameElements[$i,$j].Add_Click({elementClick 0 3})}
        04 {$GameElements[$i,$j].Add_Click({elementClick 0 4})}
        05 {$GameElements[$i,$j].Add_Click({elementClick 0 5})}
        06 {$GameElements[$i,$j].Add_Click({elementClick 0 6})}
        07 {$GameElements[$i,$j].Add_Click({elementClick 0 7})}
        10 {$GameElements[$i,$j].Add_Click({elementClick 1 0})}
        11 {$GameElements[$i,$j].Add_Click({elementClick 1 1})}
        12 {$GameElements[$i,$j].Add_Click({elementClick 1 2})}
        13 {$GameElements[$i,$j].Add_Click({elementClick 1 3})}
        14 {$GameElements[$i,$j].Add_Click({elementClick 1 4})}
        15 {$GameElements[$i,$j].Add_Click({elementClick 1 5})}
        16 {$GameElements[$i,$j].Add_Click({elementClick 1 6})}
        17 {$GameElements[$i,$j].Add_Click({elementClick 1 7})}
        20 {$GameElements[$i,$j].Add_Click({elementClick 2 0})}
        21 {$GameElements[$i,$j].Add_Click({elementClick 2 1})}
        22 {$GameElements[$i,$j].Add_Click({elementClick 2 2})}
        23 {$GameElements[$i,$j].Add_Click({elementClick 2 3})}
        24 {$GameElements[$i,$j].Add_Click({elementClick 2 4})}
        25 {$GameElements[$i,$j].Add_Click({elementClick 2 5})}
        26 {$GameElements[$i,$j].Add_Click({elementClick 2 6})}
        27 {$GameElements[$i,$j].Add_Click({elementClick 2 7})}
        30 {$GameElements[$i,$j].Add_Click({elementClick 3 0})}
        31 {$GameElements[$i,$j].Add_Click({elementClick 3 1})}
        32 {$GameElements[$i,$j].Add_Click({elementClick 3 2})}
        33 {$GameElements[$i,$j].Add_Click({elementClick 3 3})}
        34 {$GameElements[$i,$j].Add_Click({elementClick 3 4})}
        35 {$GameElements[$i,$j].Add_Click({elementClick 3 5})}
        36 {$GameElements[$i,$j].Add_Click({elementClick 3 6})}
        37 {$GameElements[$i,$j].Add_Click({elementClick 3 7})}
        40 {$GameElements[$i,$j].Add_Click({elementClick 4 0})}
        41 {$GameElements[$i,$j].Add_Click({elementClick 4 1})}
        42 {$GameElements[$i,$j].Add_Click({elementClick 4 2})}
        43 {$GameElements[$i,$j].Add_Click({elementClick 4 3})}
        44 {$GameElements[$i,$j].Add_Click({elementClick 4 4})}
        45 {$GameElements[$i,$j].Add_Click({elementClick 4 5})}
        46 {$GameElements[$i,$j].Add_Click({elementClick 4 6})}
        47 {$GameElements[$i,$j].Add_Click({elementClick 4 7})}
        50 {$GameElements[$i,$j].Add_Click({elementClick 5 0})}
        51 {$GameElements[$i,$j].Add_Click({elementClick 5 1})}
        52 {$GameElements[$i,$j].Add_Click({elementClick 5 2})}
        53 {$GameElements[$i,$j].Add_Click({elementClick 5 3})}
        54 {$GameElements[$i,$j].Add_Click({elementClick 5 4})}
        55 {$GameElements[$i,$j].Add_Click({elementClick 5 5})}
        56 {$GameElements[$i,$j].Add_Click({elementClick 5 6})}
        57 {$GameElements[$i,$j].Add_Click({elementClick 5 7})}
        60 {$GameElements[$i,$j].Add_Click({elementClick 6 0})}
        61 {$GameElements[$i,$j].Add_Click({elementClick 6 1})}
        62 {$GameElements[$i,$j].Add_Click({elementClick 6 2})}
        63 {$GameElements[$i,$j].Add_Click({elementClick 6 3})}
        64 {$GameElements[$i,$j].Add_Click({elementClick 6 4})}
        65 {$GameElements[$i,$j].Add_Click({elementClick 6 5})}
        66 {$GameElements[$i,$j].Add_Click({elementClick 6 6})}
        67 {$GameElements[$i,$j].Add_Click({elementClick 6 7})}
        70 {$GameElements[$i,$j].Add_Click({elementClick 7 0})}
        71 {$GameElements[$i,$j].Add_Click({elementClick 7 1})}
        72 {$GameElements[$i,$j].Add_Click({elementClick 7 2})}
        73 {$GameElements[$i,$j].Add_Click({elementClick 7 3})}
        74 {$GameElements[$i,$j].Add_Click({elementClick 7 4})}
        75 {$GameElements[$i,$j].Add_Click({elementClick 7 5})}
        76 {$GameElements[$i,$j].Add_Click({elementClick 7 6})}
        77 {$GameElements[$i,$j].Add_Click({elementClick 7 7})}
        }
        $GameWindow.controls.add(($GameElements[$i,$j]))
    }  
}

$GameWindow.ShowDialog()

