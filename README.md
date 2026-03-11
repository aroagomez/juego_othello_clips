# Othello con IA en CLIPS

[cite_start]Este proyecto consiste en la implementación del juego de mesa Othello (Reversi) utilizando el sistema experto CLIPS[cite: 256]. [cite_start]El sistema permite jugar partidas entre jugadores humanos, o en la modalidad de jugador contra máquina[cite: 257].

## Características Técnicas y Algoritmos
[cite_start]El núcleo del proyecto es el desarrollo de un jugador automático capaz de tomar decisiones inteligentes evaluando el estado del juego[cite: 261]. 

Para la toma de decisiones, el motor de Inteligencia Artificial implementa los siguientes algoritmos de búsqueda en espacio de estados:
* [cite_start]**Minimax:** Evalúa recursivamente los movimientos posibles alternando entre maximizar (IA) y minimizar (oponente)[cite: 366].
* [cite_start]**Poda Alfa-Beta (Alpha-Beta Pruning):** Optimización del algoritmo Minimax que poda las ramas inútiles del árbol de búsqueda para mejorar la eficiencia temporal[cite: 355].

## Funciones Heurísticas
[cite_start]La evaluación de los nodos hoja en el árbol de búsqueda se realiza mediante una combinación de heurísticas que calculan la ventaja estratégica[cite: 325]:
* [cite_start]**Diferencia de fichas:** Puntúa en base a la diferencia de fichas propias frente a las del oponente[cite: 308].
* [cite_start]**Movilidad:** Evalúa la ventaja estratégica calculando la cantidad de movimientos posibles restantes[cite: 307, 311].
* [cite_start]**Control de esquinas:** Asigna puntuación positiva extra por cada esquina dominada, al ser posiciones estables[cite: 315, 316].
* [cite_start]**Esquinas adyacentes:** Penaliza las fichas ubicadas en posiciones adyacentes a las esquinas por el riesgo de perderlas[cite: 320, 322].

## Representación del Entorno
* [cite_start]**Tablero Dinámico:** Representación estructurada mediante una lista lineal (multislot) adaptable a tamaños de 4x4, 6x6 y 8x8 casillas[cite: 335, 386].
* [cite_start]**Sistema Basado en Reglas:** Uso de reglas de producción (condición-acción) para controlar el flujo de turnos, la validación de movimientos y las condiciones de victoria o empate[cite: 341, 349].

## Ejecución
Para iniciar el juego en el entorno CLIPS:
1. Cargar el código fuente en el entorno.
2. [cite_start]Ejecutar el comando `(run)` en la consola[cite: 374].
3. [cite_start]Introducir los parámetros de configuración solicitados (tipo de jugadores, algoritmo, profundidad de búsqueda y tamaño del tablero)[cite: 377, 383, 386].