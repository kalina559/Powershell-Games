cls
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

Function ticTacToeElementClick ($a, $b)
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
        $GameElements[$a,$b].Image = [system.drawing.image]::FromFile($PSScriptRoot + "\ticTacToe\" + $type)
        $GameElements[$a,$b].Name = $global:buttonType
        #Write-Host $a
        checkIfGameOver ($a,$b)
        typeChange
    }        
}

Function checkersElementClick ($a, $b)
{ 
Write-Host $GameElements[$a,$b].Name
#Write-Host [Int](($a-$global:checkedCoordinates[0])/2)
Write-Host $a, $b
#Write-Host "bialych: ", $global:whiteAmount, "  czarnych: ", $global:blackAmount
#Write-Host $global:checkedCoordinates[0], $global:checkedCoordinates[1]
    if($GameElements[$a,$b].Name -eq 'available')
    {
        if($GameElements[($global:checkedCoordinates[0]),($global:checkedCoordinates[1])].Name -eq 'black' -and $global:checkersType -eq "black")
        {
            if(($global:checkedCoordinates[0] + $global:checkedCoordinates[1])%2 -eq 0)
            {
                $GameElements[($global:checkedCoordinates[0]),($global:checkedCoordinates[1])].Image = $brownField
                $GameElements[$a,$b].Image = $blackPawnBrownField
            }
            else
            {
                $GameElements[($global:checkedCoordinates[0]),($global:checkedCoordinates[1])].Image = $whiteField
                $GameElements[$a,$b].Image = $blackPawnWhiteField
            }
            $GameElements[$a,$b].Name = 'black'
        }
        elseif($GameElements[($global:checkedCoordinates[0]),($global:checkedCoordinates[1])].Name -eq 'white' -and $global:checkersType -eq "white")
        {
            if(($global:checkedCoordinates[0] + $global:checkedCoordinates[1])%2 -eq 0)
            {
                $GameElements[($global:checkedCoordinates[0]),($global:checkedCoordinates[1])].Image = $brownField
                $GameElements[$a,$b].Image = $whitePawnBrownField
            }
            else
            {
                $GameElements[($global:checkedCoordinates[0]),($global:checkedCoordinates[1])].Image = $whiteField
                $GameElements[$a,$b].Image = $whitePawnWhiteField                
            }
            $GameElements[$a,$b].Name = 'white'
        }
        #Czyszczenie pola skad ruszyl sie pionek - ustawianie go na 'nic'
        $GameElements[($global:checkedCoordinates[0]),($global:checkedCoordinates[1])].Name = 'nic'
        
        #Realizacja bicia
        if($global:checkedCoordinates[0] - $a -eq 2 -or $global:checkedCoordinates[0] - $a -eq -2)
        {
            $aBeat = ($a + $global:checkedCoordinates[0]) / 2
            $bBeat = ($b + $global:checkedCoordinates[1]) / 2
            Write-Host $aBeat, $bBeat
            $GameElements[$aBeat, $bBeat].Image = $brownField
            $GameElements[$aBeat, $bBeat].Name = 'nic'

            #Zmniejszamy liczbe pionkow odpowiedniego gracza
            if($global:checkersType -eq "white")
            {
                $global:blackAmount = $global:blackAmount - 1
            }
            else
            {
                $global:whiteAmount = $global:whiteAmount - 1
            }

            #Informacja o zwyciezcy
            if($global:whiteAmount -eq 0)
            {
                $winWindow.Text = "Wygraly czarne"
                $winWindow.Show()
            }
            elseif($global:blackAmount -eq 0)
            {
                $winWindow.Text = "Wygraly biale!"
                $winWindow.Show()
            }
        }       
    
        #Ustawienie ruchu nastepnego gracza
        typeCheckersChange 
        
    }

    ##czyszczenie planszy z zielonych pól
    For ([int]$i=0; $i -lt 8; $i++)   
    {
        For ($j=0; $j -lt 8; $j++) 
        {               
            if($GameElements[$i,$j].Name -eq 'available')
            {
                if(($i+$j)%2 -eq 0)
                {
                    $GameElements[$i,$j].Image = $brownField
                }        
                else
                {
                    $GameElements[$i,$j].Image = $whiteField
                }
                $GameElements[$i,$j].Name = 'nic'
            }
        }
    }

    ##tworzenie krolowych
    if($b -eq 0 -and $GameElements[$a,$b].Name -eq 'white')
    {
        $GameElements[$a,$b].Name = 'whiteQueen'
        $GameElements[$a,$b].Image = $whitePawnQueenBrownField
    }
    if($b -eq 7 -and $GameElements[$a,$b].Name -eq 'black')
    {
        $GameElements[$a,$b].Name = 'blackQueen'
        $GameElements[$a,$b].Image = $blackPawnQueenBrownField
    }

    ##sprawdzanie dostapnych ruchow i bic dla pionkow
    if($GameElements[$a,$b].Name -eq 'black' -and $global:checkersType -eq "black")
    {
        #ruch wprzod
        if($GameElements[($a+1),($b+1)].Name -eq 'nic' -and (($a+1) -lt 8) -and (($b+1) -lt 8))
        {
            $GameElements[($a+1),($b+1)].Image = $availableMove
            $GameElements[($a+1),($b+1)].Name = 'available'
        } 
        if($GameElements[($a-1),($b+1)].Name -eq 'nic' -and (($a-1) -ge 0) -and (($b+1) -lt 8) )
        {
            $GameElements[($a-1),($b+1)].Image = $availableMove
            $GameElements[($a-1),($b+1)].Name = 'available'
        } 
        #bicie przez czarne
        if($GameElements[($a-1),($b+1)].Name -eq 'white' -and (($a-2) -ge 0) -and (($b+2) -lt 8) )
        {
            if($GameElements[($a-2),($b+2)].Name -eq 'nic')
            {
                $GameElements[($a-2),($b+2)].Image = $availableMove
                $GameElements[($a-2),($b+2)].Name = 'available'
            }
        } 

        if($GameElements[($a+1),($b+1)].Name -eq 'white' -and (($a+2) -ge 0) -and (($b+2) -lt 8) )
        {
            if($GameElements[($a+2),($b+2)].Name -eq 'nic')
            {
                $GameElements[($a+2),($b+2)].Image = $availableMove
                $GameElements[($a+2),($b+2)].Name = 'available'
            }
        } 

        #bicie przez czarne w tyl
        if($GameElements[($a-1),($b-1)].Name -eq 'white' -and (($a-2) -ge 0) -and (($b-2) -lt 8) )
        {
            if($GameElements[($a-2),($b-2)].Name -eq 'nic')
            {
                $GameElements[($a-2),($b-2)].Image = $availableMove
                $GameElements[($a-2),($b-2)].Name = 'available'
            }
        } 

        if($GameElements[($a+1),($b-1)].Name -eq 'white' -and (($a+2) -ge 0) -and (($b-2) -lt 8) )
        {
            if($GameElements[($a+2),($b-2)].Name -eq 'nic')
            {
                $GameElements[($a+2),($b-2)].Image = $availableMove
                $GameElements[($a+2),($b-2)].Name = 'available'
            }
        } 


        $global:checkedCoordinates = $a, $b      
    }

    if($GameElements[$a,$b].Name -eq 'white' -and $global:checkersType -eq "white")
    {
        #ruch wprzod bialymi
        if($GameElements[($a-1),($b-1)].Name -eq 'nic' -and (($a-1) -ge 0) -and (($b-1) -ge 0))
        {
            $GameElements[($a-1),($b-1)].Image = $availableMove
            $GameElements[($a-1),($b-1)].Name = 'available'
        }  
        if($GameElements[($a+1),($b-1)].Name -eq 'nic' -and (($a+1) -lt 8) -and (($b-1) -ge 0) )
        {
            $GameElements[($a+1),($b-1)].Image = $availableMove
            $GameElements[($a+1),($b-1)].Name = 'available'
        }   

        #bicie przez białe
        if($GameElements[($a-1),($b-1)].Name -eq 'black' -and (($a-2) -ge 0) -and (($b-2) -lt 8) )
        {
            if($GameElements[($a-2),($b-2)].Name -eq 'nic')
            {
                $GameElements[($a-2),($b-2)].Image = $availableMove
                $GameElements[($a-2),($b-2)].Name = 'available'
            }
        } 

        if($GameElements[($a+1),($b-1)].Name -eq 'black' -and (($a+2) -ge 0) -and (($b-2) -lt 8) )
        {
            if($GameElements[($a+2),($b-2)].Name -eq 'nic')
            {
                $GameElements[($a+2),($b-2)].Image = $availableMove
                $GameElements[($a+2),($b-2)].Name = 'available'
            }
        } 

        #bicie przez białe w tyl
        if($GameElements[($a-1),($b+1)].Name -eq 'black' -and (($a-2) -ge 0) -and (($b+2) -lt 8) )
        {
            if($GameElements[($a-2),($b+2)].Name -eq 'nic')
            {
                $GameElements[($a-2),($b+2)].Image = $availableMove
                $GameElements[($a-2),($b+2)].Name = 'available'
            }
        } 

        if($GameElements[($a+1),($b+1)].Name -eq 'black' -and (($a+2) -ge 0) -and (($b+2) -lt 8) )
        {
            if($GameElements[($a+2),($b+2)].Name -eq 'nic')
            {
                $GameElements[($a+2),($b+2)].Image = $availableMove
                $GameElements[($a+2),($b+2)].Name = 'available'
            }
        } 

        ##sprawdzanie dostapnych ruchow i bic dla krolowych
        For ([int]$i=0; $i -lt 8; $i++)   
        {
            For ($j=0; $j -lt 8; $j++) 
            {

            }
        }



        $global:checkedCoordinates = $a, $b     
    }

    
}        

Function checkersElementMove ($a, $b)
{
    
}

Function typeCheckersChange 
{    
    if($global:checkersType -eq "white")
    {
        $global:checkersType = "black"
    }
    else
    {
        $global:checkersType = "white"
    }  

    $typeCheckers.Image = [system.drawing.image]::FromFile($PSScriptRoot + "\warcaby\" + $global:checkersType + "PawnBrownField.png")              
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

    $typeButton.Image = [system.drawing.image]::FromFile($PSScriptRoot + "\ticTacToe\" + $global:buttonType + ".png")              
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


################Wybór trybu
$ModeWindow = New-Object system.Windows.Forms.Form
$ModeWindow.Width = 300
$ModeWindow.Height = 150
$ModeWindow.MaximizeBox = $False
$ModeWindow.MinimizeBox = $False
$ModeWindow.WindowState = "Normal"
$ModeWindow.SizeGripStyle = "Hide"
$ModeWindow.StartPosition = "CenterScreen"
$ModeWindow.FormBorderStyle = 'Fixed3D' #None
$ModeWindow.Text = "Tryb Gry"

$firstMode = New-Object System.Windows.Forms.RadioButton
$secondMode = New-Object System.Windows.Forms.RadioButton
$firstMode.Checked = $True
$firstMode.Name = "Warcaby"
$firstMode.Text = "Warcaby"
$firstMode.Location = New-Object System.Drawing.Point(110,10)
$secondMode.Name = "Kółko i krzyżyk"
$secondMode.Text = "Kółko i krzyżyk"
$secondMode.Location = New-Object System.Drawing.Point(110,30)
$secondMode.Width = 200
$ModeWindow.Controls.Add($firstMode)
$ModeWindow.Controls.Add($secondMode)

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
$SettingsWindow.Text = "Rozmiar planszy"###Przycisk 'dalej'
$NextButton = New-Object System.Windows.Forms.Button
$NextButton.Location=New-Object System.Drawing.Size(25,70) 
$NextButton.Size = New-Object System.Drawing.Size(250,40)
$NextButton.Font = New-Object System.Drawing.Font("Lucida Console",16,[System.Drawing.FontStyle]::Regular)
$NextButton.Text = "Rozpocznij grę"
$NextButton.Add_Click({confirmSettings($ModeWindow)})

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

#DimensionLabel
$DimensionLabel = New-Object System.Windows.Forms.Label
$DimensionLabel.Text = "Wymiar planszy"
$DimensionLabel.Width = 150
$DimensionLabel.Location=New-Object System.Drawing.Size(160,10) 

###########dodawanie obiektów do wyboru trybu
$ModeWindow.Controls.Add($NextButton)

###########dodawanie obiektów do ustawien poczatkowych
$SettingsWindow.Controls.Add($SetButton)
$SettingsWindow.Controls.Add($DimensionUpDown)
$SettingsWindow.Controls.Add($DimensionLabel)

#Okno gry w kółko i krzyżyk
$TicTacToeWindow = New-Object system.Windows.Forms.Form
$TicTacToeWindow.Width = 1000
$TicTacToeWindow.Height = 667
$TicTacToeWindow.MaximizeBox = $False
$TicTacToeWindow.MinimizeBox = $False
$TicTacToeWindow.WindowState = "Normal"
$TicTacToeWindow.SizeGripStyle = "Hide"
$TicTacToeWindow.StartPosition = "CenterScreen"
$TicTacToeWindow.FormBorderStyle = 'Fixed3D'
$TicTacToeBackground = [system.drawing.image]::FromFile($PSScriptRoot + "\ticTacToe\background.jfif")
$TicTacToeWindow.BackgroundImage = $TicTacToeBackground

#Okno gry w warcaby
$CheckersWindow = New-Object system.Windows.Forms.Form
$CheckersWindow.Width = 1000
$CheckersWindow.Height = 667
$CheckersWindow.MaximizeBox = $False
$CheckersWindow.MinimizeBox = $False
$CheckersWindow.WindowState = "Normal"
$CheckersWindow.SizeGripStyle = "Hide"
$CheckersWindow.StartPosition = "CenterScreen"
$CheckersWindow.FormBorderStyle = 'Fixed3D'
$CheckersBackground = [system.drawing.image]::FromFile($PSScriptRoot + "\warcaby\background.jpg")
$CheckersWindow.BackgroundImage = $CheckersBackground

$StartButton= New-Object System.Windows.Forms.Button
$StartButton.Location=New-Object System.Drawing.Size(350,20) 
$StartButton.Size = New-Object System.Drawing.Size(300,100)
$StartButton.Text = "Start"
$StartButton.Font = New-Object System.Drawing.Font("Lucida Console",30,[System.Drawing.FontStyle]::Regular)
$StartButton.Add_Click({startClick})
$TicTacToeWindow.controls.add($StartButton)

#zmienna do przełączania znaku, którym gra użytkownik (początkowo to kółko)
$global:buttonType = "O"

$typeButton = new-object Windows.Forms.PictureBox
$typeImage = [system.drawing.image]::FromFile($PSScriptRoot + "\ticTacToe\O.png")
$typeButton.Width = $typeImage.Size.Width
$typeButton.Height = $typeImage.Size.Height
$typeButton.Image = $typeImage
$typeButton.Location = New-Object System.Drawing.Size(900,300) 
#$typeButton.Add_Click({typeClick})
$TicTacToeWindow.controls.add($typeButton)

$typeCheckers = new-object Windows.Forms.PictureBox
$typeImage = [system.drawing.image]::FromFile($PSScriptRoot + "\warcaby\whitePawnBrownField.png")
$typeCheckers.Width = $typeImage.Size.Width
$typeCheckers.Height = $typeImage.Size.Height
$typeCheckers.Image = $typeImage
$typeCheckers.Location = New-Object System.Drawing.Size(900,300) 
#$typeButton.Add_Click({typeClick})
$CheckersWindow.controls.add($typeCheckers)






#InfoLabel - informacja o wygranej i ruchach
$infoLabel = New-Object System.Windows.Forms.Label
$infoLabel.Text = "gra w trakcie..."
$infoLabel.Location=New-Object System.Drawing.Size(475,600) 
$TicTacToeWindow.controls.add($infoLabel)

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
$Image = [system.drawing.image]::FromFile($PSScriptRoot + "\ticTacToe\field.png")

#Pola w warcabach
$brownField = [system.drawing.image]::FromFile($PSScriptRoot + "\warcaby\brownField.png")
$whiteField = [system.drawing.image]::FromFile($PSScriptRoot + "\warcaby\whiteField.png")
$whitePawnWhiteField = [system.drawing.image]::FromFile($PSScriptRoot + "\warcaby\whitePawnWhiteField.png")
$whitePawnBrownField = [system.drawing.image]::FromFile($PSScriptRoot + "\warcaby\whitePawnBrownField.png")
$blackPawnWhiteField = [system.drawing.image]::FromFile($PSScriptRoot + "\warcaby\blackPawnWhiteField.png")
$blackPawnBrownField = [system.drawing.image]::FromFile($PSScriptRoot + "\warcaby\blackPawnBrownField.png")
$availableMove = [system.drawing.image]::FromFile($PSScriptRoot + "\warcaby\availableMove.png")
$availableMoveWhitePawn = [system.drawing.image]::FromFile($PSScriptRoot + "\warcaby\availableMoveWhitePawn.png")
$availableMoveBlackPawn = [system.drawing.image]::FromFile($PSScriptRoot + "\warcaby\availableMoveBlackPawn.png")
$whitePawnQueenBrownField = [system.drawing.image]::FromFile($PSScriptRoot + "\warcaby\whitePawnQueenBrownField.png")
$blackPawnQueenBrownField = [system.drawing.image]::FromFile($PSScriptRoot + "\warcaby\blackPawnQueenBrownField.png")

#Gra
$ModeWindow.ShowDialog()
if($secondMode.Checked)   ##jeśli wybrane kółko i krzyżyk to wyświetlają się ustawienia (rozmiar planszy)
    {
    $SettingsWindow.ShowDialog()
    }


if($secondMode.Checked)   ##tworzenie pól do kółka i krzyżyk
{
    #Obiekty wstawione dynamicznie, po ustawieniu opcji
    $GameElements = New-Object 'object[,]' ($DimensionUpDown.Value),($DimensionUpDown.Value)
    #Tablica przechowujaca dane o polach, 0 - puste, 1 - krzyzyk, 2 - kolko
    [int[,]]$GameData = [int[,]]::new(($WidthUpDown.Value),($HeightUpDown.Value))

    $global:isWin=0      #0 - rozgrywka trwa, 1 - zwycięstwo, -1 - porażka

        #Tworzenie pól ( niestety nie da się tego ładnie zrobić, trzeba switch casem)
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
        
                00 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 0 0})}
                01 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 0 1})}
                02 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 0 2})}
                03 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 0 3})}
                04 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 0 4})}
                05 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 0 5})}
                06 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 0 6})}
                07 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 0 7})}
                10 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 1 0})}
                11 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 1 1})}
                12 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 1 2})}
                13 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 1 3})}
                14 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 1 4})}
                15 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 1 5})}
                16 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 1 6})}
                17 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 1 7})}
                20 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 2 0})}
                21 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 2 1})}
                22 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 2 2})}
                23 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 2 3})}
                24 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 2 4})}
                25 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 2 5})}
                26 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 2 6})}
                27 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 2 7})}
                30 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 3 0})}
                31 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 3 1})}
                32 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 3 2})}
                33 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 3 3})}
                34 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 3 4})}
                35 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 3 5})}
                36 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 3 6})}
                37 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 3 7})}
                40 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 4 0})}
                41 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 4 1})}
                42 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 4 2})}
                43 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 4 3})}
                44 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 4 4})}
                45 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 4 5})}
                46 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 4 6})}
                47 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 4 7})}
                50 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 5 0})}
                51 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 5 1})}
                52 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 5 2})}
                53 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 5 3})}
                54 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 5 4})}
                55 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 5 5})}
                56 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 5 6})}
                57 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 5 7})}
                60 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 6 0})}
                61 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 6 1})}
                62 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 6 2})}
                63 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 6 3})}
                64 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 6 4})}
                65 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 6 5})}
                66 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 6 6})}
                67 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 6 7})}
                70 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 7 0})}
                71 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 7 1})}
                72 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 7 2})}
                73 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 7 3})}
                74 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 7 4})}
                75 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 7 5})}
                76 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 7 6})}
                77 {$GameElements[$i,$j].Add_Click({ticTacToeElementClick 7 7})}
            }

            $TicTacToeWindow.controls.add(($GameElements[$i,$j]))
        }  
    }

    $TicTacToeWindow.ShowDialog()
}

###################################### WARCABY

if($firstMode.Checked)   ##tworzenie pól do kółka i krzyżyk
{
    #Obiekty wstawione dynamicznie, po ustawieniu opcji
    $GameElements = New-Object 'object[,]' (8),(8)
    #Tablica przechowujaca dane o polach, 0 - puste, 1 - krzyzyk, 2 - kolko
    [int[,]]$GameData = [int[,]]::new((8),(8))

    $global:isWin=0      #0 - rozgrywka trwa, 1 - zwycięstwo, -1 - porażka

    $global:checkedCoordinates = 100,100

#zmienna do przełączania koloru pionka, którym gra użytkownik (początkowo to bialy)
$global:checkersType = "white"

#liczbyPionkow
$global:whiteAmount = 12
$global:blackAmount = 12

        #Tworzenie pól ( niestety nie da się tego ładnie zrobić, trzeba switch casem)
For ([int]$i=0; $i -lt 8; $i++) 
    {
        For ($j=0; $j -lt 8; $j++) 
        {                  
            $GameElements[$i,$j] = new-object Windows.Forms.PictureBox
            $GameElements[$i,$j].Width = $Image.Size.Width
            $GameElements[$i,$j].Height = $Image.Size.Height
            
            
            if(($i+$j)%2 -eq 0)
            {
            
                
                if($j -lt 3)
                {
                    $GameElements[$i,$j].Image = $blackPawnBrownField
                    $GameElements[$i,$j].Name='black'
                }
                elseif($j -gt 4)
                {
                    $GameElements[$i,$j].Image = $whitePawnBrownField
                    $GameElements[$i,$j].Name='white'
                }
                else
                {
                    $GameElements[$i,$j].Image = $brownField
                    $GameElements[$i,$j].Name='nic'
                }
            }
            else
            {            
                $GameElements[$i,$j].Image = $WhiteField
                $GameElements[$i,$j].Name='nic'
            }
            
            $GameElements[$i,$j].Visible=1
            $GameElements[$i,$j].Location = New-Object System.Drawing.Size((300+ $i * $Image.Width),(100 + $j*$Image.Height))
                   

            $temp =10*$i+$j
            switch($temp)
            {
        
                00 {$GameElements[$i,$j].Add_Click({checkersElementClick 0 0})}
                01 {$GameElements[$i,$j].Add_Click({checkersElementClick 0 1})}
                02 {$GameElements[$i,$j].Add_Click({checkersElementClick 0 2})}
                03 {$GameElements[$i,$j].Add_Click({checkersElementClick 0 3})}
                04 {$GameElements[$i,$j].Add_Click({checkersElementClick 0 4})}
                05 {$GameElements[$i,$j].Add_Click({checkersElementClick 0 5})}
                06 {$GameElements[$i,$j].Add_Click({checkersElementClick 0 6})}
                07 {$GameElements[$i,$j].Add_Click({checkersElementClick 0 7})}
                10 {$GameElements[$i,$j].Add_Click({checkersElementClick 1 0})}
                11 {$GameElements[$i,$j].Add_Click({checkersElementClick 1 1})}
                12 {$GameElements[$i,$j].Add_Click({checkersElementClick 1 2})}
                13 {$GameElements[$i,$j].Add_Click({checkersElementClick 1 3})}
                14 {$GameElements[$i,$j].Add_Click({checkersElementClick 1 4})}
                15 {$GameElements[$i,$j].Add_Click({checkersElementClick 1 5})}
                16 {$GameElements[$i,$j].Add_Click({checkersElementClick 1 6})}
                17 {$GameElements[$i,$j].Add_Click({checkersElementClick 1 7})}
                20 {$GameElements[$i,$j].Add_Click({checkersElementClick 2 0})}
                21 {$GameElements[$i,$j].Add_Click({checkersElementClick 2 1})}
                22 {$GameElements[$i,$j].Add_Click({checkersElementClick 2 2})}
                23 {$GameElements[$i,$j].Add_Click({checkersElementClick 2 3})}
                24 {$GameElements[$i,$j].Add_Click({checkersElementClick 2 4})}
                25 {$GameElements[$i,$j].Add_Click({checkersElementClick 2 5})}
                26 {$GameElements[$i,$j].Add_Click({checkersElementClick 2 6})}
                27 {$GameElements[$i,$j].Add_Click({checkersElementClick 2 7})}
                30 {$GameElements[$i,$j].Add_Click({checkersElementClick 3 0})}
                31 {$GameElements[$i,$j].Add_Click({checkersElementClick 3 1})}
                32 {$GameElements[$i,$j].Add_Click({checkersElementClick 3 2})}
                33 {$GameElements[$i,$j].Add_Click({checkersElementClick 3 3})}
                34 {$GameElements[$i,$j].Add_Click({checkersElementClick 3 4})}
                35 {$GameElements[$i,$j].Add_Click({checkersElementClick 3 5})}
                36 {$GameElements[$i,$j].Add_Click({checkersElementClick 3 6})}
                37 {$GameElements[$i,$j].Add_Click({checkersElementClick 3 7})}
                40 {$GameElements[$i,$j].Add_Click({checkersElementClick 4 0})}
                41 {$GameElements[$i,$j].Add_Click({checkersElementClick 4 1})}
                42 {$GameElements[$i,$j].Add_Click({checkersElementClick 4 2})}
                43 {$GameElements[$i,$j].Add_Click({checkersElementClick 4 3})}
                44 {$GameElements[$i,$j].Add_Click({checkersElementClick 4 4})}
                45 {$GameElements[$i,$j].Add_Click({checkersElementClick 4 5})}
                46 {$GameElements[$i,$j].Add_Click({checkersElementClick 4 6})}
                47 {$GameElements[$i,$j].Add_Click({checkersElementClick 4 7})}
                50 {$GameElements[$i,$j].Add_Click({checkersElementClick 5 0})}
                51 {$GameElements[$i,$j].Add_Click({checkersElementClick 5 1})}
                52 {$GameElements[$i,$j].Add_Click({checkersElementClick 5 2})}
                53 {$GameElements[$i,$j].Add_Click({checkersElementClick 5 3})}
                54 {$GameElements[$i,$j].Add_Click({checkersElementClick 5 4})}
                55 {$GameElements[$i,$j].Add_Click({checkersElementClick 5 5})}
                56 {$GameElements[$i,$j].Add_Click({checkersElementClick 5 6})}
                57 {$GameElements[$i,$j].Add_Click({checkersElementClick 5 7})}
                60 {$GameElements[$i,$j].Add_Click({checkersElementClick 6 0})}
                61 {$GameElements[$i,$j].Add_Click({checkersElementClick 6 1})}
                62 {$GameElements[$i,$j].Add_Click({checkersElementClick 6 2})}
                63 {$GameElements[$i,$j].Add_Click({checkersElementClick 6 3})}
                64 {$GameElements[$i,$j].Add_Click({checkersElementClick 6 4})}
                65 {$GameElements[$i,$j].Add_Click({checkersElementClick 6 5})}
                66 {$GameElements[$i,$j].Add_Click({checkersElementClick 6 6})}
                67 {$GameElements[$i,$j].Add_Click({checkersElementClick 6 7})}
                70 {$GameElements[$i,$j].Add_Click({checkersElementClick 7 0})}
                71 {$GameElements[$i,$j].Add_Click({checkersElementClick 7 1})}
                72 {$GameElements[$i,$j].Add_Click({checkersElementClick 7 2})}
                73 {$GameElements[$i,$j].Add_Click({checkersElementClick 7 3})}
                74 {$GameElements[$i,$j].Add_Click({checkersElementClick 7 4})}
                75 {$GameElements[$i,$j].Add_Click({checkersElementClick 7 5})}
                76 {$GameElements[$i,$j].Add_Click({checkersElementClick 7 6})}
                77 {$GameElements[$i,$j].Add_Click({checkersElementClick 7 7})}
            }

            $CheckersWindow.controls.add(($GameElements[$i,$j]))
        }  
    }

    $CheckersWindow.ShowDialog()
}

