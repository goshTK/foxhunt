#!/usr/bin/wish
# Fox number
set N 8
# Field size
set min 0
set max 15
# Init vars
set foxes 0
set step 0
set but_mark ""

proc fscan {h v status} {
 global lst ref
 if {[lsearch $lst $h,$v]>=0} then {incr ref}
}

proc mark {h v status} {
 if {[.field.b$h-$v cget -text]==" "} then {.field.b$h-$v configure -text "+" -bg blue}
}

proc light {h v status} {
 global ref
 .field.b$h-$v configure -state $status
 if {[.field.b$h-$v cget -bg]=="red"} then {incr ref}
}

proc work {Str state job} {
 global lst min max foxes step N but_mark ref
 if {($job=="fscan")&&([$Str cget -text]>-1)} then {return}
 if {($job=="mark")&&([$Str cget -text]==" "||[$Str cget -text]=="+")} then {return}
 set Str [string trim $Str .field.b] 
 set crd [split $Str -]
 set X [lindex $crd 0]
 set Y [lindex $crd 1]
 set ref 0
 if {$state=="active"} then {set but_mark [.field.b$X-$Y cget -text]}
 #Horizontal & Vertical scan
 for {set i $min} {$i<=$max} {incr i} {
  if {$i!=$X} then {$job $i $Y $state}
  if {$i!=$Y} then {$job $X $i $state}
 }
 #diagonal 1 scan
 set XY [eval {expr $X+$Y}]
 if {$XY<=$max} then {
  set y $XY
  for {set x 0} {$x<=$XY} {incr x} {
   if {($x!=$X)&&($y!=$Y)} then {$job $x $y $state}
   incr y -1
  }
 } else {
  set y $max
  for {set x [eval {expr $XY-$max}]} {$x<=$max} {incr x} {
   if {($x!=$X)&&($y!=$Y)} then {$job $x $y $state}
   incr y -1
  }
 }
 #diagonal 2 scan
 if {$X>$Y} then {
  set y 0
  for {set x [eval {expr $X-$Y}]} {$x<=$max} {incr x} {
   if {($x!=$X)&&($y!=$Y)} then {$job $x $y $state}
   incr y
  }
 } else {
  set x 0
  for {set y [eval {expr $Y-$X}]} {$y<=$max} {incr y} {
   if {($x!=$X)&&($y!=$Y)} then {$job $x $y $state}
   incr x
  }
 }
 if {$job=="fscan"} then {
  .msg.vis configure -text $ref
  if {[lsearch $lst $X,$Y]>=0} then {
   .msg.fox configure -text "Fox found!!!"
   incr foxes
   .field.b$X-$Y configure -text $ref -bg red
   .msg.fnum configure -text $foxes
  } else {
     .field.b$X-$Y configure -text $ref -bg green
     .msg.fox configure -text " "
    }
  incr step
  .msg.stepnum configure -text $step
  .msg.crd configure -text $X-$Y
  if {$foxes==$N} then {tk_messageBox -title "You're winner!!!" -message "Found all foxes!!!" -type ok}
 }
 if {$job=="light"} then {
  if {$state=="normal"} then {
   .field.b$X-$Y configure -text $but_mark
   set but_mark ""
  } 
  if {$state=="active"} then {.field.b$X-$Y configure -text $ref}
 }
}

proc Arr_view {} {
 global lst min max
 set arr_txt ""
 set vw .viewer
 toplevel $vw
 wm title $vw "Debug View"
 text $vw.text -relief sunken -bd 2 -yscrollcommand "$vw.yscrl set" -setgrid 1 -undo 1 -font {Times 15} 
 scrollbar $vw.yscrl -command "$vw.text yview"
 set m_menu $vw.mainMenu
 menu $m_menu
 $vw configure -menu $m_menu
 $m_menu add command -label "Exit" -command "destroy $vw"
 pack $vw.yscrl -side right -fill y
 pack $vw.text -expand yes -fill both
 for {set y $min} {$y<=$max} {incr y} {
  for {set x $min} {$x<=$max} {incr x} {
   if {[lsearch $lst $x,$y]>=0} then {append arr_txt 1} else {append arr_txt 0}
  } 
  append arr_txt "\n"
 }
 $vw.text insert 0.0 $arr_txt         
 $vw.text configure -state disabled
}

proc New_round {} {
 global min max step foxes
 Init_lst
 set step 0
 set foxes 0
 for {set y $min} {$y<=$max} {incr y} {
  for {set x $min} {$x<=$max} {incr x} {.field.b$x-$y configure -text " " -bg gray85}
 }
 .msg.stepnum configure -text $step
 .msg.fnum configure -text $foxes
 .msg.vis configure -text " "
 .msg.fox configure -text " "
 catch {destroy .viewer}
}

proc Init_lst {} {
 global lst N min max
 set lst {}
 set try 0
 while {$try<$N} {
  set x [expr int(rand()*($max+1))]
  set y [expr int(rand()*($max+1))]
  if {[lsearch $lst $x,$y] < 0} then {
   incr try
   lappend lst $x,$y
  }
 } 
}

Init_lst
set w .
wm title $w "Fox hunter"
set MainMenu .mainMenu
menu $MainMenu
set SubMenu $MainMenu.subMenu
menu $SubMenu
$MainMenu add cascade -label "Menu" -menu $SubMenu
$w configure -menu $MainMenu
$SubMenu add command -label "New" -command New_round
$SubMenu add command -label "Debug" -command Arr_view
$SubMenu add command -label "Exit" -command exit
frame .field
pack .field -side top
frame .msg
label .msg.crd -relief raised -width 5
label .msg.fox -width 12
label .msg.ft -text "Founded: " -relief groove
label .msg.fnum -text $foxes -relief groove
label .msg.vt -text "Visible: " -relief groove
label .msg.vis -text " " -relief groove
label .msg.step -text "Step:" -relief groove
label .msg.stepnum -text $step -relief groove
pack .msg -side bottom
pack .msg.crd .msg.fox .msg.ft .msg.fnum .msg.vt .msg.vis .msg.step .msg.stepnum -side left
for {set y $min} {$y<=$max} {incr y} {
 for {set x $min} {$x<=$max} {incr x} {
  button .field.b$x-$y -command "work .field.b$x-$y zero fscan" -text " " -font "Helvetica 10" -activebackground orange -width 1 
  grid .field.b$x-$y -in .field -column $x -row $y
 }
}
wm resizable $w 0 0
bind Button <ButtonPress-3> {work %W zero mark}
bind Button <ButtonPress-2> {work %W active light}
bind Button <ButtonRelease-2> {work %W normal light} 
