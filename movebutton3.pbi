;V3.35 HJBremer

;TODO image

DeclareModule MoveButton
   
   Declare.i Moveknop(pbnr, x, y, width, height, text$, textpos=0, knopstate=0, knopform=0, theme=0)
   
   Declare.i Moveknop_Free (pbnr)   
   Declare.i Moveknop_State(pbnr, state=-1)
   Declare.i Moveknop_GetValue(pbnr, typ)
   Declare.i Moveknop_SetValue(pbnr, typ, wert.d)   
   Declare.i Moveknop_SetText(pbnr, text$, textsize.d=0)
   
   Declare.s Moveknop_Color(nr, theme$="")   ;Farben laden/speichern
   
   Enumeration          ;!!! Wert für #colorparent + #colortheme nicht ändern !!!
      #colorparent = 0  ;BackColor Canvas, die Werte 1-8 sind reserviert für Farben
      #colortheme = 10  ;für Farbschemas laden/speichern
      #colormemory      ;Adresse der Farbwerte für ein Gadget      
      #backstyle        ;normal oder gradient
      #knopstyle        ;normal oder gradient
      #speedloop        ;setze Verzögerung
      #speeddelay       ;  ""
      #textinfo         ;schaltet Textrahmen etc ein
      #textfont         ;Font setzen
      #textsize         ;Vectorfont Size      
   EndEnumeration
   
   Macro HexString(color)
      "$"+RSet(Hex(color), 6, "0")
   EndMacro

EndDeclareModule

Module MoveButton
   
   EnableExplicit
   
   ;- Structure
   
   Structure knopcolor
      parent.i     ;BackColor Canvas ParentFenster
      frame.i      ;Rahmenfarbe      
      ring.i       ;KnopfColor aussen
      back_on.i    ;wenn eingeschaltet
      back_off.i   ;wenn aus   
      knop_on.i    ;wenn eingeschaltet
      knop_off.i   ;wenn aus      
      text_on.i    ;wenn eingeschaltet
      text_off.i   ;wenn aus      
   EndStructure
   
   Structure moveknop      
      pbnr.i
      width.d           ;Gadget breite/höhe
      height.d 
      
      xknop.d           ;x+y = posi vom knop
      yknop.d
      
      knopgap.d         ;Abstand Knopf von der Gadgetseite 
      knopgap2.d        ;Abstand Knopf 2mal
      framegap.d        ;Abstand Rahmen vom Gadget     
      knopsize.d        ;Knopf Durchmesser = 2 x Radius
      knopradius.d      ;vom Knopf
      frameradius.d     ;vom GadgetRahmen      
      
      colorback.i       ;intern GadgetBackColor
      colorknop.i       ;intern KnopfColor innen
      colortext.i       ;intern Textcolor      
      
      StructureUnion       ;alle Farben
         colorarray.i[9]   ;Zugriff über Array 0-8 = 9 Werte (siehe Hilfe Strukturen)
         color.knopcolor   ;oder KnopColor-Namen
      EndStructureUnion
      
      backstyle.i    ;0 oder 1
      knopstyle.i    ;wenn 1, sollte #colorknop_off dunkler sein als _on 
      knopform.i     ;0 oder 1
      
      loopflag.i     ;siehe moveknop_Press()      
      loop.i         ;anzahl Aufrufe zum Zeichnen für Bewegung vom Knop
      delay.i        ;zusätzliche Verzögerung beim zeichnen
      align.i        ;Ausrichtung vertikal / horizontal 
      state.i        ;off / on = 0 oder 1, wenn 2 wird push gesetzt
      push.i         ;wenn 1 = Button
      
      textflag.i     ;intern, sagt das Text vorhanden und gemalt werden soll
      textinfo.i     ;zeigt Textrahmen etc
      textfont.i     ;
      textsize.d     ;Texthöhe siehe Moveknop_SetText(pbnr, text$, textsize)
      textpos.i      ;im Knopf oder ausserhalb
      text.s         ;intern
      text_on.s      ;text$ für Moveknop_Text() = "on,off"
      text_off.s      
   EndStructure
   
   ;- Default Werte
   Global default_textfont = LoadFont(#PB_Any, "Consolas", 10, #PB_Font_Bold)
   Global default_textinfo = 0               ;mit Textrahmen und pbnr und state   
   Global default_speedloop = 50             ;Anzahl Bewegungs Wiederholungen
   Global default_speeddelay = 2             ;zusätzliche Verzögerung
   Global default_knopstyle = 0              ;0 normal, 1+2 Gradient
   Global default_backstyle = 0              ;0 normal, 1 Gradient
   
   Global default_color$ = Moveknop_Color(1) ;Farben laden   
   Global default_colorparent = -1           ;um 1.Farbe im colorarray zu überschreiben   
   
   ;- intern   
   Procedure.i AddRGB(color, wert)
      
      Protected r = Red(color) + wert, g = Green(color) + wert, b = Blue(color) + wert
      
      If r > 255: r = 255: EndIf : If r < 0: r = 0: EndIf
      If g > 255: g = 255: EndIf : If g < 0: g = 0: EndIf
      If b > 255: b = 255: EndIf : If b < 0: b = 0: EndIf
      
      ProcedureReturn RGB(r, g, b)      
   EndProcedure
   
   Procedure.i AddPathRoundBox(x, y, w, h, r)
      
      MovePathCursor(x+r, y)   ;Hilfe + Beispiel für AddPathArc() ist Grrrr...      
   
      AddPathArc(w-r , 0   , w-r  , r   , r, #PB_Path_Relative)    ;oben
      AddPathArc(0   , h-r , -r   , h-r , r, #PB_Path_Relative)    ;rechts
      AddPathArc(-w+r, 0   , -w+r , -r  , r, #PB_Path_Relative)    ;unten
      AddPathArc(0   , -h+r, r    , -h+r, r, #PB_Path_Relative)    ;links      
   EndProcedure   
   
   Procedure.i moveknop_DrawText(*mb.moveknop)      
      Protected a = $FF000000   ;Alphawert für Color 
      Protected.d x, y, textboxbr, textboxhh
      
      With *mb 
         
         If \textsize = 0
            \textsize = 1+(\knopradius) / (VectorResolutionY() / 72) ;:Debug \textsize
            If \align=0 And \textpos=0: \textsize * 1.7: EndIf       ;Gadget waagerecht + Text ausserhalb
            If Len(\text) <= 2: \textsize + 2.5: EndIf               ;
         EndIf         
         VectorFont(FontID(\textfont), \textsize) ;: Debug \textsize : Debug \text_on : Debug "--"
         
         If \align ;Gadget senkrecht            
            textboxbr = \height - \knopgap2
            textboxhh = VectorParagraphHeight(\text, textboxbr, \height)
            
            x = \xknop - textboxbr/2   ;Text immer im Knop
            y = \yknop - textboxhh/2               
            
            ;Text um Knop-Mittelpunkt zurück drehen, 
            ;betrifft folgende Text-Operationen bis StopDrawing() oder ResetCoordinates
            RotateCoordinates(\xknop, \yknop, 90)  ;xknop + yknop werden nicht verändert nur intern
           
         Else     ;Gadget waagerecht            
            textboxbr = \width - \knopsize - \knopgap2 - 2           ;Text neben Knop oder -1
            If \textpos: textboxbr = \knopsize - \knopgap2 : EndIf   ;Text im Knop
            
            textboxhh = VectorParagraphHeight(\text, textboxbr, \height)
            
            y = \yknop - textboxhh/2
            If \textpos ;Text im Knop
               x = \xknop - textboxbr/2
               
            Else        ;Text neben Knop
               x = \xknop + \knopradius + \knopgap - 4 ;Text neben dem Knop oder -2
               If \state And \push = 0
                  x = \xknop - \knopradius - \knopgap - textboxbr + 4 ; oder +2 (abhängig von textboxbr)                 
               EndIf
            EndIf
         EndIf
         
         If textboxhh = 0: textboxhh = 15: MessageRequester("", "Problem mit Font/Text"): EndIf
         
         MovePathCursor(x, y): VectorSourceColor(a | \colortext)
         
         ;DrawVectorParagraph bietet oft bessere Schrift
         DrawVectorParagraph(\text, textboxbr, textboxhh, #PB_VectorParagraph_Center)
         
         ;\textinfo = 1
         If \textinfo
            VectorSourceColor(a | \colortext) ;!#White
            AddPathBox(x, y, textboxbr, textboxhh) : StrokePath(1)
            VectorFont(FontID(\textfont), 10)            
            ResetCoordinates()
            MovePathCursor(5,1)            
            DrawVectorText(Str(\pbnr) + "-" + Str(\state))
         EndIf         
      EndWith      
   EndProcedure
   
   Procedure.i moveknop_DrawButton(*mb.moveknop)
      
      Protected color, a = $FF000000   ;Alphawert für Color       
      Protected.d x, y, g, w, h, r
      
      With *mb         
         StartVectorDrawing(CanvasVectorOutput(\pbnr))
            
            If \loopflag = 0  ;wird von moveknop_Press() auf halben Weg auf null gesetzt
               If \state
                  \text = \text_on 
                  \colortext = \color\text_on
                  \colorback = \color\back_on
                  \colorknop = \color\knop_on                  
               Else
                  \text = \text_off
                  \colortext = \color\text_off
                  \colorback = \color\back_off
                  \colorknop = \color\knop_off    
               EndIf
            EndIf
            
            If \align   ;Senkrecht
               ;betrifft nachfolgende ZeichenOperationen bis StopDrawing() oder Reset....
               TranslateCoordinates(0, \width): RotateCoordinates(0, 0, -90)     
            EndIf
            
            ;Canvas komplett füllen bzw löschen mit \colorparent
            AddPathBox(0, 0, \width, \height) : VectorSourceColor(a | \color\parent): FillPath()
            
            ;Background malen mit Rahmen + runden Ecken
            g = \framegap            ;Rahmenabstand  vom CanvasGadget
            w = \width-g-g
            h = \height-g-g
            r = \frameradius
            
            AddPathRoundBox(g, g, w, h, r)
            VectorSourceColor(a | \color\frame)   ;Rahmenfarbe aussen
            StrokePath(3, #PB_Path_Preserve)      ;Dicke 3 oder so, Path bleibt offen für FillPath()            
            VectorSourceColor(a | $aaaaaa)        ;ausfüllen mit Hellgrau ergibt Rahmen innen
            FillPath()
         
            ;Background innen, Hellgrau mit 2 Pixel Abstand übermalen, ergibt Doppelrahmen
            If \backstyle = 0 ;normal
               VectorSourceColor(a | \colorback)
               AddPathRoundBox(g+2, g+2, w-4, h-4, r)
               FillPath()
            Else
               color = a | \colorback
               VectorSourceLinearGradient(0, 0, 0, h)
               VectorSourceGradientColor(a | color, 0.0)
               VectorSourceGradientColor(a | AddRGB(\colorback, 32), 0.5)
               VectorSourceGradientColor(a | color, 1.0)
               AddPathRoundBox(g+2, g+2, w-4, h-4, r)
               FillPath()            
            EndIf
            
            ;knop
            
            If \knopform = 0 ;rund               
               x = \xknop
               y = \yknop
               r = \knopradius
               
               ;knop malen - rund - aussen (Rahmen)
               AddPathCircle(x, y, r): VectorSourceColor(a | \color\ring): FillPath()
               
               ;knop malen - rund - innen = radius-2
               If \knopstyle = 0
                  color = AddRGB(\colorknop, -$33)
                  AddPathCircle(x, y, r-1): VectorSourceColor(a | color): FillPath() 
                  AddPathCircle(x, y, r-2): VectorSourceColor(a | \colorknop): FillPath() 
               Else               
                  VectorSourceCircularGradient(\xknop, \yknop, r-2) ;vom Mittelpunkt aus
                  VectorSourceGradientColor($FFe6e6e6, 0.0)         ;r-2 muß sein wegen Aussehen
                  If \knopstyle = 2
                     VectorSourceGradientColor($FF888888, 0.8) 
                  EndIf
                  VectorSourceGradientColor(a | \colorknop, 1.0)               
                  FillVectorOutput()               
                  ;damit es schöner aussieht, hier übermalen 
                  AddPathCircle(x, y, r-2): VectorSourceColor(a | \colorknop): StrokePath(1) 
               EndIf
               
            Else ;eckig
               
               x = \xknop-\knopradius
               y = \yknop-\knopradius  
               w = \knopsize           
               r = \frameradius - 3 ;2
               
               ;Workaround wegen w-6, w sonst negativ ! allgemeines Problem von AddPathRoundBox
               If w-6 < r*2: r = 4: EndIf  
               
               ;knop malen - eckig - aussen (Rahmen)
               AddPathRoundBox(x, y, w, w, r)            
               VectorSourceColor(a | \color\ring): FillPath()
               
               ;knop malen - eckig - innen
               If \knopstyle = 0
                  color = AddRGB(\colorknop, -$33)
                  AddPathRoundBox(x+1, y+1, w-2, w-2, r): VectorSourceColor(a | color): FillPath()            
                  AddPathRoundBox(x+2, y+2, w-4, w-4, r): VectorSourceColor(a | \colorknop): FillPath() 
               Else
                  AddPathRoundBox(x+2, y+2, w-4, w-4, r)
                  SaveVectorState() ;wegen ClipPath
                  ClipPath()        ;siehe Hilfe, dadurch kann mann CircularGradient im Viereck benutzen
                  VectorSourceCircularGradient(\xknop, \yknop, \knopsize) ;vom Mittelpunkt aus
                  VectorSourceGradientColor($FFe6e6e6, 0.0)
                  If \knopstyle = 2
                     VectorSourceGradientColor($FFe6e6e6, 0.1)
                  EndIf
                  VectorSourceGradientColor(a | \colorknop, 1.0)               
                  FillVectorOutput()
                  RestoreVectorState() ; ClipPath aufheben
                  AddPathRoundBox(x+2, y+2, w-4, w-4, r): VectorSourceColor(a | \colorknop): StrokePath(1)
               EndIf
               
            EndIf
            
            ;Text
            If \textflag : moveknop_DrawText(*mb) : EndIf
            
         StopVectorDrawing()
         Delay(\delay)
         
      EndWith      
   EndProcedure
   
   Procedure.i moveknop_Press(*mb.moveknop)      
      Protected j, add.d
      
      With *mb         
         If \state = 0
            \state = 1
            \xknop = \knopradius + \knopgap         
         Else
            \state = 0
            \xknop = \width - \knopradius - \knopgap          
         EndIf   
         
         If \push    ;ähnlich einem Button ohne Bewegung
            \xknop = \knopradius + \knopgap  ;zur Sicherheit nochmal zuweisen
            moveknop_DrawButton(*mb)         ;nur einmal zeichnen
         Else            
            ;zeichnet knop mehrmals um Bewegung zu simulieren
            add = ( \width - \xknop - \xknop) / \loop    ;um diesen Wert bewegt sich Knop           
            \loopflag = 1                                ;Farben ändern sich in _DrawButton() 
            For j = 1 To \loop                           ;  erst auf halben Weg
               If j > \loop/2: \loopflag = 0: EndIf      ;  wegen loop/2
               \xknop + add  
               moveknop_DrawButton(*mb)
            Next         
         EndIf         
      EndWith      
   EndProcedure
   
   Procedure.i moveknop_Event()     
      Protected color, *mb.moveknop = GetGadgetData(EventGadget())
  
      Select EventType() 
         Case #PB_EventType_LeftButtonDown  ;Schalter
            moveknop_Press(*mb)
            
         Case #PB_EventType_LeftButtonUp, #PB_EventType_RightButtonUp ;für Taster = normaler Button
            
            If *mb\push = 1 And *mb\state = 1 ;in moveknop_Press wird state null
               moveknop_Press(*mb)            
            EndIf 
            
         Case #PB_EventType_RightButtonDown
            
            If *mb\push = 1 And *mb\state = 0 ;in off Stellung wie LeftButtonDown
               color = *mb\color\knop_on
               *mb\color\knop_on = color ! #White
               moveknop_Press(*mb)
               *mb\color\knop_on = color
            EndIf 
            
      EndSelect       
   EndProcedure
   
   Procedure.i moveknop_GetData(pbnr)     
      Protected error, text$
      
      If IsGadget(pbnr) = 0
         error = 1: text$ = "unbekannte Gadgetnr: " + pbnr         
      ElseIf GadgetType(pbnr) <> #PB_GadgetType_Canvas
         error = 2: text$ = "kein CanvasGadget: " + pbnr         
      ElseIf GetGadgetData(pbnr) = 0
         error = 3: text$ = "kein MoveButton: " + pbnr
      EndIf      
      If error: MessageRequester("Fehler", "moveknop_GetData: " + text$) : End : EndIf
      
      ProcedureReturn GetGadgetData(pbnr)      
   EndProcedure
   
   ;- extern 
   
   Procedure.s Moveknop_Color(nr, theme$="")
      ;Lesen oder Schreiben eines Colorthemestring
      
      ; [Moveknop] Beispiel 
      ; Theme1 = $F0F0F0,$0075FF,$949494,$BABABA,$999999,$00EFE5,$CFCFCF,$0000FF,$2D2D2D,
      
      Static def$ = "$F0F0F0,$FF0000,$00FFFF,$BABABA,$999999,$11B5FF,$666666,$0000FF,$000000,"
      
      Protected anz, name$ = "Theme" + Str(nr)
      
      Protected ok = OpenPreferences("MoveknopColors.txt")      
      If Not ok : CreatePreferences("MoveknopColors.txt") : EndIf
      
      PreferenceGroup("Moveknop") 
      
      If nr = 0   ;Anzahl vorhandener Themes zurückgeben
         ExaminePreferenceKeys()
         While NextPreferenceKey() ; Solange ein Schlüssel existiert...
            anz+1     
         Wend
         theme$ = Str(anz)
      Else      
         If theme$ = ""       ;Read
            theme$ = ReadPreferenceString(name$, "")
            If theme$ = ""    ;wenn nicht vorhanden, dann erstellen
               theme$ = def$
               WritePreferenceString(name$, theme$)            
            EndIf
         Else                 ;Write
            WritePreferenceString(name$, theme$)
         EndIf
      EndIf
      ClosePreferences()
      
      ProcedureReturn theme$
   EndProcedure   
   
   Procedure.i Moveknop_GetValue(pbnr, typ)
      Protected *mb.moveknop = moveknop_GetData(pbnr)
      
      With *mb            
         Select typ         
            Case 0,#colorparent: ProcedureReturn \colorarray[0]
            Case 0 To 8:         ProcedureReturn \colorarray[typ] ;Farben        
            Case #textsize:      ProcedureReturn \textsize        ;Fontgrösse
            Case #speedloop:     ProcedureReturn \loop         ;Knop Bewegung langsam/schneller
            Case #speeddelay:    ProcedureReturn \delay        ;Knop Bewegung langsam/schneller
            Case #colormemory:   ProcedureReturn @ *mb\color   ;um Farben direkt zu setzen
         EndSelect
      EndWith
      
      ProcedureReturn *mb   ;wenn typ unbekannt z.B. -1   
   EndProcedure
   
   Procedure.i Moveknop_SetValue(pbnr, typ, wert.d)
      Protected j, k, x$, *mb.moveknop
      
      If pbnr = #PB_Default
         Select typ
            Case 0,#colorparent: default_colorparent = wert
            Case #colortheme: 
               k = Val(Moveknop_Color(0))
               Select wert
                  Case 1 To k: default_color$ = Moveknop_Color(wert)
                  Default: Debug "Theme unbekannt:" + wert
               EndSelect
            Case #textinfo:  default_textinfo = wert 
            Case #textfont:  default_textfont = wert 
            Case #knopstyle: default_knopstyle = wert               
            Case #backstyle: default_backstyle = wert
            Case #speedloop: default_speedloop  = wert
            Case #speeddelay: default_speeddelay = wert
         EndSelect
         
      Else      
         *mb.moveknop = moveknop_GetData(pbnr)
         
         With *mb            
            Select typ                  
               Case 0,#colorparent: \colorarray[0] = wert                  
               Case 0 To 8:         \colorarray[typ] = wert
               Case #colortheme: 
                  k = Val(Moveknop_Color(0))
                  Select wert
                     Case 1 To k
                        x$ = Moveknop_Color(wert) ;theme lesen
                        For j = 0 To 8            ;ins ButtonMemory
                           \colorarray[j] = Val(StringField(x$, j+1, ","))
                        Next
                     Default: Debug "Theme unbekannt:" + wert
                  EndSelect
               Case #textinfo: \textinfo = wert
               Case #textfont:  \textfont = wert
               Case #textsize:   \textsize = wert                  
               Case #knopstyle : \knopstyle = wert
               Case #backstyle : \backstyle = wert                  
               Case #speedloop : \loop  = wert
               Case #speeddelay: \delay = wert
            EndSelect            
            
            moveknop_DrawButton(*mb)            
         EndWith
      EndIf      
   EndProcedure
   
   Procedure.i Moveknop_Free(pbnr)
      Protected *mb.moveknop = moveknop_GetData(pbnr)
      FreeStructure(*mb)
      FreeGadget(pbnr)
   EndProcedure
   
   Procedure.i Moveknop_State(pbnr, state=-1)
      Protected *mb.moveknop = moveknop_GetData(pbnr)
      If state = -1
         ProcedureReturn *mb\state
      Else
         If *mb\state <> state         
            PostEvent(#PB_Event_Gadget, EventWindow(), pbnr, #PB_EventType_LeftButtonDown)
         EndIf
      EndIf
   EndProcedure
   
   Procedure.i Moveknop_SetText(pbnr, text$, textsize.d=0)
      Protected *mb.moveknop = moveknop_GetData(pbnr)
      *mb\textsize = textsize
      *mb\textflag = 1
      *mb\text_on = StringField(text$, 1, ","): If *mb\text_on="": *mb\text_on=" ": EndIf
      *mb\text_off = StringField(text$, 2, ","): If *mb\text_off="": *mb\text_off=" ": EndIf
      moveknop_DrawButton(*mb)  
   EndProcedure
   
   Procedure.i Moveknop(pbnr, x, y, width, height, text$, knopstate=0, knopform=0, textpos=0, theme=0)
      
      Protected j, id, color$, *mb.moveknop = AllocateStructure(moveknop)
      
      id = CanvasGadget(pbnr, x, y, width, height)   
      If pbnr = #PB_Any : pbnr = id : EndIf       
      
      With *mb
         \pbnr = pbnr
         
         ;Vorgaben
         \state = knopstate       ;on/off = 0 oder 1, oder 2         
         \textpos = textpos       ;1 innen 0 aussen
         \knopform = knopform     ;1 eckig 0 rund
         
         If \state = 2 : \state = 0 : \push = 1 : EndIf  ;wenn 2 dann Button (Taster)
         
         \textinfo = default_textinfo         ;Textrahmen + pbnr + state anzeigen
         \textfont = default_textfont
         
         If width > height
            \align = 0        ;knop waagerecht      
            \width = width
            \height = height
         Else
            \align = 1        ;knop senkrecht
            \width = height   ;Werte vertauschen für TranslateCoordinates()   
            \height = width   ;                  und RotateCoordinates() 
            \textpos = 1      ;1 = Text innen = im Knop 
         EndIf
         
         color$ = default_color$
         If theme : color$ = Moveknop_Color(theme) : EndIf  ;andere Farben laden
         
         For j = 0 To 8: \colorarray[j] = Val(StringField(color$, j+1, ",")): Next
         
         If default_colorparent <> -1: \colorarray[0] = default_colorparent: EndIf
         
         \knopstyle = default_knopstyle   ;normal oder Gradient
         \backstyle = default_backstyle   ;normal oder Gradient         
         \loop = default_speedloop        ;Anzahl Aufrufe von StartDawing() für Bewegung vom Knop
         \delay = default_speeddelay      ;zusätzliche Verzögerung, für loop ab 10, delay ca 2
         
         \framegap = 2                       ; Abstand Rahmen vom CanvasGadget
         \frameradius = 10                   ; Rundung Rahmen         
         \knopgap = 5 + 0                    ; Abstand Knop von CanvasGadgetrand, auch +2
         \knopgap2 = \knopgap + \knopgap     ; Abstand Knop 2mal
         \knopsize = \height - \frameradius  ; Knopdurchmesser, Knop kleiner: knopgap +2 und knopsize -4
         \knopradius = \knopsize / 2         ; KnopRadius
         \yknop = \height /2                 ; Mittelpunkt des Kreises  
         
         If text$
            \textflag = 1
            \text_on = StringField(text$, 1, ","): If \text_on = "": \text_on = " ": EndIf
            \text_off = StringField(text$, 2, ","): If \text_off = "": \text_off = " ": EndIf 
         EndIf
         
         If \state = 0 ;Aus 
            \xknop = \knopradius + \knopgap
         Else
            \xknop = \width - \knopradius - \knopgap
         EndIf          
      EndWith      
      
      SetGadgetData(pbnr, *mb)      
      SetGadgetAttribute(pbnr, #PB_Canvas_Cursor, #PB_Cursor_Hand)   
      BindGadgetEvent(pbnr, @moveknop_Event(), #PB_EventType_LeftButtonDown)
      BindGadgetEvent(pbnr, @moveknop_Event(), #PB_EventType_LeftButtonUp)      
      BindGadgetEvent(pbnr, @moveknop_Event(), #PB_EventType_RightButtonDown)
      BindGadgetEvent(pbnr, @moveknop_Event(), #PB_EventType_RightButtonUp)
      
      moveknop_DrawButton(*mb)  
      
      ProcedureReturn id      
   EndProcedure
   
EndModule

UseModule MoveButton

; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; Folding = ---
; EnableXP