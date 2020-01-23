
;TODO styles für div Moveknops
;TODO 

XIncludeFile "movebutton3.pbi"

EnableExplicit

Enumeration
   #mainwindow
   #fontwindow
   #container1
   #container2
   
   #combobox_theme
   #combobox_color   
   #combobox_style
   
   #knop_Font
   #Knop_Save   
   #knop_Tinfo   
   #knop_Speed   
   #trackbar_info
   #trackbar_speed
   
   #colorBox
   #colorBoxRGB
   #colorBoxGradient
   
   #knop_Test: #knop_Test1: #knop_Test2: #knop_Test3: #knop_Test4: #knop_Test5: #knop_Test6: 
   #knop_Test11: #knop_Test12: #knop_Test13: 
   
   #fontnr : #fontnr2   
EndEnumeration

Procedure.i GetColorUnderMouse() 
   Protected color, cursorPos.POINT, dc = GetDC_(0)      
   GetCursorPos_(cursorPos)    
   color = GetPixel_(dc, cursorPos\x, cursorPos\y) 
   ReleaseDC_(0, dc)       
   ProcedureReturn color
EndProcedure 

Procedure.i ColorBoxRGB(pbnr)   
   ;erstellt Farbtafel   
   Protected w = GadgetWidth(pbnr), h = GadgetHeight(pbnr)   
   Protected ch.d = 1 / 7.15 : ;Debug chh
   
   StartDrawing(CanvasOutput(pbnr))         
      DrawingMode(#PB_2DDrawing_Gradient)
      BackColor(#Red) 
      GradientColor(ch*1, #Yellow)
      GradientColor(ch*2, #Green)
      GradientColor(ch*3, #Cyan)
      GradientColor(ch*4, #Blue)
      GradientColor(ch*5, #Magenta)
      GradientColor(ch*6, #Red)
      GradientColor(ch*7, #Gray)
      FrontColor(#Gray)
      LinearGradient(0, 0, 0, h)
      Box(0, 0, w, h) 
      DrawingMode(#PB_2DDrawing_Transparent)
      DrawRotatedText(w-5, h/1.5, "© HJBremer", 270, #Gray)
   StopDrawing()   
EndProcedure

Procedure.i ColorBoxGradient(pbnr, color, text$="")   
   ;erstellt Farbtafel
   Protected th, t$ = "Farbe"      
   Protected x, y, w = GadgetWidth(pbnr), h = GadgetHeight(pbnr)
   Protected j, p.d
   Static fid
   
   If fid = 0: fid = FontID(LoadFont(#PB_Any, "Consolas", 9)): EndIf
   
   StartDrawing(CanvasOutput(pbnr))
      DrawingMode(#PB_2DDrawing_Gradient)
      BackColor(#White) 
      GradientColor(0.5, color)
      FrontColor(#Black)
      LinearGradient(0, 0, 0, h)
      Box(0, 0, w, h) 
      DrawingMode(#PB_2DDrawing_Transparent)
      
      x = (w - TextWidth(t$)) / 2 : y = 5 : th = TextHeight(t$)
      DrawText(x, y, t$ , #Black) : y + th
      
      x = (w - TextWidth(text$)) / 2
      DrawText(x, y, text$, #Black)         
      DrawRotatedText(w-5, h/4, "© HJBremer", 270, color ! #White)
      
      DrawingFont(fid) 
      p = h / 12
      For j = 1 To 11
         color = Point(5, p*j)
         Line(0, p*j, 5, 1, color ! #White)
         If j = 6: Circle(3, p*j, 2, color ! #White) : EndIf
         DrawText(6, p*j-TextHeight(t$) / 2, HexString(color), color ! #White)
      Next

   StopDrawing()      
EndProcedure

Procedure.i GetCanvasColor(pbnr)
   Protected color
   Protected x = GetGadgetAttribute(pbnr, #PB_Canvas_MouseX)
   Protected y = GetGadgetAttribute(pbnr, #PB_Canvas_MouseY)
   StartDrawing(CanvasOutput(pbnr))  
      If y > 0 And y < GadgetHeight(pbnr) 
         color = Point(x, y)
      EndIf
   StopDrawing() 
   ProcedureReturn color
EndProcedure

Procedure.i SetColorBox(pbnr, color, t$)      
   Protected cbr = GadgetWidth(pbnr), chh = GadgetHeight(pbnr)
   
   StartVectorDrawing(CanvasVectorOutput(pbnr))               
      AddPathBox(0, 0, cbr, chh) : VectorSourceColor($FF000000 | color): FillPath()   
      VectorFont(FontID(#fontnr), 15)
      VectorSourceColor($FF000000 | color ! #White)
      MovePathCursor(0, 9)
      DrawVectorParagraph(t$, cbr-4, chh, #PB_VectorParagraph_Center) 
      VectorFont(FontID(#fontnr), 12)
      MovePathCursor(0, chh-22)
      DrawVectorParagraph(HexString(color), cbr-4, chh, #PB_VectorParagraph_Center)         
   StopVectorDrawing()   
EndProcedure

Procedure.i SaveColor(pbnr, theme)
   
   Structure colormemory ;um Farben direkt zu setzen
      color.i[0]
   EndStructure
   
   Protected *cm.colormemory, j, text$, color
   
   *cm = Moveknop_GetValue(pbnr, #colormemory)
   For j = 0 To 8
      color = *cm\color[j]
      text$ + HexString(color) + ","
   Next                     
   SetClipboardText(text$)        ;save colors to Clipboard   
   Moveknop_Color(theme, text$)   ;save colors to File
   
EndProcedure

Procedure.i Container1(x, y, w, h, flag=0)
   
   Protected x1, x2, w1 = 60, w2 = 120      
   
   ContainerGadget(#container1, x, y, w, h, flag)      
      
      x = 10: y = 20: x1 = 50: x2 = x1 + w1 + 10: h = 25
      
      Moveknop(#knop_Test, x, y, 40, 100, "On,off", 1,0,0)
      
      TextGadget(#PB_Any, x1, y+2, w1, h, "Themes", #PB_Text_Right) ;|#PB_Text_Border)
      ComboBoxGadget(#combobox_theme, x2, y, w2, h) : y + h + 15
      
      TextGadget(#PB_Any, x1, y+2, w1, h, "Styles", #PB_Text_Right)
      ComboBoxGadget(#combobox_style, x2, y, w2, h) : y + h + 15
      
      TextGadget(#PB_Any, x1, y+2, w1, h, "Colors", #PB_Text_Right)
      ComboBoxGadget(#combobox_color, x2, y, w2, h) : y + h + 15
      
      CanvasGadget(#colorBox, x, y, w-x-x, h*3, #PB_Canvas_Border) : y + h*3 + 5 
      
      TextGadget(#PB_Any, x, y, w-x-x, h, "F5 = Get Color under Mouse  ", #PB_Text_Right) : y + h + 10      
      
      Moveknop(#knop_Speed, x, y, w2, 32, "Speed Loop,Speed Delay", 1, 1) : x + w2 + 15
      Moveknop_SetValue(#knop_Speed, #colortheme, 3)
      Moveknop_SetValue(#knop_Speed, #textsize, 14)
      
      Moveknop(#knop_Tinfo, x, y, w2, 32, "Info on,Info off", 0, 0, 0) : x = 15 : y + 45
      Moveknop_SetValue(#knop_Tinfo, #colortheme, 2)
      Moveknop_SetValue(#knop_Tinfo, #textsize, 15)
      
      TextGadget    (#trackbar_info, x, y, w, h, "Speed-Loop " + Moveknop_GetValue(#knop_Test, #speedloop))
      TrackBarGadget(#trackbar_speed, x-5, y+h, w-x-x+5, h, 5, 100, #PB_TrackBar_Ticks) 
      SetGadgetState(#trackbar_speed, Moveknop_GetValue(#knop_Test, #speedloop)) 
      
      x = GadgetX(#combobox_theme) + GadgetWidth(#combobox_theme) + 17
      y = GadgetY(#combobox_theme)
      Moveknop(#Knop_Save, x, y, 46, 46, "save,Save", 2, 0) : y + 50 + 12
      Moveknop(#knop_Font, x, y, 46, 46, "font,Font", 2, 1)
      
      Protected j, color, text$
      Protected t1$ = "Theme 1,Theme 2,Theme 3,Theme 4"
      Protected t2$ = "Knopstyle 0,Knopstyle 1,Knopstyle 2,Backstyle 0,Backstyle 1"
      Protected t3$ = "Parent,Rahmen,Knop aussen,Back ein,Back aus,Knop ein,Knop aus,Text ein,Text aus"
      
      x = Val(Moveknop_Color(0))   ; Anzahl Themes
      For j = 1 To x: AddGadgetItem(#combobox_theme, -1, "Theme " + Str(j)): Next
      For j = 1 To 5: AddGadgetItem(#combobox_style, -1, StringField(t2$, j, ",")): Next
      For j = 1 To 9: AddGadgetItem(#combobox_color, -1, StringField(t3$, j, ",")): Next
      
      SetGadgetState(#combobox_theme, 0)  ;state=0 ist Theme 1
      SetGadgetState(#combobox_style, 0)
      SetGadgetState(#combobox_color, 1)  ;state=1 ist Rahmen 
      
      color = Moveknop_GetValue(#knop_Test, GetGadgetState(#combobox_color))
      text$ = GetGadgetText(#combobox_color)
      SetColorBox(#colorBox, color, text$)
      
      x = 10
      y = GadgetY(#trackbar_speed) + GadgetHeight(#trackbar_speed) + 30
      
      Moveknop(#knop_Test1, x,y, 30, 60, "1,11",1,0,0,1) : x + 50
      Moveknop(#knop_Test2, x,y, 30, 60, "2,22",0,0,0,2) : x + 50
      Moveknop(#knop_Test3, x,y, 30, 60, "3,33",1,0,0,3) : x + 50
      Moveknop(#knop_Test4, x,y, 30, 60, "4,44",0,0,0,4) : x + 50
      Moveknop(#knop_Test5, x,y, 30, 60, "5,55",1,0,0,5) : x + 50
      Moveknop(#knop_Test6, x,y, 30, 60, "6,66",0,0,0,6) : x = 10 : y + 75
      
      Moveknop(#knop_Test11, x,y, 90, 40, "on,off", 0,0)    : y + 55
      Moveknop(#knop_Test12, x,y, 90, 40, "kill,aus", 2,0)  : x = 110 : y = GadgetY(#knop_Test11)
      Moveknop(#knop_Test13, x,y, 44, 77, "ein,aus", 1,1)
      
   CloseGadgetList()   
EndProcedure

Procedure.i Container2(x, y, w, h, flag=0)   
   ContainerGadget(#container2, x, y, w, h, flag)      
      CanvasGadget(#colorBoxRGB, 0, 0, w/2, h, #PB_Canvas_Border) 
      ColorBoxRGB(#colorBoxRGB)      
      CanvasGadget(#colorboxGradient, w/2, 0, w/2, h, #PB_Canvas_Border)      
      ColorBoxGradient(#colorboxGradient, #Gray)      
   CloseGadgetList()   
EndProcedure

;- Main

LoadFont(#fontnr, "Arial", 10)   
SetGadgetFont(#PB_Default, FontID(#fontnr))

Define event, window, flags = #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_Invisible
Define w = 640, h = 600

OpenWindow(#mainwindow, 0, 0, w, h, "Moveknop example", flags)

AddKeyboardShortcut(#mainwindow, #PB_Shortcut_F5, #PB_Shortcut_F5)

Container1( 0,  0, w/2, h, #PB_Container_Flat)
Container2(w/2, 0, w/2, h, #PB_Container_Flat)

HideWindow(#mainwindow, 0)

;- Repeat

Define fontname$ = "Arial"
Define j, x, y, text$, *cm.colormemory

Define state = GetGadgetState(#combobox_color)
Define color = Moveknop_GetValue(#knop_Test, state)
Define colorinfo$ = GetGadgetText(#combobox_color)

ColorBoxGradient(#colorboxGradient, color, colorinfo$)

Repeat
   event = WaitWindowEvent()      
   window = EventWindow()
   
   Select window
      Case #mainwindow
         If Event = #PB_Event_CloseWindow
            Break
            
         ElseIf event = #PB_Event_Menu
            Select EventMenu()
               Case #PB_Shortcut_F5
                  state = GetGadgetState(#combobox_color)   ;ColorCombo 0-8
                  text$ = GetGadgetText(#combobox_color)
                  color = GetColorUnderMouse()
                  SetColorBox(#colorBox, color, text$)
                  Moveknop_SetValue(#knop_Test, state, color)
                  ColorBoxGradient(#colorBoxGradient, color, colorinfo$)   ;Farbtafel rechts
            EndSelect
            
         ElseIf event = #PB_Event_Gadget 
            
            Select EventGadget()  
                  
                  ;- comboboxen
                  
               Case #combobox_theme                     
                  state = GetGadgetState(#combobox_theme) + 1
                  Moveknop_SetValue(#knop_Test, #colortheme, state)
                  PostEvent(#PB_Event_Gadget, #mainwindow, #combobox_color)   ;Farbbox aktualisieren
                 
               Case #combobox_style                     
                  state = GetGadgetState(#combobox_style) 
                  Select state
                     Case 0: Moveknop_SetValue(#knop_Test, #knopstyle, 0)
                     Case 1: Moveknop_SetValue(#knop_Test, #knopstyle, 1)
                     Case 2: Moveknop_SetValue(#knop_Test, #knopstyle, 2)
                     Case 3: Moveknop_SetValue(#knop_Test, #backstyle, 0)
                     Case 4: Moveknop_SetValue(#knop_Test, #backstyle, 1)
                  EndSelect
                  
               Case #combobox_color
                  state = GetGadgetState(#combobox_color)         ;ColorCombo 0-8
                  text$ = GetGadgetText(#combobox_color)
                  color = Moveknop_GetValue(#knop_Test, state)   ;Farbe von MoveKnop
                  SetColorBox(#colorBox, color, text$)
                  colorinfo$ = text$: ColorBoxGradient(#colorBoxGradient, color, colorinfo$)                  
                  Select state
                     Case 3,5,7: Moveknop_State(#knop_Test, 1)
                     Case 4,6,8: Moveknop_State(#knop_Test, 0)
                  EndSelect
                  
                  ;- colorbox RGB Gradient
                  
               Case #colorBox
                  If EventType() = #PB_EventType_LeftClick
                     color = GetCanvasColor(#colorBox) 
                     ColorBoxGradient(#colorBoxGradient, color, colorinfo$)   ;Farbtafel rechts
                  EndIf
                  
               Case #colorBoxRGB
                  If EventType() = #PB_EventType_LeftClick
                     state = GetGadgetState(#combobox_color)         ;ColorCombo 0-8
                     text$ = GetGadgetText(#combobox_color)
                     color = GetCanvasColor(#colorBoxRGB)         ;Farbe von RGB-Farbtafel       
                     SetColorBox(#colorBox, color, text$)
                     Moveknop_SetValue(#knop_Test, state, color)
                     ColorBoxGradient(#colorBoxGradient, color, colorinfo$)   ;Farbtafel rechts ändern               
                  EndIf
                  
               Case #colorBoxGradient
                  If EventType() = #PB_EventType_LeftClick
                     state = GetGadgetState(#combobox_color)      ;ColorCombo 0-8
                     text$ = GetGadgetText(#combobox_color)
                     color = GetCanvasColor(#colorBoxGradient)    ;von Farbtafel rechts
                     SetColorBox(#colorBox, color, text$)
                     Moveknop_SetValue(#knop_Test, state, color)
                  EndIf
                  
                  ;- Knop_ save, font, tinfo, speed (loop+delay)
                  
               Case #Knop_Save
                  If EventType() = #PB_EventType_LeftClick
                     state = GetGadgetState(#combobox_theme) + 1
                     SaveColor(#knop_Test, state)                     
                  ElseIf EventType() = #PB_EventType_RightClick
                     state = Val(Moveknop_Color(0)) + 1  ;read Anzahl + 1 für neu
                     SaveColor(#knop_Test, state)
                     AddGadgetItem(#combobox_theme, -1, "Theme " + Str(state))
                  EndIf
                  Select state
                     Case 1: Moveknop_SetValue(#knop_Test1, #colortheme, 1)
                     Case 2: Moveknop_SetValue(#knop_Test2, #colortheme, 2)
                     Case 3: Moveknop_SetValue(#knop_Test3, #colortheme, 3)
                     Case 4: Moveknop_SetValue(#knop_Test4, #colortheme, 4)
                     Case 5: Moveknop_SetValue(#knop_Test5, #colortheme, 5)
                     Case 6: Moveknop_SetValue(#knop_Test6, #colortheme, 6)                        
                  EndSelect
                  
               Case #knop_Font
                  If EventType() = #PB_EventType_LeftClick
                     x = GadgetX(#knop_Font, #PB_Gadget_ScreenCoordinate) + 50
                     y = WindowY(#mainwindow)
                     OpenWindow (#fontwindow, x, y, 0, 0, "", #PB_Window_BorderLess)
                     If FontRequester(fontname$, 10, 0)
                        fontname$ = SelectedFontName()
                        LoadFont(#fontnr2, fontname$, SelectedFontSize(), SelectedFontStyle())
                        Moveknop_SetValue(#knop_Test, #textfont, #fontnr2)
                     EndIf
                     CloseWindow(#fontwindow)
                  EndIf
                  
               Case #knop_Tinfo
                  If EventType() = #PB_EventType_LeftClick                     
                     If Moveknop_State(#knop_Tinfo)
                        Moveknop_SetValue(#knop_Test, #textinfo, 1)
                     Else
                        Moveknop_SetValue(#knop_Test, #textinfo, 0)
                     EndIf
                  EndIf
                  
               Case #knop_Speed
                  If EventType() = #PB_EventType_LeftClick                     
                     If Moveknop_State(#knop_Speed)
                        SetGadgetAttribute(#trackbar_speed, #PB_TrackBar_Minimum, 5)
                        SetGadgetAttribute(#trackbar_speed, #PB_TrackBar_Maximum, 100)
                        state = Moveknop_GetValue(#knop_Test, #speedloop)
                        SetGadgetText(#trackbar_info, "Loop: " + state)
                        SetGadgetState(#trackbar_speed, state) 
                     Else
                        SetGadgetAttribute(#trackbar_speed, #PB_TrackBar_Minimum, 0)
                        SetGadgetAttribute(#trackbar_speed, #PB_TrackBar_Maximum, 10)
                        state = Moveknop_GetValue(#knop_Test, #speeddelay)
                        SetGadgetText(#trackbar_info, "Delay: " + state)
                        SetGadgetState(#trackbar_speed, state)                     
                     EndIf
                  EndIf 
                  
               Case #trackbar_speed
                  state = GetGadgetState(#trackbar_speed) 
                  SetGadgetText(#trackbar_info, "Speed/Delay = " + state)                  
                  If Moveknop_State(#knop_Speed)
                     Moveknop_SetValue(#knop_Test, #speedloop, state)                     
                  Else
                     Moveknop_SetValue(#knop_Test, #speeddelay, state)                     
                  EndIf                 
                  state = Moveknop_State(#knop_Test) ! 1
                  Moveknop_State(#knop_Test, state)
                  
               Case #knop_Test
                  If EventType() = #PB_EventType_LeftClick                     
                  EndIf
                  
            EndSelect
            
         EndIf         
   EndSelect
ForEver
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 141
; FirstLine = 127
; Folding = --
; EnableXP