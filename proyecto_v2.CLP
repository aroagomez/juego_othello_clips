(deftemplate tablero
	(multislot casillas (type SYMBOL)(allowed-symbols B N _))
)

(deftemplate jugador
	(slot color (type SYMBOL)(allowed-symbols B N))
	(slot tipo (type SYMBOL)(allowed-symbols H M))
	(slot turno (type SYMBOL)(allowed-symbols T F))	
	(slot fichas (type INTEGER))
	(slot fichasPuestas (type INTEGER))
)

(defglobal ?*tamanio* = 0)
(defglobal ?*profundidadMax* = 1)
(defglobal ?*algoritmo* = 1)

(deffunction sacarMulticampoDeMulticampo (?inicio $?multi)
    (bind ?i ?inicio)
    (bind ?fin (length$ $?multi))
    (bind $?sol (create$))
    (while (<= ?i ?fin)
        (bind $?sol (insert$ $?sol (+ (length$ $?sol) 1) (nth$ ?i $?multi)))
        (bind ?i (+ ?i 1))
    )
    (return $?sol)
)

(deffunction imprimir($?tablero)
	
	(printout t crlf "      ")
	(loop-for-count (?i 1 ?*tamanio*)
		(printout t ?i "   ")
	)
	(printout t crlf)
	(printout t "     ")
	(loop-for-count ?*tamanio*
		(printout t "___ ")
	)
	(printout t crlf)

	(bind ?inicio 1)
	
	(loop-for-count (?i 1 ?*tamanio*)
		(printout t "    ")
		(loop-for-count ?*tamanio*
			(printout t "|   ")
		)
		(printout t "|" crlf)
		(printout t "  " ?i " |")
		;;;;;;;;;;;;;;;;;;;;;;;;
		;aquí consigo una fila entera del tablero
		(bind $?fila (sacarMulticampoDeMulticampo ?inicio $?tablero))
		;;;;;;;;;;;;;;;;;;;;;;;
		(loop-for-count (?j 1 ?*tamanio*)
			(if (eq (nth$ ?j $?fila) _)
				then (printout t "   " "|")
				else(printout t " " (nth$ ?j $?fila) " |")
			)
			
		)
		(printout t crlf "    ")
		(loop-for-count ?*tamanio*
			(printout t "|___")
		)
		(printout t "|" crlf)
		(bind ?inicio (+ ?inicio ?*tamanio*))
	)
	(printout t crlf)
)

(deffunction posicion (?fil ?col)
	(return (+(* ?*tamanio* (- ?fil 1)) ?col))
)

(deffunction calcularFichasPuestas (?colMio ?colOpo $?c)

	(bind ?fichasPuestasMias 0)
	(bind ?fichasPuestasOpo 0)

	(bind ?fil 1)
	(while (<= ?fil ?*tamanio*)
		(bind ?col 1)
		(while (<= ?col ?*tamanio*)
			(bind ?valor (nth$ (posicion ?fil ?col) $?c))
			(if (eq ?valor ?colMio) then
				(bind ?fichasPuestasMias (+ ?fichasPuestasMias 1))
			)
			(if (eq ?valor ?colOpo) then
				(bind ?fichasPuestasOpo (+ ?fichasPuestasOpo 1))
			)
			(bind ?col (+ ?col 1))
		)
		(bind ?fil (+ ?fil 1))
	)
	(return (create$ ?fichasPuestasMias ?fichasPuestasOpo))
)

(deffunction comprobarQueTengoFichas (?fichasMias ?fichasOpo ?colMio ?colOpo $?c)

	(if (and(= ?fichasMias 0)(> ?fichasOpo 0)) then
			(bind ?fichasMias 1)
			(bind ?fichasOpo (- ?fichasOpo 1))
	)
	(return (create$ ?fichasMias ?fichasOpo))

)

(deffunction revisarDireccion (?fil ?dFil ?col ?dCol ?colMio ?colOpo $?c)

	(bind ?atrapada F)
	(bind ?filC ?fil)
	(bind ?colC ?col)
	(if (eq (nth$ (posicion ?filC ?colC) $?c) _) then
		(bind ?continuar T)
	else
		(bind ?continuar F)
	)
	

	(while (and (eq ?continuar T) (>= ?filC 1) (<= ?filC ?*tamanio*) (>= ?colC 1) (<= ?colC ?*tamanio*))

		(bind ?filC (+ ?filC ?dFil))
		(bind ?colC (+ ?colC ?dCol))

		(if (or (< ?filC 1) (> ?filC ?*tamanio*) (< ?colC 1) (> ?colC ?*tamanio*)) then
			(bind ?continuar F)
			(return FALSE)
			(break)
		)

		(bind ?valor (nth$ (posicion ?filC ?colC) $?c))

		(if (eq ?valor _) then 
			(bind ?continuar F)
			(return FALSE)
		)

		(if (eq ?valor ?colOpo) then
			(bind ?atrapada T)
		)

		(if (eq ?valor ?colMio) then
			(bind ?continuar F)
			(if (eq ?atrapada T) then
				(return TRUE)
			else 
				(return FALSE)
			)
		)
	)
	(return FALSE)
)

(deffunction capturarDireccion (?fil ?dFil ?col ?dCol ?colMio ?colOpo ?fichasMias ?fichasOpo $?c)

	(bind ?filC (+ ?fil ?dFil))
	(bind ?colC (+ ?col ?dCol))

	(while (neq (nth$ (posicion ?filC ?colC) $?c) ?colMio)
		(bind $?fichas2 (comprobarQueTengoFichas ?fichasMias ?fichasOpo ?colMio ?colOpo $?c))
		(bind ?fichasMias (nth$ 1 $?fichas2))
		(bind ?fichasOpo (nth$ 2 $?fichas2))
		(bind ?pos (posicion ?filC ?colC))
		(bind $?c (replace$ $?c ?pos ?pos ?colMio))
		(bind ?fichasMias (- ?fichasMias 1))
		(bind ?fichasOpo (+ ?fichasOpo 1))
		(bind ?filC (+ ?filC ?dFil))
		(bind ?colC (+ ?colC ?dCol))
	)
	(return (create$ ?fichasMias ?fichasOpo $?c))
)

(deffunction esPosicionPosible (?fil ?col ?colMio ?colOpo $?c)
	;;Horizontal derecha
	(bind ?hd (revisarDireccion ?fil 0 ?col 1 ?colMio ?colOpo $?c))
	
	;;Horizontal izquierda
	(bind ?hi (revisarDireccion ?fil 0 ?col -1 ?colMio ?colOpo $?c))
	
	;;Vertical arriba
	(bind ?var (revisarDireccion ?fil -1 ?col 0 ?colMio ?colOpo $?c))
	
	;;Vertical abajo
	(bind ?vab (revisarDireccion ?fil 1 ?col 0 ?colMio ?colOpo $?c))
	
	;;Diagonal arriba derecha
	(bind ?dard (revisarDireccion ?fil -1 ?col 1 ?colMio ?colOpo $?c))
	
	;;Diagonal abajo derecha
	(bind ?dabd (revisarDireccion ?fil 1 ?col 1 ?colMio ?colOpo $?c))
	
	;;Diagonal arriba izquierda
	(bind ?dari (revisarDireccion ?fil -1 ?col -1 ?colMio ?colOpo $?c))
	
	;;Diagonal abajo izquierda
	(bind ?dabi (revisarDireccion ?fil 1 ?col -1 ?colMio ?colOpo $?c))

	;;Comprobar se puede hacer el movimiento
	(if (or (eq ?hd TRUE)(eq ?hi TRUE)(eq ?var TRUE)(eq ?vab TRUE)(eq ?dard TRUE)(eq ?dari TRUE)(eq ?dabd TRUE)(eq ?dabi TRUE)) then
		(return TRUE)
	)
	(return FALSE)
)

(deffunction hayAlgunMovimiento (?colMio ?colOpo $?c)

	(bind ?fil 1)
	(bind ?continuar T)

	(while (<= ?fil ?*tamanio*)

		(bind ?col 1)

		(while (<= ?col ?*tamanio*)

			(bind ?esPosible (esPosicionPosible ?fil ?col ?colMio ?colOpo $?c))
			(if (eq ?esPosible TRUE) then
				(bind ?continuar F)
				(return TRUE)
			)
			
			(bind ?col (+ ?col 1))
		)
		(bind ?fil (+ ?fil 1))
	)
	(return FALSE)		
)

(deffunction mover (?colMio ?colOpo ?fil ?col ?fichasMias ?fichasOpo $?c)
	;;Horizontal derecha
	(bind ?hd (revisarDireccion ?fil 0 ?col 1 ?colMio ?colOpo $?c))
	(if (eq ?hd TRUE) then
		(bind $?res (capturarDireccion ?fil 0 ?col 1 ?colMio ?colOpo ?fichasMias ?fichasOpo $?c))	
		(bind ?fichasMias (nth$ 1 $?res))
		(bind ?fichasOpo (nth$ 2 $?res))
		(bind $?c (sacarMulticampoDeMulticampo 3 $?res))
	)
	;;Horizontal izquierda
	(bind ?hi (revisarDireccion ?fil 0 ?col -1 ?colMio ?colOpo $?c))
	(if (eq ?hi TRUE) then
		(bind $?res (capturarDireccion ?fil 0 ?col -1 ?colMio ?colOpo ?fichasMias ?fichasOpo $?c))
		(bind ?fichasMias (nth$ 1 $?res))
		(bind ?fichasOpo (nth$ 2 $?res))
		(bind $?c (sacarMulticampoDeMulticampo 3 $?res))
	)
	;;Vertical arriba
	(bind ?var (revisarDireccion ?fil -1 ?col 0 ?colMio ?colOpo $?c))
	(if (eq ?var TRUE) then
		(bind $?res (capturarDireccion ?fil -1 ?col 0 ?colMio ?colOpo ?fichasMias ?fichasOpo $?c))
		(bind ?fichasMias (nth$ 1 $?res))
		(bind ?fichasOpo (nth$ 2 $?res))
		(bind $?c (sacarMulticampoDeMulticampo 3 $?res))
	)
	;;Vertical abajo
	(bind ?vab (revisarDireccion ?fil 1 ?col 0 ?colMio ?colOpo $?c))
	(if (eq ?vab TRUE) then
		(bind $?res (capturarDireccion ?fil 1 ?col 0 ?colMio ?colOpo ?fichasMias ?fichasOpo $?c))
		(bind ?fichasMias (nth$ 1 $?res))
		(bind ?fichasOpo (nth$ 2 $?res))
		(bind $?c (sacarMulticampoDeMulticampo 3 $?res))
	)
	;;Diagonal arriba derecha
	(bind ?dard (revisarDireccion ?fil -1 ?col 1 ?colMio ?colOpo $?c))
	(if (eq ?dard TRUE) then
		(bind $?res (capturarDireccion ?fil -1 ?col 1 ?colMio ?colOpo ?fichasMias ?fichasOpo $?c))
		(bind ?fichasMias (nth$ 1 $?res))
		(bind ?fichasOpo (nth$ 2 $?res))
		(bind $?c (sacarMulticampoDeMulticampo 3 $?res))
	)
	;;Diagonal abajo derecha
	(bind ?dabd (revisarDireccion ?fil 1 ?col 1 ?colMio ?colOpo $?c))
	(if (eq ?dabd TRUE) then
		(bind $?res (capturarDireccion ?fil 1 ?col 1 ?colMio ?colOpo ?fichasMias ?fichasOpo $?c))
		(bind ?fichasMias (nth$ 1 $?res))
		(bind ?fichasOpo (nth$ 2 $?res))
		(bind $?c (sacarMulticampoDeMulticampo 3 $?res))
	)
	;;Diagonal arriba izquierda
	(bind ?dari (revisarDireccion ?fil -1 ?col -1 ?colMio ?colOpo $?c))
	(if (eq ?dari TRUE) then
		(bind $?res (capturarDireccion ?fil -1 ?col -1 ?colMio ?colOpo ?fichasMias ?fichasOpo $?c))
		(bind ?fichasMias (nth$ 1 $?res))
		(bind ?fichasOpo (nth$ 2 $?res))
		(bind $?c (sacarMulticampoDeMulticampo 3 $?res))
	)
	;;Diagonal abajo izquierda
	(bind ?dabi (revisarDireccion ?fil 1 ?col -1 ?colMio ?colOpo $?c))
	(if (eq ?dabi TRUE) then
		(bind $?res (capturarDireccion ?fil 1 ?col -1 ?colMio ?colOpo ?fichasMias ?fichasOpo $?c))
		(bind ?fichasMias (nth$ 1 $?res))
		(bind ?fichasOpo (nth$ 2 $?res))
		(bind $?c (sacarMulticampoDeMulticampo 3 $?res))
	)
	(bind $?fichas (comprobarQueTengoFichas ?fichasMias ?fichasOpo ?colMio ?colOpo $?c))
	(bind ?fichasMias (nth$ 1 $?fichas))
	(bind ?fichasOpo (nth$ 2 $?fichas))
	(bind $?c (replace$ $?c (posicion ?fil ?col) (posicion ?fil ?col) ?colMio))
	(bind ?fichasMias (- ?fichasMias 1))
	(return (create$ ?fichasMias ?fichasOpo $?c))
)

(deffunction movimientoManual (?colMio ?colOpo ?fichasMias ?fichasOpo $?c)

	(printout t "Es el turno del jugador " ?colMio crlf)
	(bind ?hayMov (hayAlgunMovimiento ?colMio ?colOpo $?c))

	(if (eq ?hayMov TRUE) then
		(printout t "Introduzca en que fila y columna desea poner una ficha de su color: " crlf)
		(bind ?fil (read))
		(while (or(not (integerp ?fil))(> ?fil ?*tamanio*))
			(printout t "Por favor introduzca un numero entero valido para la fila: " crlf)
			(bind ?fil (read))
		)
		(bind ?col (read))
		(while (or(not (integerp ?col))(> ?col ?*tamanio*))
			(printout t "Por favor introduzca un numero entero valido para la columna: " crlf)
			(bind ?col (read))
		)

		;;Comprobar que he podido hacer el movimiento
		(if (eq (esPosicionPosible ?fil ?col ?colMio ?colOpo $?c) FALSE) then
			(printout t "El movimiento no es valido, introduzca uno que lo sea porfavor." crlf)
			(movimientoManual ?colMio ?colOpo ?fichasMias ?fichasOpo $?c)
		else
			(printout t "Movimiento realizado." crlf)
			(return (mover ?colMio ?colOpo ?fil ?col ?fichasMias ?fichasOpo $?c))
		)
	else
		(printout t "No hay ningun movimiento posible, se pasa de turno." crlf)
	)	

	(return (create$ ?fichasMias ?fichasOpo $?c))
)

(deffunction movimientosPosibles (?colMio ?colOpo $?c)

	(bind $?sol (create$))
	(bind ?fil 1)

	(while (<= ?fil ?*tamanio*)

		(bind ?col 1)

		(while (<= ?col ?*tamanio*)

			(bind ?esPosible (esPosicionPosible ?fil ?col ?colMio ?colOpo $?c))
			(if (eq ?esPosible TRUE) then
				(bind $?sol (insert$ $?sol (+ (length$ $?sol) 1) ?fil))
				(bind $?sol (insert$ $?sol (+ (length$ $?sol) 1) ?col))
			)
			
			(bind ?col (+ ?col 1))
		)
		(bind ?fil (+ ?fil 1))
	)
	(return $?sol)		
)

(deffunction movilidad (?colMio ?colOpo $?c)

	(bind $?misMovs (movimientosPosibles ?colMio ?colOpo $?c))
	(bind $?opoMovs (movimientosPosibles ?colOpo ?colMio $?c))

    (bind ?movMio (/ (length$ $?misMovs) 2))
    (bind ?movOpo (/ (length$ ?opoMovs) 2))

    (return (create$ ?movMio ?movOpo))
)

(deffunction evaluadorDifFich (?colMio ?colOpo $?c)

    (bind ?puntuacion 0)

	(bind $?fichas (calcularFichasPuestas ?colMio ?colOpo $?c))
	(bind ?fichasPuestasMias (nth$ 1 $?fichas))
	(bind ?fichasPuestasOpo (nth$ 2 $?fichas))

    (bind ?fichasTotal (+ ?fichasPuestasMias ?fichasPuestasOpo))

    (if (> ?fichasPuestasMias ?fichasPuestasOpo) then
    	(bind ?puntuacion (* (/ ?fichasPuestasMias ?fichasTotal ) 100 ))
    )

    (if (< ?fichasPuestasMias ?fichasPuestasOpo) then
    	(bind ?puntuacion (* (/ ?fichasPuestasOpo ?fichasTotal ) -100 ))
    )

    (return ?puntuacion)
)

(deffunction evaluadorDifMov (?colMio ?colOpo $?c)

    (bind ?puntuacion 0)
    (bind $?movs (movilidad ?colMio ?colOpo $?c))
    (bind ?movMio (nth$ 1 $?movs))
    (bind ?movOpo (nth$ 2 $?movs))

	(bind ?movTotal (+ ?movMio ?movOpo))
   
    (if (> ?movMio ?movOpo) then
    	(bind ?puntuacion (* (/ ?movMio ?movTotal) 100 ))
    )

    (if (< ?movMio ?movOpo) then
    	(bind ?puntuacion (* (/ ?movOpo ?movTotal ) -100 ))
    )

    (return ?puntuacion)
)

(deffunction cuantasEsquinas (?col $?c)

    (bind ?esq 0)

    ;;(1, 1)
    (if (eq (nth$ (posicion 1 1) $?c) ?col) then
        (bind ?esq (+ ?esq 1))
    )

    ;;(1, tam)
    (if (eq (nth$ (posicion 1 ?*tamanio*) $?c) ?col) then
        (bind ?esq (+ ?esq 1))
    )

    ;;(tam, 1)
    (if (eq (nth$ (posicion ?*tamanio* 1) $?c) ?col) then
        (bind ?esq (+ ?esq 1))
    )

    ;;(tam, tam)
    (if (eq (nth$ (posicion ?*tamanio* ?*tamanio*) $?c) ?col) then
        (bind ?esq (+ ?esq 1))
    )

    (return ?esq)
)

(deffunction evaluadorEsquinas (?colMio ?colOpo $?c)

    (bind ?esqMio (cuantasEsquinas ?colMio $?c))

    (bind ?esqOpo (cuantasEsquinas ?colOpo $?c))

    (bind ?puntuacion (- (* ?esqMio 25) (* ?esqOpo 25)))

    (return ?puntuacion)
)

(deffunction esquinasAdyacentes (?col $?c)

    (bind ?esq 0)

	;;Adyacentes esquina (1,1)
		;;(1, 2)

		(if (eq (nth$ (posicion 1 2) $?c) ?col) then
			(bind ?esq (+ ?esq 1))
		)

		;;(2, 1)

		(if (eq (nth$ (posicion 2 1) $?c) ?col) then
			(bind ?esq (+ ?esq 1))
		)

		;;(2, 2)

		(if (eq (nth$ (posicion 2 2) $?c) ?col) then
			(bind ?esq (+ ?esq 1))
		)

	;;Adyacentes esquina (1, tam)
		;;(2, tam)
	
		(if (eq (nth$ (posicion 2 ?*tamanio*) $?c) ?col) then
			(bind ?esq (+ ?esq 1))
		)

		;;(1, tam-1)
	
		(if (eq (nth$ (posicion 1 (- ?*tamanio* 1)) $?c) ?col) then
			(bind ?esq (+ ?esq 1))
		)

		;;(2, tam-1)
	
		(if (eq (nth$ (posicion 2 (- ?*tamanio* 1)) $?c) ?col) then
			(bind ?esq (+ ?esq 1))
		)

	;;Adyacentes(tam, 1)
		;;(tam-1, 1)

		(if (eq (nth$ (posicion (- ?*tamanio* 1) 1) $?c) ?col) then
			(bind ?esq (+ ?esq 1))
		)

		;;(tam, 2)

		(if (eq (nth$ (posicion ?*tamanio* 2) $?c) ?col) then
			(bind ?esq (+ ?esq 1))
		)

		;;(tam-1, 2)

		(if (eq (nth$ (posicion (- ?*tamanio* 1) 2) $?c) ?col) then
			(bind ?esq (+ ?esq 1))
		)

	;;Adyacentes (tam, tam)
		;;(tam-1, tam)

		(if (eq (nth$ (posicion (- ?*tamanio* 1) ?*tamanio*) $?c) ?col) then
			(bind ?esq (+ ?esq 1))
		)

		;;(tam, tam-1)

		(if (eq (nth$ (posicion ?*tamanio* (- ?*tamanio* 1)) $?c) ?col) then
			(bind ?esq (+ ?esq 1))
		)

		;;(tam-1, tam-1)

		(if (eq (nth$ (posicion (- ?*tamanio* 1) (- ?*tamanio* 1)) $?c) ?col) then
			(bind ?esq (+ ?esq 1))
		)

    (return ?esq)
)

(deffunction evaluadorEsqAdy (?colMio ?colOpo $?c)

    (bind ?esqMioAdy (esquinasAdyacentes ?colMio $?c))

    (bind ?esqOpoAdy (esquinasAdyacentes ?colOpo $?c))

    (bind ?puntuacion (- (* ?esqOpoAdy 12.5) (* ?esqMioAdy 12.5)))

    (return ?puntuacion)

)

(deffunction evalua (?colMio ?colOpo $?c)

    (bind ?puntuacion 0)

    (bind ?puntuacion (+ ?puntuacion (evaluadorDifFich ?colMio ?colOpo $?c)))

    (bind ?puntuacion (+ ?puntuacion (evaluadorDifMov ?colMio ?colOpo $?c)))

    (bind ?puntuacion (+ ?puntuacion (evaluadorEsquinas ?colMio ?colOpo $?c)))

    (bind ?puntuacion (+ ?puntuacion (evaluadorEsqAdy ?colMio ?colOpo $?c)))

    (return ?puntuacion)
)

(deffunction minimax (?colActual ?colOponente ?profundidad ?esMaximizando $?tablero)
    (if (or (= ?profundidad 0) 
            (not (hayAlgunMovimiento ?colActual ?colOponente $?tablero))) then
        (return (evalua ?colOponente ?colActual $?tablero))  
    )
    
    (if ?esMaximizando then
        (bind ?mejorValor -10000)
        (bind $?movs (movimientosPosibles ?colActual ?colOponente $?tablero))
        (bind ?numMovs (/ (length$ $?movs) 2))
        
        (bind ?i 1)
        (while (<= ?i ?numMovs)
            (bind ?fil (nth$ (- (* ?i 2) 1) $?movs))
            (bind ?col (nth$ (* ?i 2) $?movs))
            
            (bind $?tempRes (mover ?colActual ?colOponente ?fil ?col 
                                  (nth$ 1 (calcularFichasPuestas ?colActual ?colOponente $?tablero))
                                  (nth$ 2 (calcularFichasPuestas ?colActual ?colOponente $?tablero))
                                  $?tablero))
            (bind $?tempTab (sacarMulticampoDeMulticampo 3 $?tempRes))
            
            (bind ?valor (minimax ?colOponente ?colActual (- ?profundidad 1) FALSE $?tempTab))
            
            (if (> ?valor ?mejorValor) then
                (bind ?mejorValor ?valor)
            )
            
            (bind ?i (+ ?i 1))
        )
        (return ?mejorValor)
    else
        (bind ?mejorValor 10000)
        (bind $?movs (movimientosPosibles ?colActual ?colOponente $?tablero))
        (bind ?numMovs (/ (length$ $?movs) 2))
        
        (bind ?i 1)
        (while (<= ?i ?numMovs)
            (bind ?fil (nth$ (- (* ?i 2) 1) $?movs))
            (bind ?col (nth$ (* ?i 2) $?movs))
            
            (bind $?tempRes (mover ?colActual ?colOponente ?fil ?col 
                                  (nth$ 1 (calcularFichasPuestas ?colActual ?colOponente $?tablero))
                                  (nth$ 2 (calcularFichasPuestas ?colActual ?colOponente $?tablero))
                                  $?tablero))
            (bind $?tempTab (sacarMulticampoDeMulticampo 3 $?tempRes))
            
            (bind ?valor (minimax ?colOponente ?colActual (- ?profundidad 1) TRUE $?tempTab))
            
            (if (< ?valor ?mejorValor) then
                (bind ?mejorValor ?valor)
            )
            
            (bind ?i (+ ?i 1))
        )
        (return ?mejorValor)
    )
)

(deffunction alphabeta (?colActual ?colOponente ?profundidad ?esMaximizando ?alpha ?beta $?tablero)
    (if (or (= ?profundidad 0) 
            (not (hayAlgunMovimiento ?colActual ?colOponente $?tablero))) then
        (return (evalua ?colOponente ?colActual $?tablero))  
    )
    
    (if ?esMaximizando then
        (bind $?movs (movimientosPosibles ?colActual ?colOponente $?tablero))
        (bind ?numMovs (/ (length$ $?movs) 2))
        
        (bind ?i 1)
        (while (<= ?i ?numMovs)
            (bind ?fil (nth$ (- (* ?i 2) 1) $?movs))
            (bind ?col (nth$ (* ?i 2) $?movs))
            
            (bind $?tempRes (mover ?colActual ?colOponente ?fil ?col 
                                  (nth$ 1 (calcularFichasPuestas ?colActual ?colOponente $?tablero))
                                  (nth$ 2 (calcularFichasPuestas ?colActual ?colOponente $?tablero))
                                  $?tablero))
            (bind $?tempTab (sacarMulticampoDeMulticampo 3 $?tempRes))
            
            (bind ?valor (alphabeta ?colOponente ?colActual (- ?profundidad 1) FALSE ?alpha ?beta $?tempTab))
            
            (if (> ?valor ?alpha) then
                (bind ?alpha ?valor)
            )

            (if (>= ?alpha ?beta) then
                (return ?alpha)
            )
            
            (bind ?i (+ ?i 1))
        )
        (return ?alpha)
    else
        (bind $?movs (movimientosPosibles ?colActual ?colOponente $?tablero))
        (bind ?numMovs (/ (length$ $?movs) 2))
        
        (bind ?i 1)
        (while (<= ?i ?numMovs)
            (bind ?fil (nth$ (- (* ?i 2) 1) $?movs))
            (bind ?col (nth$ (* ?i 2) $?movs))
            
            (bind $?tempRes (mover ?colActual ?colOponente ?fil ?col 
                                  (nth$ 1 (calcularFichasPuestas ?colActual ?colOponente $?tablero))
                                  (nth$ 2 (calcularFichasPuestas ?colActual ?colOponente $?tablero))
                                  $?tablero))
            (bind $?tempTab (sacarMulticampoDeMulticampo 3 $?tempRes))

            (bind ?valor (alphabeta ?colOponente ?colActual (- ?profundidad 1) TRUE ?alpha ?beta $?tempTab))
            
            (if (< ?valor ?beta) then
                (bind ?beta ?valor)
            )

            (if (>= ?alpha ?beta) then
                (return ?beta)
            )
            
            (bind ?i (+ ?i 1))
        )
        (return ?beta)
    )
)


(defrule inicializar
	(initial-fact)
=>
	(printout t "El jugador 1 (color negro) es una humano (H) o la maquina(M)?" crlf)
	(bind ?tipo1 (read))
	(while (and (neq ?tipo1 H)(neq ?tipo1 M))
		(printout t "El tipo no es valido, introduzca uno que lo sea (H/M): " crlf)
		(bind ?tipo1 (read))
	)
	(if (eq ?tipo1 M) then
		(printout t "Desea aplicar el algoritmo minimax(1) o alphabeta(2)?:" crlf)
		(bind ?*algoritmo* (read))
		(while (and (neq ?*algoritmo* 1)(neq ?*algoritmo* 2))
			(printout t "El algoritmo no es valido, introduzca uno que lo sea (1/2): " crlf)
			(bind ?*algoritmo* (read))
		)
		(printout t "Introduzca la profundidad con la que desea aplicar el algoritmo (<10):" crlf)
		(bind ?*profundidadMax* (read))
		(while (> ?*profundidadMax* 10)
			(printout t "Introduzca una profundidad valida (<10):" crlf)
			(bind ?*profundidadMax* (read))
		)
	)

	(printout t "El jugador 2 (color blanco) es una humano (H) o la maquina(M)?" crlf)
	(bind ?tipo2 (read))
	(while (and (neq ?tipo2 H)(neq ?tipo2 M))
		(printout t "El tipo no es valido, introduzca uno que lo sea (H/M): " crlf)
		(bind ?tipo2 (read))
	)
	(if (eq ?tipo2 M) then
		(printout t "Desea aplicar el algoritmo minimax(1) o alphabeta(2)?:" crlf)
		(bind ?*algoritmo* (read))
		(while (and (neq ?*algoritmo* 1)(neq ?*algoritmo* 2))
			(printout t "El algoritmo no es valido, introduzca uno que lo sea (1/2): " crlf)
			(bind ?*algoritmo* (read))
		)
		(printout t "Introduzca la profundidad con la que desea aplicar el algoritmo (<10):" crlf)
		(bind ?*profundidadMax* (read))
		(while (> ?*profundidadMax* 10)
			(printout t "Introduzca una profundidad valida (<10):" crlf)
			(bind ?*profundidadMax* (read))
		)
	)
	
	(printout t "Introduzca de cuantas por cuantas casillas es el tablero (4/6/8): " crlf)
	(bind ?*tamanio* (read))
	(while (and (neq ?*tamanio* 4)(neq ?*tamanio* 6)(neq ?*tamanio* 8))
		(printout t "El tamanio no es valido, introduzca uno que lo sea (4/6/8): " crlf)
		(bind ?*tamanio* (read))
	)

	(switch ?*tamanio*
		(case 4	then
			(assert (tablero (casillas _ _ _ _ _ N B _ _ B N _ _ _ _ _)))
			(assert (jugador (color N)(tipo ?tipo1)(turno T)(fichas 6)(fichasPuestas 2)))
			(assert (jugador (color B)(tipo ?tipo2)(turno F)(fichas 6)(fichasPuestas 2)))
		)
		(case 6 then
			(assert (tablero (casillas _ _ _ _ _ _ _ _ _ _ _ _ _ _ N B _ _ _ _ B N _ _ _ _ _ _ _ _ _ _ _ _ _ _)))
			(assert (jugador (color N)(tipo ?tipo1)(turno T)(fichas 16)(fichasPuestas 2)))
			(assert (jugador (color B)(tipo ?tipo2)(turno F)(fichas 16)(fichasPuestas 2)))
		)
		(case 8 then
			(assert (tablero (casillas _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ N B _ _ _ _ _ _ B N _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _)))
			(assert (jugador (color N)(tipo ?tipo1)(turno T)(fichas 30)(fichasPuestas 2)))
			(assert (jugador (color B)(tipo ?tipo2)(turno F)(fichas 30)(fichasPuestas 2)))
		)
	)	
)



(defrule moverManual

	(declare (salience 10))

	?t <- (tablero(casillas $?c))
	?j <- (jugador(color ?colMio)(turno T)(tipo H)(fichas ?fichasMias)(fichasPuestas ?fichasPuestasMias))
	?opo <- (jugador(color ?colOpo)(turno F)(tipo ?tipoOpo)(fichas ?fichasOpo)(fichasPuestas ?fichasPuestasOpo))
=>	
	(imprimir $?c)

	(if (and (eq (hayAlgunMovimiento ?colMio ?colOpo $?c) FALSE) (eq (hayAlgunMovimiento ?colOpo ?colMio $?c) FALSE)) then
		(assert (no-hay-movimientos))
	)

	(bind $?res1 (movimientoManual ?colMio ?colOpo ?fichasMias ?fichasOpo $?c))
	(bind ?fMias (nth$ 1 $?res1))
	(bind ?fOpo (nth$ 2 $?res1))
	(bind $?tab (sacarMulticampoDeMulticampo 3 $?res1))

	(bind $?res2 (calcularFichasPuestas ?colMio ?colOpo $?tab))
	(bind ?fPuestasMias (nth$ 1 $?res2))
	(bind ?fPuestasOpo (nth$ 2 $?res2))
	
	(modify ?j (fichas ?fMias)(turno F)(fichasPuestas ?fPuestasMias))
	(modify ?opo (fichas ?fOpo) (turno T)(fichasPuestas ?fPuestasOpo))
	(modify ?t (casillas $?tab))
	(printout t)
)

(defrule moverMaquina
    (declare (salience 10))
    
    ?t <- (tablero (casillas $?c))
    ?j <- (jugador (color ?colMio) (turno T) (tipo M) (fichas ?fichasMias) (fichasPuestas ?fichasPuestasMias))
    ?opo <- (jugador (color ?colOpo) (turno F) (tipo ?tipoOpo) (fichas ?fichasOpo) (fichasPuestas ?fichasPuestasOpo))
=>
    (imprimir $?c)
    
    (if (eq (hayAlgunMovimiento ?colMio ?colOpo $?c) FALSE) then
        (printout t "La máquina no tiene movimientos disponibles, pasa turno." crlf)
        (modify ?j (turno F))
        (modify ?opo (turno T))
    else
        (bind $?movs (movimientosPosibles ?colMio ?colOpo $?c))
        (bind ?numMovs (/ (length$ $?movs) 2))

        (bind ?mejorValor -10000)
        (bind ?mejorFil 0)
        (bind ?mejorCol 0)
        
        (if (eq ?*algoritmo* 1) then

            (printout t "Turno de la máquina (" ?colMio ") pensando (Minimax)..." crlf)
            
            (bind ?i 1)
            (while (<= ?i ?numMovs)
                (bind ?fil (nth$ (- (* ?i 2) 1) $?movs))
                (bind ?col (nth$ (* ?i 2) $?movs))
                
                (bind $?tempRes (mover ?colMio ?colOpo ?fil ?col ?fichasMias ?fichasOpo $?c))
                (bind $?tempTab (sacarMulticampoDeMulticampo 3 $?tempRes))
                
                (bind ?valor (minimax ?colOpo ?colMio ?*profundidadMax* FALSE $?tempTab))
                
                (if (> ?valor ?mejorValor) then
                    (bind ?mejorValor ?valor)
                    (bind ?mejorFil ?fil)
                    (bind ?mejorCol ?col)
                )
                
                (bind ?i (+ ?i 1))
            )
        else

            (printout t "Turno de la máquina (" ?colMio ") pensando (Alpha-Beta)..." crlf)
            
            (bind ?alpha -10000)
            (bind ?beta 10000)
            (bind ?i 1)
            
            (while (<= ?i ?numMovs)
                (bind ?fil (nth$ (- (* ?i 2) 1) $?movs))
                (bind ?col (nth$ (* ?i 2) $?movs))
                
                (bind $?tempRes (mover ?colMio ?colOpo ?fil ?col ?fichasMias ?fichasOpo $?c))
                (bind $?tempTab (sacarMulticampoDeMulticampo 3 $?tempRes))
                
                (bind ?valor (alphabeta ?colOpo ?colMio ?*profundidadMax* FALSE ?alpha ?beta $?tempTab))

                (if (> ?valor ?mejorValor) then
                    (bind ?mejorValor ?valor)
                    (bind ?mejorFil ?fil)
                    (bind ?mejorCol ?col)
                    (bind ?alpha ?valor)
                )

                (if (>= ?alpha ?beta) then
                    (break)
                )
                
                (bind ?i (+ ?i 1))
            )
        )

        (printout t "La máquina coloca ficha en (" ?mejorFil "," ?mejorCol ")" crlf)
        (bind $?res (mover ?colMio ?colOpo ?mejorFil ?mejorCol ?fichasMias ?fichasOpo $?c))
        (bind ?fMias (nth$ 1 $?res))
        (bind ?fOpo (nth$ 2 $?res))
        (bind $?tab (sacarMulticampoDeMulticampo 3 $?res))
        
        (bind $?res2 (calcularFichasPuestas ?colMio ?colOpo $?tab))
        (bind ?fPuestasMias (nth$ 1 $?res2))
        (bind ?fPuestasOpo (nth$ 2 $?res2))
        
        (modify ?j (fichas ?fMias) (turno F) (fichasPuestas ?fPuestasMias))
        (modify ?opo (fichas ?fOpo) (turno T) (fichasPuestas ?fPuestasOpo))
        (modify ?t (casillas $?tab))
    )
)
(defrule acabar_todoFichasMismoColor

	(declare (salience 20))

	?t <- (tablero(casillas $?c))
	?perdedor <- (jugador(color ?colPierde)(turno ?turnoPierde)(tipo ?tipoPierde)(fichas ?fichasPierde)(fichasPuestas 0))
	?ganador <- (jugador(color ?colGana)(turno ?turnoGana)(tipo ?tipoGan)(fichas ?fichasGana)(fichasPuestas ?fichasPuestasGana))
	(test (neq ?colGana ?colPierde))
=>
	(imprimir $?c)
	(printout t "La partida ha finalizado porque no queda ninguna ficha de color " ?colPierde " colocada en el tablero." crlf)

	(printout t "Gana el jugador " ?colGana " con un total de " ?fichasPuestasGana " puntos." crlf)
	(halt)
)

(defrule acabar_tableroLleno
    (declare (salience 25))
    ?t <- (tablero (casillas $?c))
    (test (not (member$ _ $?c)))  ; Verifica que no hay casillas vacías
    ?j <- (jugador(color ?colMio)(turno ?turnoMio)(tipo ?tipoMio)(fichas 0)(fichasPuestas ?fichasPuestasMias))
	?opo <- (jugador(color ?colOpo)(turno ?turnoOpo)(tipo ?tipoOpo)(fichas 0)(fichasPuestas ?fichasPuestasOpo))
	(test (neq ?colMio ?colOpo))
=>	
	(imprimir $?c)
	(printout t "La partida ha finalizado porque el tablero se ha llenado." crlf)

	(if (> ?fichasPuestasMias ?fichasPuestasOpo) then
		(printout t "Ha ganado el jugador " ?colMio " con un total de " ?fichasPuestasMias " puntos." crlf)
	)
	(if (< ?fichasPuestasMias ?fichasPuestasOpo) then
		(printout t "Ha ganado el jugador " ?colOpo " con un total de " ?fichasPuestasOpo " puntos." crlf)
	)
	(if (eq ?fichasPuestasMias ?fichasPuestasOpo) then
		(printout t "Ha habido un empate, ambos jugadores tienen un total de " ?fichasPuestasMias " puntos." crlf)
	)
	(halt)
)

(defrule acabar_noHayMovs
	(declare (salience 25))
	(no-hay-movimientos)

	?t <- (tablero (casillas $?c))
    ?j <- (jugador(color ?colMio)(turno ?turnoMio)(tipo ?tipoMio)(fichas ?fichasMias)(fichasPuestas ?fichasPuestasMias))
	?opo <- (jugador(color ?colOpo)(turno ?turnoOpo)(tipo ?tipoOpo)(fichas ?fichasOpo)(fichasPuestas ?fichasPuestasOpo))
	(test (neq ?colMio ?colOpo))
=>
	(imprimir $?c)
	(printout t "La partida ha finalizado porque ningun jugador tiene movimientos disponibles." crlf)

	(if (> ?fichasPuestasMias ?fichasPuestasOpo) then
		(printout t "Ha ganado el jugador " ?colMio " con un total de " ?fichasPuestasMias " puntos." crlf)
	)
	(if (< ?fichasPuestasMias ?fichasPuestasOpo) then
		(printout t "Ha ganado el jugador " ?colOpo " con un total de " ?fichasPuestasOpo " puntos." crlf)
	)
	(if (eq ?fichasPuestasMias ?fichasPuestasOpo) then
		(printout t "Ha habido un empate, ambos jugadores tienen un total de " ?fichasPuestasMias " puntos." crlf)
	)
	(halt)

)